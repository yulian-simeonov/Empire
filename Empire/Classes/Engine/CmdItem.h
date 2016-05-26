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

@interface CmdItem : NSObject
{
@public
    int cmdType;		// who owns the city, 0 if nobody
    int numPlay;		// what the city is producing
}

@end
