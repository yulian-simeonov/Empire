//
//  JSMultiPlayerManager.m
//  ArcheryXtreme
//
//  Created by ZhangBuSe on 1/21/13.
//  Copyright (c) 2013 Conception Designs. All rights reserved.
//

#import "JSMultiPlayerManager.h"
#import "AppDelegate.h"

@implementation JSMultiPlayerManager
@synthesize isServer;

-(id)initWithViewcontroller:(UIViewController*)parentVwController
{
    if (self = [super init])
    {
        _ParentViewController = parentVwController;
        [[GCHelper sharedInstance] setDelegate:self];
        isServer = false;
    }
    return self;
}

- (void)matchStarted;
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate->m_globalMembers matchStarted];
}

- (void)matchEnded
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate->m_globalMembers matchEnded];
}

-(NSArray*)GetPlayers
{
    GKMatch* match = [[GCHelper sharedInstance] match];
    return [match playerIDs];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate->m_globalMembers ReceiveData:data fromPlayer:playerID];
    NSLog(@"Received Packer");
}

@end
