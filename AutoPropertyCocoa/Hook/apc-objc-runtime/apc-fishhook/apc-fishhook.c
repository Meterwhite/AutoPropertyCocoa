// Copyright (c) 2013, Facebook, Inc.
// All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name Facebook nor the names of its contributors may be used to
//     endorse or promote products derived from this software without specific
//     prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "apc-fishhook.h"

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#ifdef __LP64__
typedef struct mach_header_64 apc_mach_header_t;
typedef struct segment_command_64 apc_segment_command_t;
typedef struct section_64 apc_section_t;
typedef struct nlist_64 apc_nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header apc_mach_header_t;
typedef struct segment_command apc_segment_command_t;
typedef struct section apc_section_t;
typedef struct nlist apc_nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

#ifndef SEG_DATA_CONST
#define SEG_DATA_CONST  "__DATA_CONST"
#endif

struct apc_rebindings_entry {
  struct apc_rebinding *apc_rebindings;
  size_t apc_rebindings_nel;
  struct apc_rebindings_entry *next;
};

static struct apc_rebindings_entry *_apc_rebindings_head;

static int prepend_apc_rebindings(struct apc_rebindings_entry **apc_rebindings_head,
                              struct apc_rebinding apc_rebindings[],
                              size_t nel) {
  struct apc_rebindings_entry *new_entry = (struct apc_rebindings_entry *) malloc(sizeof(struct apc_rebindings_entry));
  if (!new_entry) {
    return -1;
  }
  new_entry->apc_rebindings = (struct apc_rebinding *) malloc(sizeof(struct apc_rebinding) * nel);
  if (!new_entry->apc_rebindings) {
    free(new_entry);
    return -1;
  }
  memcpy(new_entry->apc_rebindings, apc_rebindings, sizeof(struct apc_rebinding) * nel);
  new_entry->apc_rebindings_nel = nel;
  new_entry->next = *apc_rebindings_head;
  *apc_rebindings_head = new_entry;
  return 0;
}

static void perform_apc_rebinding_with_section(struct apc_rebindings_entry *apc_rebindings,
                                           apc_section_t *section,
                                           intptr_t slide,
                                           apc_nlist_t *symtab,
                                           char *strtab,
                                           uint32_t *indirect_symtab) {
  uint32_t *indirect_symbol_indices = indirect_symtab + section->reserved1;
  void **indirect_symbol_bindings = (void **)((uintptr_t)slide + section->addr);
  for (uint i = 0; i < section->size / sizeof(void *); i++) {
    uint32_t symtab_index = indirect_symbol_indices[i];
    if (symtab_index == INDIRECT_SYMBOL_ABS || symtab_index == INDIRECT_SYMBOL_LOCAL ||
        symtab_index == (INDIRECT_SYMBOL_LOCAL   | INDIRECT_SYMBOL_ABS)) {
      continue;
    }
    uint32_t strtab_offset = symtab[symtab_index].n_un.n_strx;
    char *symbol_name = strtab + strtab_offset;
    bool symbol_name_longer_than_1 = symbol_name[0] && symbol_name[1];
    struct apc_rebindings_entry *cur = apc_rebindings;
    while (cur) {
      for (uint j = 0; j < cur->apc_rebindings_nel; j++) {
        if (symbol_name_longer_than_1 &&
            strcmp(&symbol_name[1], cur->apc_rebindings[j].name) == 0) {
          if (cur->apc_rebindings[j].replaced != NULL &&
              indirect_symbol_bindings[i] != cur->apc_rebindings[j].replacement) {
            *(cur->apc_rebindings[j].replaced) = indirect_symbol_bindings[i];
          }
          indirect_symbol_bindings[i] = cur->apc_rebindings[j].replacement;
          goto symbol_loop;
        }
      }
      cur = cur->next;
    }
  symbol_loop:;
  }
}

static void apc_rebind_symbols_for_image(struct apc_rebindings_entry *apc_rebindings,
                                     const struct mach_header *header,
                                     intptr_t slide) {
  Dl_info info;
  if (dladdr(header, &info) == 0) {
    return;
  }

  apc_segment_command_t *cur_seg_cmd;
  apc_segment_command_t *linkedit_segment = NULL;
  struct symtab_command* symtab_cmd = NULL;
  struct dysymtab_command* dysymtab_cmd = NULL;

  uintptr_t cur = (uintptr_t)header + sizeof(apc_mach_header_t);
  for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
    cur_seg_cmd = (apc_segment_command_t *)cur;
    if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
      if (strcmp(cur_seg_cmd->segname, SEG_LINKEDIT) == 0) {
        linkedit_segment = cur_seg_cmd;
      }
    } else if (cur_seg_cmd->cmd == LC_SYMTAB) {
      symtab_cmd = (struct symtab_command*)cur_seg_cmd;
    } else if (cur_seg_cmd->cmd == LC_DYSYMTAB) {
      dysymtab_cmd = (struct dysymtab_command*)cur_seg_cmd;
    }
  }

  if (!symtab_cmd || !dysymtab_cmd || !linkedit_segment ||
      !dysymtab_cmd->nindirectsyms) {
    return;
  }

  // Find base symbol/string table addresses
  uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
  apc_nlist_t *symtab = (apc_nlist_t *)(linkedit_base + symtab_cmd->symoff);
  char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);

  // Get indirect symbol table (array of uint32_t indices into symbol table)
  uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);

  cur = (uintptr_t)header + sizeof(apc_mach_header_t);
  for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
    cur_seg_cmd = (apc_segment_command_t *)cur;
    if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
      if (strcmp(cur_seg_cmd->segname, SEG_DATA) != 0 &&
          strcmp(cur_seg_cmd->segname, SEG_DATA_CONST) != 0) {
        continue;
      }
      for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
        apc_section_t *sect =
          (apc_section_t *)(cur + sizeof(apc_segment_command_t)) + j;
        if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
          perform_apc_rebinding_with_section(apc_rebindings, sect, slide, symtab, strtab, indirect_symtab);
        }
        if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
          perform_apc_rebinding_with_section(apc_rebindings, sect, slide, symtab, strtab, indirect_symtab);
        }
      }
    }
  }
}

static void _apc_rebind_symbols_for_image(const struct mach_header *header,
                                      intptr_t slide) {
    apc_rebind_symbols_for_image(_apc_rebindings_head, header, slide);
}

int apc_rebind_symbols_image(void *header,
                         intptr_t slide,
                         struct apc_rebinding apc_rebindings[],
                         size_t apc_rebindings_nel) {
    struct apc_rebindings_entry *apc_rebindings_head = NULL;
    int retval = prepend_apc_rebindings(&apc_rebindings_head, apc_rebindings, apc_rebindings_nel);
    apc_rebind_symbols_for_image(apc_rebindings_head, (const struct mach_header *) header, slide);
    if (apc_rebindings_head) {
      free(apc_rebindings_head->apc_rebindings);
    }
    free(apc_rebindings_head);
    return retval;
}

int apc_rebind_symbols(struct apc_rebinding apc_rebindings[], size_t apc_rebindings_nel) {
  int retval = prepend_apc_rebindings(&_apc_rebindings_head, apc_rebindings, apc_rebindings_nel);
  if (retval < 0) {
    return retval;
  }
  // If this was the first call, register callback for image additions (which is also invoked for
  // existing images, otherwise, just run on existing images
  if (!_apc_rebindings_head->next) {
    _dyld_register_func_for_add_image(_apc_rebind_symbols_for_image);
  } else {
    uint32_t c = _dyld_image_count();
    for (uint32_t i = 0; i < c; i++) {
      _apc_rebind_symbols_for_image(_dyld_get_image_header(i), _dyld_get_image_vmaddr_slide(i));
    }
  }
  return retval;
}
