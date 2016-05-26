//
//  AppDelegate.h
//  Empire
//
//  Created by Scott Burosh on 10/21/14.
//  Copyright SUPE 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "cocos2d.h"
#import "Global.h"
#import "var.h"
#import "JSMultiPlayerManager.h"

@interface AppDelegate : CCAppDelegate
{
@public
    JSMultiPlayerManager* m_mulplayer;
    float winScaleX;
    float winScaleY;
    Global*         m_globalMembers;
    var*            m_globalVars;
}

- (void) setScale;
@end
