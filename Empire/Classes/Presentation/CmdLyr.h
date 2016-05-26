//
//  CmdLyr.h
//  Empire
//
//  Created by 陈玉亮 on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCButton.h"
#import "Global.h"
#import "var.h"

@class GameView;
@interface CmdLyr : CCNode
{
    CCSprite * m_blk;
    
    CCButton * m_FromTo;
    CCButton * m_GotoCity;
    CCButton * m_20FreeMoves;
    CCButton * m_Direction;
    CCButton * m_SoundOnOff;
    CCButton * m_WakeUp;
    CCButton * m_Load;
    CCButton * m_CityProduction;
    CCButton * m_MoveRandom;
    CCButton * m_Sentry;
    CCButton * m_WakeUpAF;
    CCButton * m_Survey;
    CCButton * m_Faster;
    CCButton * m_Slower;
    
    CCButton * m_Exit;
    
    CCButton * m_Open;
    CCButton * m_Close;
    
    Global*         m_glbMembers;
    var*            m_glbVars;  
    
    float rWinScaleX;
    float rWinScaleY;
    
    BOOL   bOpen;
     BOOL   bFrom;
    BOOL    bTouchFlag ;
}

@property (nonatomic, strong) GameView* delegate;

-(void) actionFromTo:(id) sender;
-(void) actionGotoCity:(id) sender;
-(void) action20Free:(id) sender;
-(void) actionDirection:(id) sender;
-(void) actionSound:(id) sender;
- (void) actionWake:(id) sender;
- (void) actionLoad:(id) sender;
- (void) actionCityPro:(id)sender;
- (void) actionMoveRandom: (id) sender;
-(void) actionSentry:(id) sender;
-(void) actionWakeAF:(id) sender;
-(void) actionSurvey:(id) sender;
- (void) actionFaster:(id) sender;
- (void) actionSlower:(id) sender;
-(void) actionExit: (id) sender;
-(void)GiveAction:(enum CmdType)actionValue;
@end
