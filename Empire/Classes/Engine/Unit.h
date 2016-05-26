//
//  Unit.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

@interface Unit : NSObject
{
@public
    loc_t m_loc;                // location
    unsigned char m_own;		// owner
    unsigned char m_typ;		// type A..B
    unsigned char m_ifo;		// IFOxxxx ifo of unit function
    unsigned int m_ila;         // ila of unit function
    unsigned char m_hit;		// hits left, fuel left for fighter
    unsigned char m_mov;		// !=0 if unit has moved this turn
    int           m_num;        // unit number

    // Human strategy

    // Computer strategy
    unsigned int m_abd;		// T,C: number of As (Fs) aboard (0 if not T (C))
    int m_dir;		// direction (1 or -1)
    int m_fuel;		// F:range used for strategy selection
}
-(void) destroy;	// destroy the unit
-(void)Save:(FILE*)fp;
-(void)Load:(FILE*)fp;
@end
