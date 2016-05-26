//
//  CitySelectionLyr.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CitySelectionLyr.h"
#import "AppDelegate.h"
#import "Define.h"
#import "GameView.h"
#import "EnemySelectionLyr.h"
#import "Player.h"

@implementation CitySelectionLyr


-(void)dealloc
{
    [super dealloc];
}

- (id) init
{
    if ((self = [super init])) 
	{
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]  delegate];
        
        /////////////////////////////////////////////////////////////////////////////////////
        m_glbMembers = delegate->m_globalMembers;
        m_glbVars = delegate->m_globalVars;
        m_glbMembers->m_newPhase = m_glbMembers->m_phase;
        /////////////////////////////////////////////////////////////////////////////////////
        
        winScaleX = delegate->winScaleX;
        winScaleY = delegate->winScaleY;
        
        m_background = [CCSprite spriteWithImageNamed: [self ResourceName: @"phase_select_panel"]];
        [m_background setPosition: ccp( 240*winScaleX, 160*winScaleY)];
        [self addChild: m_background];
        [m_background setScaleY:1.2f];
        
        CCSprite *m_ArmiesNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_army"]];
        CCSprite *m_ArmiesSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_army_pressed"]];
        CCSprite *m_ArmiesVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_army_pressed"]];
        
        m_btnArmies = [CCButton buttonWithTitle:nil spriteFrame:m_ArmiesNormal.spriteFrame highlightedSpriteFrame:m_ArmiesSelect.spriteFrame disabledSpriteFrame:m_ArmiesVal.spriteFrame];
        [m_btnArmies setTarget:self selector:@selector(actionArmies:)];
        
        CCSprite *m_FightNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_fighter"]];
        CCSprite *m_FightSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_fighter_pressed"]];
        CCSprite *m_FightVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_fighter_pressed"]];
        
        m_btnFighters = [CCButton buttonWithTitle:nil spriteFrame:m_FightNormal.spriteFrame highlightedSpriteFrame:m_FightSelect.spriteFrame disabledSpriteFrame:m_FightVal.spriteFrame];
        [m_btnFighters setTarget:self selector:@selector(actionFighters:)];
        CCSprite *m_DesNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_destroyer"]];
        CCSprite *m_DesSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_destroyer_pressed"]];
        CCSprite *m_DesVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_destroyer_pressed"]];
        
        m_btnDestroyers = [CCButton buttonWithTitle:nil spriteFrame:m_DesNormal.spriteFrame highlightedSpriteFrame:m_DesSelect.spriteFrame disabledSpriteFrame:m_DesVal.spriteFrame];
        [m_btnDestroyers setTarget:self selector:@selector(actionDestroyers:)];
        
        CCSprite * m_TransNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_transport"]];
        CCSprite * m_TransSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_transport_pressed"]];
        CCSprite * m_TransVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_transport_pressed"]];
        
        m_btnTransports = [CCButton buttonWithTitle:nil spriteFrame:m_TransNormal.spriteFrame highlightedSpriteFrame:m_TransSelect.spriteFrame disabledSpriteFrame:m_TransVal.spriteFrame];
        [m_btnTransports setTarget:self selector:@selector(actionTransports:)];
        
        CCSprite * m_SubNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_submarine"]];
        CCSprite * m_SubSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_submarine_pressed"] ];
        CCSprite * m_SubVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_submarine_pressed"]];
        
        m_btnSubmarines = [CCButton buttonWithTitle:nil spriteFrame:m_SubNormal.spriteFrame highlightedSpriteFrame:m_SubSelect.spriteFrame disabledSpriteFrame:m_SubVal.spriteFrame];
        [m_btnSubmarines setTarget:self selector:@selector(actionSubmarines:)];
        
        CCSprite *m_CruNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_cruiser"]];
        CCSprite *m_CruSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_cruiser_pressed"]];
        CCSprite *m_CruVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_cruiser_pressed"]];
        
        m_btnCruisers = [CCButton buttonWithTitle:nil spriteFrame:m_CruNormal.spriteFrame highlightedSpriteFrame:m_CruSelect.spriteFrame disabledSpriteFrame:m_CruVal.spriteFrame];
        [m_btnCruisers setTarget:self selector:@selector(actionCruisers:)];
        
        CCSprite * m_CarrNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_carrier"]];
        CCSprite * m_CarrSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_carrier_pressed"]];
        CCSprite * m_CarrVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_carrier_pressed"]];
        
        m_btnCarriers = [CCButton buttonWithTitle:nil spriteFrame:m_CarrNormal.spriteFrame highlightedSpriteFrame:m_CarrSelect.spriteFrame disabledSpriteFrame:m_CarrVal.spriteFrame];
        [m_btnCarriers setTarget:self selector:@selector(actionCarriers:)];
        
        CCSprite * m_BattleNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_battleship"]];
        CCSprite * m_BattleSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_battleship_pressed"]];
        CCSprite * m_BattleVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_battleship_pressed"]];
        
        m_btnBattleships = [CCButton buttonWithTitle:nil spriteFrame:m_BattleNormal.spriteFrame highlightedSpriteFrame:m_BattleSelect.spriteFrame disabledSpriteFrame:m_BattleVal.spriteFrame];
        [m_btnBattleships setTarget:self selector:@selector(actionBattle:)];
        
        CCSprite * m_OkNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_select"]];
        CCSprite * m_OkSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_select_pressed"]];
        CCSprite * m_OkVal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_select_pressed"]];
        
        m_btnOk = [CCButton buttonWithTitle:nil spriteFrame:m_OkNormal.spriteFrame highlightedSpriteFrame:m_OkSelect.spriteFrame disabledSpriteFrame:m_OkVal.spriteFrame];
        [m_btnOk setTarget:self selector:@selector(actionOk:)];
        
//        CCMenu * menu  = [CCMenu menuWithItems:m_btnArmies, m_btnFighters, m_btnDestroyers, m_btnTransports, m_btnSubmarines, m_btnCruisers,
//                          m_btnCarriers, m_btnBattleships,m_btnOk, nil];
//        [menu alignItemsVertically];
//        [menu setPosition         ];
//        [self addChild: menu];
        
        CCLayoutBox *layoutBox = [[CCLayoutBox alloc] init];
        layoutBox.anchorPoint = ccp(0.5, 0.5);
        [layoutBox addChild:m_btnOk];
        [layoutBox addChild:m_btnBattleships];
        [layoutBox addChild:m_btnCarriers];
        [layoutBox addChild:m_btnCruisers];
        [layoutBox addChild:m_btnSubmarines];
        [layoutBox addChild:m_btnTransports];
        [layoutBox addChild:m_btnDestroyers];
        [layoutBox addChild:m_btnFighters];
        [layoutBox addChild:m_btnArmies];
        
        layoutBox.spacing = 10.f;
        layoutBox.direction = CCLayoutBoxDirectionVertical;
        [layoutBox layout];
        layoutBox.position = ccp( 200 * winScaleX, 150 * winScaleY );
        [self addChild:layoutBox];
        
        
        m_City = [CCSprite spriteWithImageNamed:[self ResourceName:@"city_back"]];
        [m_City setScale:0.35f];
        [self addChild: m_City];
        
        m_SelectObj = [CCSprite spriteWithImageNamed:[self ResourceName:@"ArmiesCity"]];
        [m_SelectObj setScale:0.2f];
        [self addChild: m_SelectObj];
        
        //26
        m_rBaseY = 260 * winScaleY;
        m_rLine = 28 * winScaleY;
        
        m_board = [CCSprite spriteWithImageNamed:[self ResourceName:@"character_border"]];
        [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY)];
        [self addChild: m_board];
        
        m_arror = [CCSprite spriteWithImageNamed:[self ResourceName:@"arrow"]];
        [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY)];
        [self addChild: m_arror];
        
        m_board1 = [CCSprite spriteWithImageNamed:[self ResourceName:@"character_border"]];
        [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY)];
        [self addChild: m_board1];
        
        [m_City setPosition:m_board.position];
        [m_SelectObj setPosition:m_board1.position];
    }
    
    return  self;
}


-(void) actionArmies:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"ArmiesCity"]]).spriteFrame];
    m_nCityType = (int)A;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionFighters:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"FightCity"]]).spriteFrame];
    m_nCityType = (int)F;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionDestroyers:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"DestroyerCity"]]).spriteFrame];
    m_nCityType = (int)D;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 2 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 2 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 2 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionTransports:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"TransCity"]]).spriteFrame];
    m_nCityType = T;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 3 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 3 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 3 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionSubmarines:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"SubCity"]]).spriteFrame];
    m_nCityType = S;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 4 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 4 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 4 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionCarriers:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"CarrierCity"]]).spriteFrame];
    m_nCityType = C;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 6 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 6 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 6 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void)actionCruisers:(id)sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"CruCity"]]).spriteFrame];
    m_nCityType = R;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 5 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 5 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 5 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionBattle:(id) sender
{
    [m_SelectObj setSpriteFrame:((CCSprite*)[CCSprite spriteWithImageNamed:[self ResourceName:@"BattleCity"]]).spriteFrame];
    m_nCityType = B;
    
    [m_board setPosition: ccp( 275 * winScaleX, m_rBaseY - 7 * m_rLine)];
    [m_arror setPosition:ccp( 300 * winScaleX, m_rBaseY - 7 * m_rLine)];
    [m_board1 setPosition: ccp( 325 * winScaleX, m_rBaseY - 7 * m_rLine)];
    [m_City setPosition:m_board.position];
    [m_SelectObj setPosition:m_board1.position];

}
-(void) actionOk:(id)sender
{
    City * city = m_glbVars->m_city[m_glbMembers->m_nSelectedCityIdx];
    city->m_phs = m_nCityType;

    Player * p = m_glbVars->m_player[m_glbMembers->m_playerNum];
    if( m_glbVars->m_unitop == 0 )
        city->m_fnd = 0;
    else {
        city->m_fnd = p->m_round + m_glbVars->m_typx[m_nCityType]->m_phstart;        
    }

    
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * winScaleX, 400 * winScaleY )] period:0.5f],
                 nil];
    [self runAction:action];	
 //   m_glbMembers->m_nCityType = m_nCityType;
    [m_glbMembers->m_GameView setVisibleLyr:true];
    m_glbMembers->m_inited = true;

}
-(void) actionCancel:(id)sender
{
    m_glbVars->m_city[m_glbMembers->m_nSelectedCityIdx]->m_phs = A;
//    m_glbMembers->m_inited = true;
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * winScaleX, 400 * winScaleY )] period:0.5f],
                 nil];
    [self runAction:action];	
}

-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}

@end
