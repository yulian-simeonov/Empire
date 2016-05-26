//
//  maps.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "empire.h"

#import "var.h"

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
@interface maps : NSObject
{
    id m_glbMembers;
    var*    m_glbVars;
}

- (int) aboard :(Unit*)u;
-(int) tcaf:(Unit *)u;
-(int) dist:(loc_t) loc1 location:(loc_t) loc2;
-(int) movdir:(loc_t) loc1 location: (loc_t) loc2;
-(int) border:(loc_t) loc;
-(int) rowcol:(loc_t) loc;
-(int) edger:(loc_t) loc;
-(int) chkloc:(loc_t) loc;
-(void) chkmov:(dir_t) r2 error: (int) errnum;
-(int) max:(int) a b: (int) b;
-(int) abs:(int) a;
-(int) edger:(loc_t) loc;
@end
