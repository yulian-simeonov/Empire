//
//  AppDelegate.m
//  Empire
//
//  Created by Scott Burosh on 10/21/14.
//  Copyright SUPE 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "StartLyr.h"
//#import <BugSense-iOS/BugSenseController.h>

@implementation AppDelegate

// 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
    m_globalMembers = [[Global alloc] init];
    m_globalVars = [[var alloc] init];
    m_mulplayer = [[JSMultiPlayerManager alloc] initWithViewcontroller:self.window.rootViewController];
    [[GCHelper sharedInstance] authenticateLocalUser];
    [self setScale];
    
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
//		CCSetupShowDebugStats: @(YES),
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
//		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
//    [BugSenseController sharedControllerWithBugSenseAPIKey:@"f7333ea1"];
//    [BugSenseController setErrorNetworkOperationsCompletionBlock:^() {
//        if ([BugSenseController crashCount] > 5) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We're sorry!" message:@"We are aware of the crashes that you have experienced lately, and are actively working on fixing them for the next version!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//            [BugSenseController resetCrashCount];
//        }
//        else
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We're sorry!" message:@"The crash report was sent us. We will fix them quickly for the next version." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//    }];
	return YES;
}

-(CCScene*)startScene
{
    return [StartLyr scene];
}

- (void) setScale
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        winScaleX = 1024.0f / 480.0f;
        winScaleY = 768.0f / 320.0f;
    }
    else {
        
        winScaleX = 1;
        winScaleY = 1;
    }
}
@end
