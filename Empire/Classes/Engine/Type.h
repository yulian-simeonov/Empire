//
//  Type.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Type : NSObject
{
    @public
    int m_prodtime;	// production times
    int m_phstart;	// starting production times
    char m_unichr;	// character representation for city phase purposes
    int m_hittab;		// hits left (value for F is fuel, for A is 0
    // for computer strategy)
}

@end
