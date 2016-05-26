//
//  path.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "empire.h"
#import "Define.h"
#import "Global.h"
#import "var.h"

static Byte okblk[MAPMAX] = {1,0,0,1,0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0};

static Byte okcnt[MAPMAX] = {0,0,0,1,1,1,1,0,0,0,0,0,0,0,
                     1,1,1,0,0,0,0,0,0,0,
                     1,1,1,0,0,0,0,0,0,0,
                     1,1,1,0,0,0,0,0,0,0,
                    1,1,1,0,0,0,0,0,0,0};

static Byte oklnd[MAPMAX] = {0,0,0,1,0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                     0,1,1,0,0,0,0,0,0,0,
                    0,1,1,0,0,0,0,0,0,0};
    
static Byte oksea[MAPMAX] = {1,0,1,0,0,0,0,1,0,0,0,0,0,0,
                     0,0,0,1,0,0,0,0,0,0,
                     0,0,0,1,0,0,0,0,0,0,
                     0,0,0,1,0,0,0,0,0,0,
                    0,0,0,1,0,0,0,0,0,0};


@interface path : NSObject
{

}

+(int) path:(id)player locationStart :(loc_t)beg locationEnd:(loc_t)end direction:(int)dir mapValueAry:(Byte*)ok
    initMoveDir:(dir_t*)pr2 optimize:(BOOL)opt;

+(void) dotblinit;

+(BOOL) mapinm:(unsigned char*)ok map:(unsigned char*)mapb location:(loc_t)loc endLocation:(loc_t)end;


+(BOOL)armap:(int*)loc currentLoc:(int)curloc trialMoveDirection:(int)trymov
 mapValueAry:(unsigned char*)ok map:(unsigned char*)mapb endLocation:(loc_t)end;

+(BOOL)armain:(int*)loc currentLoc:(int)curloc trialMoveDirection:(int*)trymov 
  mapValueAry:(unsigned char*)ok map:(unsigned char*)mapb endLocation:(loc_t)end;
@end
