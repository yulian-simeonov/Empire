//
//  EnemySelectionLyr.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCButton.h"
#import "cocos2d.h"
#import "Global.h"
#import "var.h"


@interface EnemySelectionLyr : CCNode
{
    CCSprite* m_background;
    CCSprite* m_Panel;
    
    CCButton * m_btnNum0;
    CCButton* m_btnNum1;
    CCButton * m_btnNum2;
    CCButton * m_btnNum3;
    CCButton * m_btnNum4;
    CCButton * m_btnNum5;
    CCButton * m_btnDemo;
    
    CCButton * m_btnOK;
    CCButton * m_btnCancel;
        
    float winScaleX;
    float winScaleY;
    Global*         m_glbMembers;
    var*            m_glbVars;
    @public
    int   m_nLevelNum;
}

-(NSString*)ResourceName:(NSString*)orgString;
-(void) actionNum1:(id)sender;
-(void) actionNum2:(id)sender;
-(void) actionNum3:(id)sender;
-(void) actionNum4:(id)sender;
-(void) actionNum5:(id)sender;
-(void)StartGame;
-(void) actionCancel:(id)sender;
-(void) actionNum6:(id)sender;

@end
