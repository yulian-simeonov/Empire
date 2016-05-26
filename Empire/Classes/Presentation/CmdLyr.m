//
//  CmdLyr.m
//  Empire
//
//  Created by 陈玉亮 on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CmdLyr.h"
#import "AppDelegate.h"
#import "Player.h"
#import "GameView.h"

@implementation CmdLyr

+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[CmdLyr node]];
    return scene;
}

-(void)dealloc
{
    
    [super dealloc];
}

- (id) init
{
    if ((self = [super init])) 
	{
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        rWinScaleX = delegate->winScaleX;
        rWinScaleY = delegate->winScaleY;
        
        [self setUserInteractionEnabled:YES];
        m_glbMembers = delegate->m_globalMembers;
        m_glbVars = delegate->m_globalVars;
        
        m_blk = [CCSprite spriteWithImageNamed:[self ResourceName:@"cmd_select_panel"]];
        [m_blk setPosition: ccp( 240 * rWinScaleX, 322 * rWinScaleY - m_blk.contentSize.height/2)];
        [self addChild: m_blk];
        
        float rLineY = 25 * rWinScaleY;
        float rLineX = 7 * rWinScaleX;
        
        float rBaseY = 320 * rWinScaleY;
        float rBaseX = rLineX;
        
        CCSprite * m_FromNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_from_to"]];
        CCSprite * m_FromSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_from_to_pressed"]];
        CCSprite * m_FromVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_from_to_pressed"]];
        
        m_FromTo = [CCButton buttonWithTitle:nil spriteFrame:m_FromNormal.spriteFrame highlightedSpriteFrame:m_FromSelect.spriteFrame disabledSpriteFrame:m_FromVal.spriteFrame];
        [m_FromTo setTarget:self selector:@selector(actionFromTo:)];
        
        rBaseX += rLineX + m_FromTo.contentSize.width / 2;
        
        [m_FromTo setPosition:ccp( rBaseX, rBaseY - rLineY )];
      
        CCSprite * m_GotoNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_goto_city"]];
        CCSprite * m_GotoSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_goto_city_pressed"]];
        CCSprite * m_GotoVal = [CCSprite  spriteWithImageNamed: [self ResourceName:@"btn_goto_city_pressed"]];
        
        m_GotoCity = [CCButton buttonWithTitle:nil spriteFrame:m_GotoNormal.spriteFrame highlightedSpriteFrame:m_GotoSelect.spriteFrame disabledSpriteFrame:m_GotoVal.spriteFrame];
        [m_GotoCity setTarget:self selector:@selector(actionGotoCity:)];
        
        [m_GotoCity setPosition:ccp( rBaseX, rBaseY - 2 * rLineY)];
        
        CCSprite * m_20FreeNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_free_move"]];
        CCSprite * m_20FreeSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_free_move_pressed"]];
        CCSprite * m_20FreeVal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_free_move_pressed"]];

        m_20FreeMoves = [CCButton buttonWithTitle:nil spriteFrame:m_20FreeNormal.spriteFrame highlightedSpriteFrame:m_20FreeSelect.spriteFrame disabledSpriteFrame:m_20FreeVal.spriteFrame];
        [m_20FreeMoves setTarget:self selector:@selector(action20Free:)];
        
        [m_20FreeMoves setPosition:ccp( rBaseX, rBaseY - 3 * rLineY)];
        
        
        CCSprite * m_DirNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_direction"]];
        CCSprite * m_DirSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_direction_pressed"]];
        CCSprite * m_DirVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_direction_pressed"]];
        
        m_Direction = [CCButton buttonWithTitle:nil spriteFrame:m_DirNormal.spriteFrame highlightedSpriteFrame:m_DirSelect.spriteFrame disabledSpriteFrame:m_DirVal.spriteFrame];
        [m_Direction setTarget:self selector:@selector(actionDirection:)];
        rBaseX += m_Direction.contentSize.width ;
        
        [m_Direction setPosition:ccp( rBaseX , rBaseY - rLineY)];
        
        CCSprite * m_SoundNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_sound_on_off"]];
        CCSprite * m_SoundSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_sound_on_off_pressed"]];
        CCSprite * m_SoundVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_sound_on_off_pressed"]];
        
        m_SoundOnOff = [CCButton buttonWithTitle:nil spriteFrame:m_SoundNormal.spriteFrame highlightedSpriteFrame:m_SoundSelect.spriteFrame disabledSpriteFrame:m_SoundVal.spriteFrame];
        [m_SoundOnOff setTarget:self selector:@selector(actionSound:)];
        [m_SoundOnOff setPosition:ccp( rBaseX, rBaseY - 2 * rLineY)];
        
               
        CCSprite * m_WakeNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_wake_up"]];
        CCSprite * m_WakeSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_wake_up_pressed"]];
        CCSprite * m_WakeVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_wake_up_pressed"]];
        
        m_WakeUp = [CCButton buttonWithTitle:nil spriteFrame:m_WakeNormal.spriteFrame highlightedSpriteFrame:m_WakeSelect.spriteFrame disabledSpriteFrame:m_WakeVal.spriteFrame];
        [m_WakeUp setTarget:self selector:@selector(actionWake:)];
        [m_WakeUp setPosition:ccp( rBaseX , rBaseY - 3 * rLineY)];
        
        CCSprite * m_LoadNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_load_unit"]];
        CCSprite * m_LoadSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_load_unit_pressed"]];
        CCSprite * m_LoadVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_load_unit_pressed"]];
        
        m_Load = [CCButton buttonWithTitle:nil spriteFrame:m_LoadNormal.spriteFrame highlightedSpriteFrame:m_LoadSelect.spriteFrame disabledSpriteFrame:m_LoadVal.spriteFrame];
        [m_Load setTarget:self selector:@selector(actionLoad:)];
        rBaseX += m_Load.contentSize.width;
        [m_Load setPosition:ccp( rBaseX, rBaseY -  rLineY )];
        
        
        CCSprite * m_CityProNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_city_production"]];
        CCSprite * m_CityProSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_city_production_pressed"]];
        CCSprite * m_CityProVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_city_production_pressed"]];
        
        m_CityProduction = [CCButton buttonWithTitle:nil spriteFrame:m_CityProNormal.spriteFrame highlightedSpriteFrame:m_CityProSelect.spriteFrame disabledSpriteFrame:m_CityProVal.spriteFrame];
        [m_CityProduction setTarget:self selector:@selector(actionCityPro:)];
        [m_CityProduction setPosition:ccp( rBaseX, rBaseY - 2 * rLineY )];
        
        CCSprite * m_MoveNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_move_randomly"]];
        CCSprite * m_MoveSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_move_randomly_pressed"]];
        CCSprite * m_MoveVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_move_randomly_pressed"]];
        
        m_MoveRandom = [CCButton buttonWithTitle:nil spriteFrame:m_MoveNormal.spriteFrame highlightedSpriteFrame:m_MoveSelect.spriteFrame disabledSpriteFrame:m_MoveVal.spriteFrame];
        [m_MoveRandom setTarget:self selector:@selector(actionMoveRandom:)];
        [m_MoveRandom setPosition:ccp( rBaseX , rBaseY - 3 * rLineY )];
        
        
        CCSprite * m_SentryNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_sentry"]];
        CCSprite * m_SentrySelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_sentry_pressed"]];
        CCSprite * m_SentryVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_sentry_pressed"]];
       
        m_Sentry = [CCButton buttonWithTitle:nil spriteFrame:m_SentryNormal.spriteFrame highlightedSpriteFrame:m_SentrySelect.spriteFrame disabledSpriteFrame:m_SentryVal.spriteFrame];
        [m_Sentry setTarget:self selector:@selector(actionSentry:)];
        rBaseX += m_Sentry.contentSize.width;
        [m_Sentry setPosition: ccp( rBaseX, rBaseY -  rLineY)];
        
        
        CCSprite * m_WakeAFNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_wake_up_all"]];
        CCSprite * m_WakeAFSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_wake_up_all_pressed"]];
        CCSprite * m_WakeAFVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_wake_up_all_pressed"]];
        
        m_WakeUpAF = [CCButton buttonWithTitle:nil spriteFrame:m_WakeAFNormal.spriteFrame highlightedSpriteFrame:m_WakeAFSelect.spriteFrame disabledSpriteFrame:m_WakeAFVal.spriteFrame];
        [m_WakeUpAF setTarget:self selector:@selector(actionWakeAF:)];
        
        [m_WakeUpAF setPosition:ccp( rBaseX, rBaseY - 2 * rLineY)];
        
        
        CCSprite * m_SurveyNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_survey"]];
        CCSprite * m_SurveySelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_survey_pressed"]];
        CCSprite * m_SurveyVal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_survey_pressed"]];
        
        m_Survey = [CCButton buttonWithTitle:nil spriteFrame:m_SurveyNormal.spriteFrame highlightedSpriteFrame:m_SurveySelect.spriteFrame disabledSpriteFrame:m_SurveyVal.spriteFrame];
        [m_Survey setTarget:self selector:@selector(actionSurvey:)];
        [m_Survey setPosition:ccp( rBaseX, rBaseY - 3 * rLineY)];

        CCSprite * m_SaveNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_save_game"]];
        CCSprite * m_SaveSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_save_game_pressed"]];
        CCSprite * m_SaveVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_save_game_pressed"]];
        
        m_Faster = [CCButton buttonWithTitle:nil spriteFrame:m_SaveNormal.spriteFrame highlightedSpriteFrame:m_SaveSelect.spriteFrame disabledSpriteFrame:m_SaveVal.spriteFrame];
        [m_Faster setTarget:self selector:@selector(actionFaster:)];
        
        rBaseX += m_Faster.contentSize.width;
        [m_Faster setPosition:ccp( rBaseX, rBaseY - rLineY)];

        
//        CCSprite *  m_SlowerNormal = [CCSprite spriteWithFile:[self ResourceName:@"btn_exit"]];
//        CCSprite * m_SlowerSelect = [CCSprite spriteWithFile:[self ResourceName:@"btn_exit_pressed"]];
//        CCSprite * m_SlowerVal = [CCSprite spriteWithFile: [self ResourceName:@"btn_exit_pressed"]];
//        
//        m_Slower = [CCMenuItemSprite itemFromNormalSprite:m_SlowerNormal 
//                                           selectedSprite:m_SlowerSelect disabledSprite:m_SlowerVal 
//                                                   target:self selector:@selector(actionSlower:)];
//        [m_Slower setPosition:ccp( 360* rWinScaleX, 320 * rWinScaleY - 6 * rLine)];
//        [m_Slower setScaleY:0.5f];
        
        
        
        CCSprite * m_ExitNormal = [ CCSprite spriteWithImageNamed:[self ResourceName:@"btn_exit"]];
        CCSprite * m_ExitSel = [ CCSprite spriteWithImageNamed:[self ResourceName:@"btn_exit_pressed"]];
        CCSprite * m_ExitVal = [ CCSprite spriteWithImageNamed: [self ResourceName:@"btn_exit_pressed"] ];

        m_Exit = [CCButton buttonWithTitle:nil spriteFrame:m_ExitNormal.spriteFrame highlightedSpriteFrame:m_ExitSel.spriteFrame disabledSpriteFrame:m_ExitVal.spriteFrame];
        [m_Exit setTarget:self selector:@selector(actionExit:)];
        
        [m_Exit setPosition:ccp( rBaseX , rBaseY - 3 * rLineY)];

        CCSprite * m_OpenNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_down"]];
        CCSprite * m_OpenSel =  [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_down"]];
        CCSprite * m_OpenVal =  [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_down"]];
        
        m_Open = [CCButton buttonWithTitle:nil spriteFrame:m_OpenNormal.spriteFrame highlightedSpriteFrame:m_OpenSel.spriteFrame disabledSpriteFrame:m_OpenVal.spriteFrame];
        [m_Open setTarget:self selector:@selector(actionOpen:)];
        
        [m_Open setPosition: ccp( 240 * rWinScaleX, m_blk.position.y - m_blk.contentSize.height/2 + 8 * rWinScaleY )];
        
        CCSprite * m_CloseNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_up"]];
        CCSprite * m_CloseSel =  [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_up"]];
        CCSprite * m_CloseVal =  [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow_up"]];
        
        m_Close = [CCButton buttonWithTitle:nil spriteFrame:m_CloseNormal.spriteFrame highlightedSpriteFrame:m_CloseSel.spriteFrame disabledSpriteFrame:m_CloseVal.spriteFrame];
        [m_Close setTarget:self selector:@selector(actionOpen:)];
        
        [m_Close setPosition: ccp( 240 * rWinScaleX, m_blk.position.y - m_blk.contentSize.height/2 + 8 * rWinScaleY )];
        [m_Close setVisible: false];
        
        [self addChild:m_FromTo];
        [self addChild:m_GotoCity];
        [self addChild:m_20FreeMoves];
        [self addChild:m_Direction];
        [self addChild:m_SoundOnOff];
        [self addChild:m_WakeUp];
        [self addChild:m_Load];
        [self addChild:m_CityProduction];
        [self addChild:m_MoveRandom];
        [self addChild:m_Sentry];
        [self addChild:m_WakeUpAF];
        [self addChild:m_Survey];
        [self addChild:m_Faster];
        [self addChild:m_Exit];
        [self addChild:m_Open];
        [self addChild:m_Close];
        
        bOpen = true;
        bFrom = true;
        bTouchFlag = false;
    }
    return  self;
}

-(void) actionOpen: (id) sender
{
    if( bOpen )
    {
        [m_Open setVisible:false];
        [m_Close setVisible:true];
        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 0 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
    }
    else {
        [m_Open setVisible:true];
        [m_Close setVisible:false];

        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
        
    }
    bOpen = !bOpen;
}

-(void) actionClose: (id) sender
{
    
}

-(void) actionFromTo:(id) sender
{
    Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
    if ( ply->m_mode == mdTO ) {
        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
        Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
        ply->m_mode = mdMOVE;
        m_glbMembers->m_CmdMode = mdMOVE;
        bOpen = !bOpen;
    }
    else
    {
         id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
   if( bFrom )
    {
        [self GiveAction:FromTo];
    //    ply->m_mode = mdTO;
        m_glbMembers->m_CmdMode = mdTO;
    }
    else {
        [self GiveAction:FromToOk];
        m_glbMembers->m_CmdMode = mdMOVE;
    }

    bFrom = !bFrom;
    }
    
    bOpen = !bOpen;
}

-(void) actionGotoCity:(id) sender
{
   id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:GotoCity];
    bOpen = !bOpen;
}

-(void) action20Free:(id) sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:TwentyFree];
    bOpen = !bOpen;
}

-(void) actionDirection:(id) sender
{
    Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
    if ( ply->m_mode == mdDIR ) {
        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
        Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
        ply->m_mode = mdMOVE;
        m_glbMembers->m_CmdMode = mdMOVE;
        bOpen = !bOpen;
    }
    else
    {
         id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];  
        m_glbMembers->m_CmdMode = mdDIR;
    }
    bOpen = !bOpen;
}
-(void) actionSound:(id) sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:SoundControl];
    bOpen = !bOpen;
}
- (void) actionWake:(id) sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:Wake];
    bOpen = !bOpen;
}
- (void) actionLoad:(id) sender
{
     id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:Load];
    bOpen = !bOpen;
}
- (void) actionCityPro:(id)sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:CityPro];
    bOpen = !bOpen;
}
- (void) actionMoveRandom: (id) sender
{
     id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:MoveRandom];
    bOpen = !bOpen;
}
-(void) actionSentry:(id) sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:Sentry];
    bOpen = !bOpen;
}
-(void) actionWakeAF:(id) sender
{
     id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    [self GiveAction:WakeAF];
    bOpen = !bOpen;
}
-(void) actionSurvey:(id) sender
{
    Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
    if ( ply->m_mode == mdSURV ) {
        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
        Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
        ply->m_mode = mdMOVE;
        m_glbMembers->m_CmdMode = mdMOVE;
        bOpen = !bOpen;
    }
    else
    {
        id action = [CCActionSequence actions:
                     [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                     nil];
        [self runAction:action];
        [self GiveAction:Survey];
        
        Player* player = m_glbVars->m_player[m_glbMembers->m_playerNum];
        m_glbMembers->m_Surveyloc = player->m_curloc;
     //   player->m_mode = mdSURV;
        m_glbMembers->m_CmdMode = mdSURV;
    }
    bOpen = !bOpen;
}

- (void) actionFaster:(id) sender
{
     [self GiveAction:Save];
    self.userInteractionEnabled = false;
   id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    bOpen = !bOpen;
 }

- (void) actionSlower:(id) sender
{
   [self GiveAction:FromToOk];
   id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];
    bOpen = !bOpen;
}

-(void) actionExit: (id) sender
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * rWinScaleX, 100 * rWinScaleY )] period:0.5f],
                 nil];
    [self runAction:action];

    [_delegate GoMainMenu];
    bOpen = !bOpen;
}

-(void)GiveAction:(enum CmdType)actionValue
{
    for ( int i = 0; i <= m_glbVars->m_numply; i++ ) 
    {
        Player *p = (Player*)(m_glbVars->m_player[i]);
        if( p->m_playerType == Human)
        {
            [p->m_cmdQueue enqueue:[NSNumber numberWithInt:actionValue]];    
            break;
        }
    }
}

-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if (touch)
    {
        CGPoint location = [touch locationInView: [touch view]];
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
     
        if ( CGRectContainsPoint([m_blk boundingBox], convertedPoint)) {
            [self actionOpen:nil];
        }
    }
}
@end
