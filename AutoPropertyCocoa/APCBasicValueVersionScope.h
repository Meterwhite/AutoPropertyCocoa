#define APCTemplate_NSValue_HookOfGetter(Encodename,Type,Funcname)\
\
Type Funcname##_##Encodename(_Nullable id _SELF,SEL _CMD)\
{\
    NSValue* value = Funcname(_SELF, _CMD);\
    \
    Type ret;\
    [value getValue:&ret];\
    \
    return ret;\
}

#define APCTemplate_NSNumber_HookOfGetter(Encodename,Type,Funcname,MethodPrefix)\
\
Type Funcname##_##Encodename(_Nullable id _SELF,SEL _CMD)\
{\
    return [((NSNumber*)Funcname(_SELF, _CMD)) MethodPrefix##Value];\
}


/**
 Define A : BasicValue <Funcname>_<EncodeName>(...){...}
 Define B : IMP  <Funcname>_HookIMPMapper(char* encode){...}
 */
#define APCDefBasicValueGetterVersionAndHookIMPMapper\
(NSNumberTemplate,NSValueTemplate,funcname) \
\
NSNumberTemplate(c,char,funcname,char)\
NSNumberTemplate(i,int,funcname,int)\
NSNumberTemplate(s,short,funcname,short)\
NSNumberTemplate(l,long,funcname,long)\
NSNumberTemplate(q,long long,funcname,longLong)\
NSNumberTemplate(C,unsigned char,funcname,unsignedChar)\
NSNumberTemplate(I,unsigned int,funcname,unsignedInt)\
NSNumberTemplate(S,unsigned short,funcname,unsignedShort)\
NSNumberTemplate(L,unsigned long,funcname,unsignedLong)\
NSNumberTemplate(Q,unsigned long long,funcname,unsignedLongLong)\
NSNumberTemplate(f,float,funcname,float)\
NSNumberTemplate(d,double,funcname,double)\
NSNumberTemplate(B,BOOL,funcname,bool)\
NSValueTemplate(charptr,char*,funcname)\
NSValueTemplate(class,Class,funcname)\
NSValueTemplate(sel,SEL,funcname)\
NSValueTemplate(ptr,void*,funcname)\
NSValueTemplate(rect,APCRect,funcname)\
NSValueTemplate(point,APCPoint,funcname)\
NSValueTemplate(size,APCSize,funcname)\
NSValueTemplate(range,NSRange,funcname)\
\
void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
{\
if([encodeString isEqualToString:@"c"]){\
    return (void*)funcname##_c;\
}\
else if ([encodeString isEqualToString:@"i"]){\
    return (void*)funcname##_i;\
}\
else if ([encodeString isEqualToString:@"s"]){\
    return (void*)funcname##_s;\
}\
else if ([encodeString isEqualToString:@"l"]){\
    return (void*)funcname##_l;\
}\
else if ([encodeString isEqualToString:@"q"]){\
    return (void*)funcname##_q;\
}\
else if ([encodeString isEqualToString:@"C"]){\
    return (void*)funcname##_C;\
}\
else if ([encodeString isEqualToString:@"I"]){\
    return (void*)funcname##_I;\
}\
else if ([encodeString isEqualToString:@"S"]){\
    return (void*)funcname##_S;\
}\
else if ([encodeString isEqualToString:@"L"]){\
    return (void*)funcname##_L;\
}\
else if ([encodeString isEqualToString:@"Q"]){\
    return (void*)funcname##_Q;\
}\
else if ([encodeString isEqualToString:@"f"]){\
    return (void*)funcname##_f;\
}\
else if ([encodeString isEqualToString:@"d"]){\
    return (void*)funcname##_d;\
}\
else if ([encodeString isEqualToString:@"B"]){\
    return (void*)funcname##_B;\
}\
else if ([encodeString isEqualToString:@"*"]){\
    return (void*)funcname##_charptr;\
}\
else if ([encodeString isEqualToString:@"#"]){\
    return (void*)funcname##_class;\
}\
else if ([encodeString isEqualToString:@":"]){\
    return (void*)funcname##_sel;\
}\
else if ([encodeString characterAtIndex:0] == '^'){\
    return (void*)funcname##_ptr;\
}\
else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
    return (void*)funcname##_rect;\
}\
else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
    return (void*)funcname##_point;\
}\
else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
    return (void*)funcname##_size;\
}\
else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
    return (void*)funcname##_range;\
}\
    return nil;\
}
///enc-m

#define APCTemplate_NSValue_HookOfSetter(encodename,type,funcname)\
\
void funcname##_##encodename(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    funcname(_SELF, _CMD, [NSValue valueWithBytes:&val objCType:@encode(type)]);\
}

#define APCTemplate_NSNumber_HookOfSetter(encodename,type,funcname,ftype)\
\
void funcname##_##encodename(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    funcname(_SELF, _CMD, [NSNumber numberWith##ftype:val]);\
}

#define APCDefBasicValueSetterVersionAndHookIMPMapper\
(NSNumberTemplate,NSValueTemplate,funcname) \
\
NSNumberTemplate(c,char,funcname,Char)\
NSNumberTemplate(i,int,funcname,Int)\
NSNumberTemplate(s,short,funcname,Short)\
NSNumberTemplate(l,long,funcname,Long)\
NSNumberTemplate(q,long long,funcname,LongLong)\
NSNumberTemplate(C,unsigned char,funcname,UnsignedChar)\
NSNumberTemplate(I,unsigned int,funcname,UnsignedInt)\
NSNumberTemplate(S,unsigned short,funcname,UnsignedShort)\
NSNumberTemplate(L,unsigned long,funcname,UnsignedLong)\
NSNumberTemplate(Q,unsigned long long,funcname,UnsignedLongLong)\
NSNumberTemplate(f,float,funcname,Float)\
NSNumberTemplate(d,double,funcname,Double)\
NSNumberTemplate(B,BOOL,funcname,Bool)\
NSValueTemplate(charptr,char*,funcname)\
NSValueTemplate(class,Class,funcname)\
NSValueTemplate(sel,SEL,funcname)\
NSValueTemplate(ptr,void*,funcname)\
NSValueTemplate(rect,APCRect,funcname)\
NSValueTemplate(point,APCPoint,funcname)\
NSValueTemplate(size,APCSize,funcname)\
NSValueTemplate(range,NSRange,funcname)\
\
void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
{\
    if([encodeString isEqualToString:@"c"]){\
        return (void*)funcname##_c;\
    }\
    else if ([encodeString isEqualToString:@"i"]){\
        return (void*)funcname##_i;\
    }\
    else if ([encodeString isEqualToString:@"s"]){\
        return (void*)funcname##_s;\
    }\
    else if ([encodeString isEqualToString:@"l"]){\
        return (void*)funcname##_l;\
    }\
    else if ([encodeString isEqualToString:@"q"]){\
        return (void*)funcname##_q;\
    }\
    else if ([encodeString isEqualToString:@"C"]){\
        return (void*)funcname##_C;\
    }\
    else if ([encodeString isEqualToString:@"I"]){\
        return (void*)funcname##_I;\
    }\
    else if ([encodeString isEqualToString:@"S"]){\
        return (void*)funcname##_S;\
    }\
    else if ([encodeString isEqualToString:@"L"]){\
        return (void*)funcname##_L;\
    }\
    else if ([encodeString isEqualToString:@"Q"]){\
        return (void*)funcname##_Q;\
    }\
    else if ([encodeString isEqualToString:@"f"]){\
        return (void*)funcname##_f;\
    }\
    else if ([encodeString isEqualToString:@"d"]){\
        return (void*)funcname##_d;\
    }\
    else if ([encodeString isEqualToString:@"B"]){\
        return (void*)funcname##_B;\
    }\
    else if ([encodeString isEqualToString:@"*"]){\
        return (void*)funcname##_charptr;\
    }\
    else if ([encodeString isEqualToString:@"#"]){\
        return (void*)funcname##_class;\
    }\
    else if ([encodeString isEqualToString:@":"]){\
        return (void*)funcname##_sel;\
    }\
    else if ([encodeString characterAtIndex:0] == '^'){\
        return (void*)funcname##_ptr;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
        return (void*)funcname##_rect;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
        return (void*)funcname##_point;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
        return (void*)funcname##_size;\
    }\
    else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
        return (void*)funcname##_range;\
    }\
return nil;\
}
///enc-m

#define APCTemplate_NSNumber_NullGetter(Encodename,Type,Funcname,MethodPrefix) \
\
APCTemplate_NSValue_NullGetter(Encodename,Type,Funcname)

#define APCTemplate_NSValue_NullGetter(Encodename,Type,Funcname) \
Type Funcname##_##Encodename(id _Nullable _SELF,SEL _Nonnull _CMD)\
{\
    Class cls = object_getClass(_SELF);\
    IMP imp;\
    do {\
    \
    if(nil != (imp = class_itMethodImplementation_APC(cls, _CMD)))\
        \
        if(imp != (IMP)Funcname)\
            \
            break;\
    } while ((void)(imp = nil), nil != (cls = class_getSuperclass(cls)));\
    \
    if(nil != imp){\
        \
        ((Type (*)(id,SEL))imp)(_SELF, _CMD);\
    }\
    \
    return submacro_apc_defaultvalue(Type, Encodename);\
}

#define APCTemplate_NSNumber_NullSetter(Encodename,Type,Funcname,MethodSuffix)\
\
APCTemplate_NSValue_NullSetter(Encodename,Type,Funcname)

#define APCTemplate_NSValue_NullSetter(Encodename,Type,Funcname) \
void Funcname##_##Encodename(id _Nullable _SELF,SEL _Nonnull _CMD, Type value)\
{\
    Class cls = object_getClass(_SELF);\
    IMP imp;\
    do {\
    \
    if(nil != (imp = class_itMethodImplementation_APC(cls, _CMD)))\
    \
        if(imp != (IMP)Funcname)\
            \
            break;\
    } while ((void)(imp = nil), nil != (cls = class_getSuperclass(cls)));\
    \
    if(nil != imp){\
        \
        ((void(*)(id,SEL,Type))imp)(_SELF, _CMD, value);\
    }\
}
