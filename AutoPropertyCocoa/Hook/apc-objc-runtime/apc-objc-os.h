//
//  apc-objc-os.cpp
//  AutoPropertyCocoaiOS
//
//  Created by MDLK on 2019/5/13.
//  Copyright © 2019 Novo. All rights reserved.
//

//#include "apc-objc-os.h"


class apc_nocopy_t {
private:
    apc_nocopy_t(const apc_nocopy_t&) = delete;
    const apc_nocopy_t& operator=(const apc_nocopy_t&) = delete;
protected:
    apc_nocopy_t() { }
    ~apc_nocopy_t() { }
};
