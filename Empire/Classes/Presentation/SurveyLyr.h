//
//  SurveyLyr.h
//  Empire
//
//  Created by 陈玉亮 on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface SurveyLyr : CCNode
{
    float winScaleX;
    float winScaleY;
    
    CCSprite * m_Cousor;
}
-(NSString*)ResourceName:(NSString*)orgString;
@end
