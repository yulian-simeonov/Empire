//
//  Display.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Define.h"
#import "Unit.h"
#import "City.h"
#import "empire.h"
#import "text.h"
#import "maps.h"
#import "Global.h"

@interface Display : NSObject
{
@public
    int m_timeinterval;	// 100ths of a second msg delay time
    uint m_maptab;	// map values for the players
    
    int m_secbas;		// position of upper left corner of sector
    uint m_Smin;		// text row,col coordinates of upper left sector display
    uint m_Smax;		// text row,col coordinates of lower right sector display
    
    text* m_text;
    maps* m_mapManager;
    Global* m_glbMember;
    var *   m_globalVar;
}

-(void) clrsec;
-(void) mapprt:(loc_t) loc;
-(int) insect:(loc_t) loc location:(uint) n;
-(loc_t) adjust:(loc_t) loc;
-(void) initialize;
-(int) rusure;
-(void) your;
-(void) enemy;
-(void) city_attackown;
-(void) city_repelled:(loc_t) loc;
-(void) city_conquered:(loc_t) loc;
-(void) city_subjugated;
-(void) city_crushed;
-(void) killml:(int) type number:(int) num;
-(void) overloaded:(loc_t) loc type:(int) typabd number:(int) numdes;
-(void)  headng:(Unit *)u;
-(NSString *) nmes_p:(int) type number:(int) num;
-(void) landing:(Unit *)u;
-(void) boarding:(Unit *)u;
-(void) aground:(Unit *)u;
-(void) armdes:(Unit *)u;
-(void) drown:(Unit *)u;
-(void) shot_down:(Unit *)u;
-(void) no_fuel:(Unit *)u;
-(void) docking:(Unit *)u location:(loc_t) loc;
-(void) underattack:(Unit *)u;
-(void) battle:(id)p winner:(Unit *)uwin loser:(Unit *)ulos;
-(NSString *) youene_p:(id)p number:(int) num;
-(void) plyrcrushed:(id)pdef;
-(void) lost;
-(void) produce:(City *)c;
-(void) overpop:(int) flag;
-(void) fncprt:(Unit *)u;
-(void) setdispsize:(int)rows col:(int) cols;
-(void) pcur:(loc_t) loc;
-(void) remove_sticky;
-(void) valcmd:(int) mode;
-(void) cityProdDemands;
-(void) delay:(int) n;
-(void) wakeup;

-(void)typcit:(id)p city:(City*)c;
-(void)savgam;
-(void)lstvar;


@end
