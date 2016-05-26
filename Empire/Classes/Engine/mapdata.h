//
//  mapdata.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "empire.h"

//const int mapdata[][] =
//{
// aDotMap,
// bDotMap,
// cDotMap,
// dDotMap,
// eDotMap,
//};



@interface mapdata : NSObject
{
@public    
    unsigned char m_mapData[5][MAPSIZE];
}

@end
