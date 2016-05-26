//
//  City.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import <stdio.h>

@interface City : NSObject
{
@public
    int m_own;		// who owns the city, 0 if nobody
    int m_phs;		// what the city is producing
    loc_t m_loc;		// city location, or 0
    int m_fnd;		// completion round number
    int m_num;      // city num;
    // Human strategy
    loc_t m_fipath;	// where to send fighter
    
    // Computer strategy
    int m_round;		// turn it was captured
}

-(void)Save:(FILE*)fp;
-(void)Load:(FILE*)fp;
@end
