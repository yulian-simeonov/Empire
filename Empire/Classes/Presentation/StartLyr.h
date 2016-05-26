//
//  StartLyr.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCButton.h"
#import "Global.h"
#import "var.h"

@interface StartLyr : CCNode
{
    CCSprite *m_background;
    Global * m_glbMember;
    var*     m_glbVar;
    
    CCButton * m_btnPlay;
    CCButton * m_btnMultiPlay;
    CCButton * m_btnLoad;
    
    CCButton * toggle;
    
    float winScaleX;
    float winScaleY;
}


-(NSString*)ResourceName:(NSString*)orgString;
+ (void) winSetup;
+ (CCScene*) scene;
- (id) init;
-(void)dealloc;
- (void) actionSound: (id) sender;
- (void) actionEffect: (id) sender ;
- (void) actionSinglePlay: (id) sender;
- (void) actionMultiPlay: (id) sender;
- (void) actionLoad: (id) sender;
-(void)Restore;

@end
