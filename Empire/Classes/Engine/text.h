//
//  text.h
//  Empire
//
//  Created by 陈玉亮 on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
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

#import <Foundation/Foundation.h>
#import "empire.h"
#import "Global.h"


@interface text : NSObject
{
    
    int VBUFROWS;
    int VBUFCOLS;
    char m_vbuffer[5][80 + 1];
    Global*    m_glbMember;
    // For each text mode display, which can be either a tty or the
    // PC screen in text mode.
    
    @public
    BOOL m_watch;		// display attribute DAxxxx if non-zero
    int m_TTtyp;			// terminal type
    int m_cursor;		// current cursor position
    int m_Tmax;			// terminal max display size
    int m_speaker;		// speaker on?
    int m_narrow;		// true if narrow screen
    int m_nrows;			// total number of rows in display
    int m_ncols;			// total number of columns in display
    int m_inbuf;			// -1 if empty, otherwise next character to be read
    int m_anychanges;		// !=0 if any changes since last flush()
}

- (void) deleol;
- (void) deleos;
-(void) block_cursor;
- (void) clear;
-(void) TTout:(char) c;
-(int) TTin;
-(int) TTinr;
-(void) TTunget:(int) c;
-(void) TTcurs:(unsigned int) rc;
-(void) curs:(int) rc;
-(void) bell;
-(void) output:(char) chr;
-(void) decprt:(int) i;
-(void) imes:(NSString*) p;
-(void) smes:(NSString*)p;
- (void) vsmes:(NSString*) str;
-(void) cmes:(int) rc type:(NSString *)p;
-(void) TTinit;
-(void) TTdone;
-(void) locprt:(loc_t) loc;
-(void) locdot:(loc_t) loc;
-(void) space;
-(void) crlf;
-(void) put:(unsigned int) rc val :(unsigned int) value;
-(void) flush;
-(int) DS:(int) row;
-(void) speaker_click;

@end
