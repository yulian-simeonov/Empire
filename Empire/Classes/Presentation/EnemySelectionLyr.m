//
//  EnemySelectionLyr.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EnemySelectionLyr.h"
#import "AppDelegate.h"
#import "CitySelectionLyr.h"
#import "StartLyr.h"
#import "init.h"
#import "Player.h"
#import "GameView.h"
#import "StartLyr.h"

@implementation EnemySelectionLyr

+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[EnemySelectionLyr node]];
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
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        /////////////////////////////////////////////////////////////////////////////////////
        m_glbMembers = delegate->m_globalMembers;
        m_glbMembers->m_newNumPlayers = m_glbMembers->m_numPlayers;
        m_glbVars = delegate->m_globalVars;
        [m_glbVars init_var];
    
        /////////////////////////////////////////////////////////////////////////////////////
        
        winScaleX = delegate->winScaleX;
        winScaleY = delegate->winScaleY;
        
        m_background = [CCSprite spriteWithImageNamed: [self ResourceName:@"empire"]];
        [m_background setPosition:ccp( 240* winScaleX , 160 * winScaleY)];
        [self addChild: m_background ];
       
        CCSprite *num0Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy1"]];
        CCSprite *num0Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy1_pressed"]];
        CCSprite *num0Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy1_pressed"]];
        
        m_btnNum0 = [CCButton buttonWithTitle:nil spriteFrame:num0Normal.spriteFrame highlightedSpriteFrame:num0Select.spriteFrame disabledSpriteFrame:num0Val.spriteFrame];
        [m_btnNum0 setTarget:self selector:@selector(actionNum1:)];
        
        CCSprite *num1Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy2"]];
        CCSprite *num1Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy2_pressed"]];
        CCSprite *num1Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy2_pressed"]];
        
        m_btnNum1 = [CCButton buttonWithTitle:nil spriteFrame:num1Normal.spriteFrame highlightedSpriteFrame:num1Select.spriteFrame disabledSpriteFrame:num1Val.spriteFrame];
        [m_btnNum1 setTarget:self selector:@selector(actionNum2:)];
        
        CCSprite *num2Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy3"]];
        CCSprite *num2Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy3_pressed"]];
        CCSprite *num2Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy3_pressed"]];
        
        m_btnNum2 = [CCButton buttonWithTitle:nil spriteFrame:num2Normal.spriteFrame highlightedSpriteFrame:num2Select.spriteFrame disabledSpriteFrame:num2Val.spriteFrame];
        [m_btnNum2 setTarget:self selector:@selector(actionNum3:)];
        
        CCSprite *num3Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy4"]];
        CCSprite *num3Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy4_pressed"]];
        CCSprite *num3Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy4_pressed"]];
        
        m_btnNum3 = [CCButton buttonWithTitle:nil spriteFrame:num3Normal.spriteFrame highlightedSpriteFrame:num3Select.spriteFrame disabledSpriteFrame:num3Val.spriteFrame];
        [m_btnNum3 setTarget:self selector:@selector(actionNum3:)];
        
        CCSprite *num4Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy5"]];
        CCSprite *num4Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy5_pressed"]];
        CCSprite *num4Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy5_pressed"]];
        
        m_btnNum4 = [CCButton buttonWithTitle:nil spriteFrame:num4Normal.spriteFrame highlightedSpriteFrame:num4Select.spriteFrame disabledSpriteFrame:num4Val.spriteFrame];
        [m_btnNum4 setTarget:self selector:@selector(actionNum5:)];
        
        CCSprite *num5Normal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy6"]];
        CCSprite *num5Select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy6_pressed"]];
        CCSprite *num5Val = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_enemy6_pressed"]];

        m_btnNum5 = [CCButton buttonWithTitle:nil spriteFrame:num5Normal.spriteFrame highlightedSpriteFrame:num5Select.spriteFrame disabledSpriteFrame:num5Val.spriteFrame];
        [m_btnNum5 setTarget:self selector:@selector(actionNum6:)];
        
        CCSprite* m_NumCancelNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"btn_back_main"]];
        CCSprite* m_NumCancelSelected = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_back_main_pressed"]];
        CCSprite* m_NumCancelAvailable = [CCSprite spriteWithImageNamed:[self ResourceName: @"btn_back_main_pressed"]];
        
        m_btnCancel = [CCButton buttonWithTitle:nil spriteFrame:m_NumCancelNormal.spriteFrame highlightedSpriteFrame:m_NumCancelSelected.spriteFrame disabledSpriteFrame:m_NumCancelAvailable.spriteFrame];
        [m_btnCancel setTarget:self selector:@selector(actionCancel:)];
        
        m_Panel = [CCSprite spriteWithImageNamed: [self ResourceName:@"enemy_select_panel"]];
        float rBaseY = (160 - 55 + 8) * winScaleY;
        float rLine = 30 * winScaleY;
        [m_Panel setPosition:ccp( 240 * winScaleX, rBaseY )];
        [self addChild: m_Panel z:1 ];
        
//        CCMenu * menu = [CCMenu menuWithItems:m_btnNum0,m_btnNum1, m_btnNum2, m_btnNum3, m_btnNum4, m_btnNum5, 
//                         m_btnCancel, nil];
//        [menu setPosition:ccp( m_Panel.position.x - m_Panel.contentSize.width/2, m_Panel.position.y - m_Panel.contentSize.height / 2 )];
//        [self addChild: menu z:2];
        
        CCNode* node = [CCNode node];
        [node setPosition:ccp( m_Panel.position.x - m_Panel.contentSize.width/2, m_Panel.position.y - m_Panel.contentSize.height / 2 )];
        [node addChild:m_btnNum0];
        [node addChild:m_btnNum1];
        [node addChild:m_btnNum2];
        [node addChild:m_btnNum3];
        [node addChild:m_btnNum4];
        [node addChild:m_btnNum5];
        [node addChild:m_btnCancel];
        [self addChild:node z:2];
        
        rBaseY = m_Panel.contentSize.height * 2 / 3 + 15 * winScaleY;
        [m_btnNum0 setPosition:ccp( 100 * winScaleX, rBaseY)];
        
        rBaseY -= rLine;
        [m_btnNum1 setPosition:ccp( 100 *winScaleX, rBaseY)];
        
        rBaseY -= rLine;
        [m_btnNum2 setPosition:ccp( 100 * winScaleX, rBaseY)];
        
        
        float rBaseX = (327 - 100) * winScaleX;
        rBaseY = m_Panel.contentSize.height * 2 / 3 + 15 * winScaleY;
        [m_btnNum3 setPosition:ccp( rBaseX, rBaseY )];
        
        rBaseY -= rLine;
        [m_btnNum4 setPosition:ccp( rBaseX, rBaseY)];
        
        rBaseY -= rLine;
        [m_btnNum5 setPosition: ccp( rBaseX, rBaseY)];
        
        [m_btnCancel setPosition:ccp( m_Panel.contentSize.width - m_btnCancel.contentSize.width/2 - 5 * winScaleX, m_Panel.contentSize.height - m_btnCancel.contentSize.height/2 - 5 * winScaleY)];
        
        m_nLevelNum = 0;
        
    }
    
    return  self;
}


-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}

- (void) actionNum1:(id)sender
{
    m_nLevelNum = 2;
    [self StartGame];
}

- (void) actionNum2:(id)sender
{
    m_nLevelNum = 3;
    [self StartGame];
}

- (void) actionNum3:(id)sender
{
    m_nLevelNum = 4;
    [self StartGame];
}

-(void) actionNum4:(id)sender
{
    m_nLevelNum = 5;
    [self StartGame];
}

-(void) actionNum5:(id)sender
{
    m_nLevelNum = 6;
    [self StartGame];
}

-(void) actionNum6:(id)sender
{
    m_nLevelNum = 6;
    [self StartGame];
}

-(void) StartGame
{    
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

-(void) actionCancel:(id)sender
{
    CCScene* layer = [StartLyr node];
    CCScene* scene = [CCScene node];
    [scene addChild:layer];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.7f]];
}




@end
