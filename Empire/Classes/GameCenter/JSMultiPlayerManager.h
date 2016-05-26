//
//  JSMultiPlayerManager.h
//  ArcheryXtreme
//
//  Created by ZhangBuSe on 1/21/13.
//  Copyright (c) 2013 Conception Designs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCHelper.h"
#import "Define.h"

@interface JSMultiPlayerManager : NSObject<GCHelperDelegate>
{

}

@property (nonatomic) BOOL isServer;
@property (nonatomic, retain) UIViewController* ParentViewController;
-(id)initWithViewcontroller:(UIViewController*)parentVwController;
@end
