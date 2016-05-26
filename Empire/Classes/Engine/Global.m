//
//  Global.m
//  Scott'sEmpire
//
//  Created by ZhiXing Li on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "GameView.h"
#import "AppDelegate.h"
#import "var.h"
#import "Player.h"
#import "init.h"
#import "CmdItem.h"

#import "StartLyr.h"

@implementation Global
-(id)init
{
    if (self = [super init])
    {
        m_speaker = true;
        
        m_cxClient = 120;
        m_cyClient = 160;
        
        m_pixelx = 120;
        m_pixely = 120;
        
        m_scalex = 1;
        m_scaley = 1;
        
        m_numPlayers = 4;
        m_sector.origin.x = 0;
        m_sector.origin.y = 40;
        m_sector.size = CGSizeMake(m_pixelx, m_pixely);
        
        
        m_map = [[mapdata alloc] init];
        m_nSelectedCityIdx = 0;
        
        memset(m_visibleMap, 0, sizeof(BOOL) * 6000);
        memset(m_tempMapData, 0, sizeof(unsigned char) * 6000);
        
        m_nCityType = 0;
        m_Surveyloc = 0;
        m_CmdMode = 0;
        m_prevCmdMode = -1;
        
        m_bLoadFlag = false;
        
        m_isMultiPlay = false;
        m_isServer = false;
        memset(m_mapInfo, -1, sizeof(unsigned char) * 3);
    }
    return self;
}

-(void)dealloc
{
    [m_map release];
    [super dealloc];
}

//- (void)matchStarted
//{
//    if (m_isServer)
//    {
//        GKMatch* match = [[GCHelper sharedInstance] match];
//        NSArray* players = [self GetPlayers];
//        unsigned char sendbuf[2] = {PlayerNum, 0};
//        
//        //hb
//        m_numPlayers = players.count + 1;
//        
//        for (int i = 0; i < players.count; i++)
//        {
//            sendbuf[1] = i + 2;
//            NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:2];
//            NSArray* peer = [NSArray arrayWithObject:players];
//            [match sendData:sendBuf toPlayers:peer withDataMode:GKMatchSendDataReliable error:nil];
//        }
//        [self SendTestPacket];
//    }
//}

- (void)matchStarted
{
    
    GKMatch* match = [[GCHelper sharedInstance] match];
    
    if (m_isServer)
    {
        unsigned char sendbuf[2] = {PlayerNum, 0};
        
        for (int i = 0; i < match.playerIDs.count; i++)
        {
            sendbuf[1] = i + 2;
            NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:2];
            NSError* error;
            [match sendData:sendBuf toPlayers:[NSArray arrayWithObject:[match.playerIDs objectAtIndex:i]] withDataMode:GKMatchSendDataReliable error:&error];
        }
        m_isMultiPlay = true;
        [self StartMultiGame:(int)match.playerIDs.count + 1];
    }
    
    //hb
    m_numPlayers = (int)match.playerIDs.count + 1;
    m_nPlayerPos = m_numPlayers;
    
}

- (void) StartMultiGame:(int) m_nLevelNum
{
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    Global*         m_glbMembers;
    var*            m_glbVars;

    /////////////////////////////////////////////////////////////////////////////////////
    m_glbMembers = delegate->m_globalMembers;
    m_glbMembers->m_newNumPlayers = m_glbMembers->m_numPlayers;
    m_glbVars = delegate->m_globalVars;
    [m_glbVars init_var];
    
    m_glbMembers->m_newNumPlayers = m_nLevelNum;
    m_glbMembers->m_numPlayers = m_nLevelNum;
    [StartLyr winSetup];
    for (int i = 0; i < MAPSIZE; i++ ) {
        m_glbMembers->m_tempMapData[i] = m_glbVars->m_map[i];
    }
    GameView* gmVw = [[[GameView alloc] init] autorelease];
    CCScene* scene = [CCScene node];
    [scene addChild:gmVw];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.7f]];
    [gmVw showSelectDlg];
    
}


-(NSArray*)GetPlayers
{
    GKMatch* match = [[GCHelper sharedInstance] match];
    return [match playerIDs];
}

- (void)matchEnded
{
    
}

- (void)ReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    var* m_glbVar = delegate->m_globalVars;
    unsigned char*  receivedBuf = (unsigned char*)[data bytes];

    switch (receivedBuf[0]) {
        case PlayerNum:
        {
            m_playerNum = receivedBuf[1];
            m_isMultiPlay = true;
            m_newNumPlayers = m_numPlayers;
            break;
        }   
        case MapInfo:
        {
            memcpy(m_mapInfo, receivedBuf + 1, 3);
            break;
        }
        case CityIdx:
        {
            memcpy(m_cityInfo, receivedBuf + 1, 4);
            [self StartMultiGame:m_numPlayers];
            break;
        }
        case Command:
        {
            CmdItem * item  = [[CmdItem alloc] init];
            item->cmdType = receivedBuf[1];
            item->numPlay = receivedBuf[2];
            m_nRand = receivedBuf[3];
            m_nPlayerPos = receivedBuf[2];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveCmd" object:item];
            break;
        }
        case ExitCmd:
        {
            CmdItem * item  = [[CmdItem alloc] init];
            item->numPlay = receivedBuf[1];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePlayer" object:item];
            
            break;
        }
            
//        case CityPhase:
//        {
//            int playNum = receivedBuf[1];
//            int cityIdx = receivedBuf[2];
//            int phs = receivedBuf[3];
//            m_glbVar->m_city[cityIdx]->m_phs = phs;
//            m_glbVar->m_city[cityIdx]->m_own = playNum;
//            m_glbVar->m_city[cityIdx]->m_fnd = m_glbVar->m_typx[phs]->m_phstart;
//            break;
//        }
//        case KillUnit:
//        {
//            int playerNum = receivedBuf[1];
//            int unitNumber = *((int*)receivedBuf+2);
//            [m_glbVar->m_player[playerNum] kill:m_glbVar->m_unit[unitNumber]];
//            break;
//        }
//        case MoveUnit:
//        {
//            int playNum = receivedBuf[1];
//            int unitType = receivedBuf[2];
//            loc_t loc = *((loc_t*)receivedBuf + 3);
//            int mapValue = receivedBuf[7];
//            [m_glbVar->m_player[playNum] Change:unitType location:loc areaOrland:mapValue];
//            break;
//        }
//        case CaptureCity:
//        {
//            int playerNum = receivedBuf[1];
//            loc_t loc = *((loc_t*)receivedBuf + 2);
//            [m_glbVar->m_player[playerNum] CapturedCity:loc];
//            break;
//        }
        default:
            break;
    }
}

-(void)SendTestPacket
{
    unsigned char sendbuf[3] = {Command, 1, 1};
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:3];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SendTestPacket) userInfo:nil repeats:NO];
}

-(void)SendCmd:(unsigned char)playerNum command:(enum CmdType)cmd random:(unsigned char) rand
{
    unsigned char sendbuf[4] = {Command, playerNum, cmd, rand};
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:4];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

-(void)SendMapInfo
{
    unsigned char sendbuf[4] = {MapInfo, m_mapInfo[0], m_mapInfo[1], m_mapInfo[2]};
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:4];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

-(void)SendCityIdx
{
    unsigned char sendbuf[5] = {CityIdx, m_cityInfo[0], m_cityInfo[1], m_cityInfo[2], m_cityInfo[3] };
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:5];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

- (void) SendExitCmd:(unsigned char)playerNum
{
    unsigned char sendbuf[2] = {ExitCmd,  playerNum};
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:2];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}


-(void)SendCityPhs:(unsigned char)playerNum cityIndex:(unsigned char)cityIdx cityPhase:(unsigned char)cityPhs
{
    unsigned char sendbuf[4] = {CityPhase, playerNum, cityIdx, cityPhs};
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:4];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

-(void)SendKillUnit:(unsigned char)playerNum unitNumber:(int)unitNum
{
    unsigned char sendbuf[6] = {KillUnit, playerNum};
    memcpy(sendbuf + 2, &unitNum, sizeof(int));
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:6];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

-(void)SendMoveUnt:(unsigned char)playerNum unitType:(unsigned char)type unitLocation:(loc_t)loc mapValue:(unsigned char)ac
{
    unsigned char sendbuf[8] = {MoveUnit, playerNum, type};
    memcpy(sendbuf + 3, &loc, sizeof(loc_t));
    sendbuf[7] = ac;
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:8];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}

-(void)SendCaptureCity:(unsigned char)playerNum location:(loc_t)loc
{
    unsigned char sendbuf[6] = {CaptureCity, playerNum};
    memcpy(sendbuf, &loc, sizeof(loc_t));
    NSData* sendBuf = [NSData dataWithBytes:&sendbuf length:4];
    GKMatch* match = [[GCHelper sharedInstance] match];
    [match sendDataToAllPlayers:sendBuf withDataMode:GKMatchSendDataReliable error:nil];
}
@end
