//
//  CitySelectionLyr.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCButton.h"
#import "Global.h"
#import "var.h"

@interface CitySelectionLyr : CCNode
{
    CCSprite * m_background;
    
    CCButton * m_btnArmies;
    CCButton * m_btnFighters;
    CCButton * m_btnDestroyers;
    CCButton * m_btnTransports;
    CCButton * m_btnSubmarines;
    CCButton * m_btnCruisers;
    CCButton * m_btnCarriers;
    CCButton * m_btnBattleships;
    
    CCButton * m_btnOk;
    CCButton * m_btnCancel;
    
    float winScaleX;
    float winScaleY;
    Global*         m_glbMembers;
    var*            m_glbVars;
    CCSprite * m_City;
    CCSprite * m_SelectObj;
    
    CCSprite * m_board;
    CCSprite * m_arror;
    CCSprite * m_board1;
    
    float    m_rBaseY;
    float    m_rLine;
    
    int   m_nCityType;
}

-(NSString*)ResourceName:(NSString*)orgString;
-(void) actionArmies:(id)sender;
-(void) actionFighters:(id)sender;
-(void) actionDestroyers:(id)sender;
-(void) actionTransports:(id)sender;
-(void) actionSubmarines:(id)sender;
-(void) actionCarriers:(id)sender;
-(void) actionBattle:(id) sender;
-(void)actionCruisers:(id)sender;
-(void) actionOk:(id)sender;
-(void) actionCancel:(id)sender;

@end
