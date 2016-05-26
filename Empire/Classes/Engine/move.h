//
//  move.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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
#import "empire.h"
#import "sub2.h"
#import "Global.h"
#import "var.h"
#import "maps.h"

#define  HYSTERESIS 10

@interface move : NSObject
{
    Global * m_glbMember;
    var *    m_globalVar;
    maps*    m_MapManager;
}

-(int) slice;
-(void) hrdprd:(id)p;
-(void) chkwin;
-(void) done:(int) i;
-(void) updlst:(loc_t) loc type:(int)type;		// update map value at loc
-(int) updmap:(loc_t) loc;
-(Unit *)fnduni:(loc_t) loc;
-(void) kill:(Unit *)u;
-(int)Randir;
-(BOOL)Fndtar:(Unit*)u location:(uint*)p entryNum:(uint)n;
-(BOOL)Sursea:(Unit*)u;
-(BOOL)Full:(Unit*)u;
-(BOOL)Ecrowd:(loc_t)loc;
@end
