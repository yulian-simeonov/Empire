//
//  Define.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Define : NSObject

typedef int dir_t;
typedef int loc_t;
enum CmdType
{
//    Right, LeftBottom, Bottom, RightBottom, Left, RightTop ,Top, LeftTop
    Right,RightBottom, Bottom, LeftBottom, Left, LeftTop,Top, RightTop , Skip,
    FromTo, GotoCity, TwentyFree, Direction, SoundControl, Wake, Load, 
    CityPro, MoveRandom, Sentry, WakeAF, Survey, FromToOk, Save
};
@end

///////////////////////////////////////Communcation Protocol/////////////////////////////////////////
#define Command         0
#define PlayerNum       1
#define CityIdx         2
#define CityPhase       3
#define MapInfo         4
#define KillUnit        5
#define MoveUnit        6
#define CaptureCity     7

#define ExitCmd         8


/////////////////////////////////////////////////////////////////////////////////////////////////////

