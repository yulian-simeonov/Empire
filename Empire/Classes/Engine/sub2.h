//
//  sub2.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "empire.h"
#import "var.h"
#import "Global.h"

/*
 * Empire, the Wargame of the Century (tm)
 * Copyright (C) 1978-2004 by Walter Bright
 * All Rights Reserved
 *
 * You may use this source for personal use only. To use it commercially
 * or to distribute source or binaries of Empire, please contact
 * www.digitalmars.com.
 *
 * Written by Walter Bright.
 * This source is written in the D Programming Language.
 * See www.digitalmars.com/d/ for the D specification and compiler.
 *
 * Use entirely at your own risk. There is no warranty, expressed or implied.
 */

@interface sub2 : NSObject
{
    Global * m_glbMember;
    var *    m_globalVar;
    
}
- (int) newuni:(Unit *)pu location:(loc_t) loc intTy: (uint) ty intpn:(uint) pn;
-(City *) fndcit:(loc_t) loc;

@end
