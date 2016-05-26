//
//  Player.h
//  Scott'sEmpire
//
//  Created by ZhiXing Li on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

#import "AppDelegate.h"
#import "Display.h"
#import "Unit.h"
#import "maps.h"
#import "City.h"
#import "var.h"
#import "move.h"
#import "empire.h"
#import "path.h"
#import "sub2.h"
#import "Global.h"
#import "GameViewDelegate.h"


enum PlayerType
{
    Computer, Human, NetUser
};

@interface Player : NSObject
{
@public
    uint                m_num;                      // player number(1 . . numply)
    uint                m_round;                    // round number
    enum PlayerType     m_playerType;      
    bool                m_watch;                    // display attribute DAxxxx if non-zero
    BOOL                 m_movedone;                 // !=0 if we moved the piece this turn
    
    int                 m_uninum;                   // what unit number we're on
    BOOL                m_secflg;                   // if next unit has to be in the current sector
    ushort              m_defeat;                   // true if player is defeated
    
    int                 m_turns;                    // number of turns completed
    
    // Human Player
    int                 m_mode;                     // mdXXXX: input modes
    loc_t               m_curloc;                   // current location of cursor
    int                 m_frmloc;                   // use when in TO mode
    int                 m_maxrng;
    int                 m_citnum;
    int                 m_savmod;
    int                 m_nrdy;                     // true if we're not ready
    int                 m_modsave;
    
    // computer strategy
    ushort              m_target[CITMAX];           // There is a TARGET byte for each city.
                                                    // If the computer knows about the city bue doesn't own it, it is true
    
    uint                m_troopt[6][5];             // The 6 rows correspond to the ships
                                                    // DTSRCP in that order. The 5 columns
                                                    // correspond to locations of enemy ships
                                                    // discovered, in order from newest to
                                                    // oldest sighting.
    
    uint                m_loci[LOCMAX];             // locations of enemy armies sighted from most to least recent
    uint                m_numuni[TYPMAX];           // # of units of each type
    uint                m_numown;                   // # of our owned cities
    uint                m_numtar;                   // # of cities listed as targets
    uint                m_numphs[TYPMAX];           // # of cities producing each type of unit
    
    var*                m_globalVar;
    Global*             m_glbMembers;
    move*               m_move;
    empire*             m_empire;
    sub2*               m_sub;
    maps*               m_mapManager;
    JSQueue*            m_cmdQueue;
    unsigned char*      m_map;
    Display*            m_display;
    Unit*               m_usv;                      // current unit
    id<GameViewDelegate>        delegate;
    
    
    BOOL                m_bMoved; //hb
}

@property (nonatomic, retain) id<GameViewDelegate>  delegate;

+(Player*)Get:(int)num;
-(void)Save:(FILE*)fp;
-(void)Load:(FILE*)fp;
-(void)Tslice;
-(void)Finrnd;
-(int)Mmove:(Unit*)u;
-(BOOL)Evalu8:(Unit*)u diret:(int)r2;
-(void)Attcit:(loc_t)loc;
-(void)CapturedCity:(loc_t)loc;
-(void)Sector:(int)loc;
-(void)Sensor:(loc_t)loc;
-(void)Center:(int)loc;
-(int)Citsel:(int)cityIdx;

/* =============================Human strategy=========================================*/
-(BOOL)Hmove:(Unit*)u direction:(int*)pr2;
-(BOOL)Nmove:(Unit*)u direction:(int*)pr2;
-(void)MoveFromTo:(Unit*)u;
-(BOOL)GotoNearestCity:(Unit*)u;
-(void)AwakeUnit:(Unit*)u;
-(BOOL)LoadUnits:(Unit*)u;
-(void)EnterNewCity;
-(BOOL)ConfirmFromToMove:(Unit*)u;
-(void)AboardUnits:(Unit*)u;
-(BOOL)mycmod:(Unit*)u ifo:(int)fo ila:(int)la;
-(BOOL)Valid:(Unit*)u;
-(BOOL)Cittst;
-(void)SetMode:(int)newMode;
-(void)CmdError;
-(void)TypHdg;
-(void)ChkSleep:(Unit*)u direction:(int)r2;
-(BOOL)RuSure;
-(BOOL)Seeifok:(Unit*)u direction:(int)r2;
-(BOOL)MyCode:(Unit*)u direction:(int*)pr2;
-(BOOL)OkMove:(Unit*)u direction:(int)r2;
-(void)Phasin:(City*)c;
-(BOOL)Tltr:(int)loc direction:(int*)pr2;
-(BOOL)Eneltr:(int)loc;
-(BOOL)Citltr:(int)loc direction:(int*)pr2;
-(BOOL)CMove:(Unit*)u direction:(int*)pr2;
-(BOOL)iFoeva:(Unit*)u;
-(BOOL)ifo_gotoT:(Unit*)u;
-(BOOL)ifo2:(Unit*)u;
-(BOOL)ifo3:(Unit*)u;
-(BOOL)ifo6:(Unit*)u;
-(BOOL)ifo_city:(Unit*)u;
-(BOOL)ifo8:(Unit*)u;
-(BOOL)ifo9:(Unit*)u;
-(BOOL)ifo10:(Unit*)u;
-(BOOL)ifo11:(Unit*)u;
-(BOOL)ifo13:(Unit*)u;
-(BOOL)ifo14:(Unit*)u;
-(BOOL)ifo15:(Unit*)u;
-(void)NewIfo:(Unit*)u;
-(int)Movsel:(Unit*)u;
-(int)Selfol:(Unit*)u;
-(int)Seldir:(Unit*)u;
-(int)Seluni:(Unit*)u;
-(int)Selloc:(Unit*)u;
-(int)Locs:(Unit*)u location:(int)toloc;
-(void)Movcor:(Unit*)u direction:(int*)pr2;
-(int)Explor:(Unit*)u direction:(int*)pr2;
-(int)Expshp;
-(void)Arrloc:(int)loc;
-(BOOL)Eneatt:(Unit*)u direction:(int*)pr2 mask:(int)msk;
-(BOOL)Around:(Unit*)u direction:(int*)pr2;
-(void)ARMYif:(Unit*)u;
-(void)ARMYco:(Unit*)u direction:(int*)pr2;
-(BOOL)Armtar:(Unit*)u;
-(BOOL)Armloc:(Unit*)u;
-(BOOL)Armtt:(Unit*)u;
-(void)FIGHif:(Unit*)u;
-(BOOL)Gocit:(Unit*)u;
-(BOOL)Gocar:(Unit*)u;
-(BOOL)Figtar:(Unit*)u;
-(void)FIGHco:(Unit*)u direction:(int*)pr2;
-(void)TROOif:(Unit*)u;
-(void)SHIPif:(Unit*)u;
-(void)CARRif:(Unit*)u;
//-(void)SHIPco:(Unit*)u;
-(bool)Port:(Unit*)u;
-(BOOL)Armcit:(Unit*)u;
-(BOOL)Trotar:(Unit*)u lookAll:(BOOL)flag;
-(BOOL)Shipta:(Unit*)u;
-(BOOL)Shiptt:(Unit*)u;
-(BOOL)Shiptr:(Unit*)u;
-(BOOL)Lodarm:(Unit*)u direction:(int*)pr2;
-(void)Cwatch;
-(void)Cityct;
-(void)CPhasin:(City*)c;
-(void)Cityph;
-(int)Nearct:(int)loc;
-(void)Island:(City*)c;
-(void)Selshp:(City*)c;
-(BOOL)Ckloci:(City*)c;
-(BOOL)Makfs:(City*)c location:(int)crowd edge:(int)edg;
-(void)Updcmp:(int)loc;
-(void)Threat:(int)loc;
-(void)Updloc:(int)loc;
-(void)Updtro:(int)loc type:(uint)ty;
-(BOOL)Patblk:(loc_t)beg to:(loc_t)end;
-(BOOL)Patcnt:(loc_t)beg to:(loc_t)end;
-(BOOL)Patlnd:(loc_t)beg to:(loc_t)end;
-(BOOL)Patsea:(loc_t)beg to:(loc_t)end;
-(BOOL)Patho:(loc_t)beg to:(loc_t)end direction:(int)dir state:(Byte*)ok sndDirection:(dir_t*)pr2;
-(BOOL)Pathn:(loc_t)beg to:(loc_t)end direction:(int)dir state:(Byte*)ok sndDirection:(dir_t*)pr2;
-(void)Notify_destory:(Unit*)u;
-(void)Notify_round:(Player*)p round:(int)r;
-(void)Notify_defeated:(Player*)p;
-(void)Notify_city_lost:(City*)c;
-(void)Notify_city_won:(City*)c;
-(void)Notify_city_repelled:(City*)c;
-(void)Drag:(Unit*)u;
-(void)Eomove:(int)loc;
-(void)Change:(uint)type location:(loc_t)loc areaOrland:(uint)ac;
-(void)Killit:(Unit*)u;
-(BOOL)Fight:(Unit*)u location:(int)loc;
-(BOOL)Cmdcur:(int*)ploc command:(uint)cmd direction:(int*)pr2;
-(Player*)nextp;
-(void)Exchange_display:(Player*)p;
-(void)Repaint;
@end
