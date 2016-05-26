//
//  Global.h
//  Scott'sEmpire
//
//  Created by ZhiXing Li on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Define.h"
#import "mapdata.h"
#import "maps.h"
#import "JSQueue.h"
#import "GCHelper.h"

@interface Global : NSObject
{
@public 
    BOOL        m_inited;           // !=0 means game is initialized
    BOOL        m_isServer;         // if this mode is multi player mode, this player is server
    BOOL        m_isMultiPlay;      // if this game is multiMode
    unsigned char m_mapInfo[3];
    unsigned char m_cityInfo[4];
    //  About
    CCNode*     m_helpScene;
    
    //  City select
    int         m_phase;
    int         m_newPhase;
    CCNode*     m_citySelectScene;
    
    // init
    int         m_numPlayers;
    int         m_newNumPlayers;
    int         demo;
    CCNode*     m_initScene;
    
    BOOL        m_speaker;          // !=0 means sound is on
    
    double      m_scalex;           // zoom factor
    double      m_scaley;           // zome factor
    
    id          m_player;           // which player is being displayed

    loc_t       m_ulcorner;         // upper left corner
    loc_t       m_cursor;           // location of cursor
    
    int         m_offsetx;
    int         m_offsety;
    
    //client size
    int         m_cxClient;
    int         m_cyClient;
    
    // cliping rectangles
    CGRect      m_sector;
    CGRect      m_text;
    
    // Sector size
    int         m_pixelx;
    int         m_pixely;
    
    //blast
    BOOL        m_blastState;       // !=0 means draw blast
    int         m_blastX;           //location of blast
    int         m_blastY;
    
    //mapData
    
    mapdata *   m_map;
    int         m_nSelectedCityIdx;
    
    BOOL         m_visibleMap[MAPSIZE];
    unsigned char m_tempMapData[MAPSIZE];
    
    
    //display
    char        m_vbuffer[5][80 + 1];
    int         m_nCityType;
    
    id          m_GameView;

    int         m_rMoveX;
    int         m_rMoveY;
    
    int         m_Surveyloc;
    int         m_CmdMode;
    int         m_prevCmdMode;
    
    BOOL        m_bLoadFlag;
    unsigned char m_playerNum;
    
    
    int         m_nRand;
    
    int         m_nPlayerPos;
}
- (void)matchStarted;
- (void)matchEnded;
- (void)ReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
-(void)SendCmd:(unsigned char)playerNum command:(enum CmdType)cmd random:(unsigned char) rand;
-(void)SendMapInfo;
-(void)SendCityIdx;
- (void) SendExitCmd:(unsigned char)playerNum;

-(void)SendCityPhs:(unsigned char)playerNum cityIndex:(unsigned char)cityIdx cityPhase:(unsigned char)cityPhs;
-(NSArray*)GetPlayers;
-(void)SendKillUnit:(unsigned char)playerNum unitNumber:(int)unitNum;
-(void)SendMoveUnt:(unsigned char)playerNum unitType:(unsigned char)type unitLocation:(loc_t)loc mapValue:(unsigned char)ac;
-(void)SendCaptureCity:(unsigned char)playerNum location:(loc_t)loc;
@end
