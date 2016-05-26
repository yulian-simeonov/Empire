//
//  StartLyr.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StartLyr.h"
#import "AppDelegate.h"
#import "EnemySelectionLyr.h"
#import "init.h"
#import "Player.h"
#import "GCHelper.h"
#import "GameView.h"

@implementation StartLyr

+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[StartLyr node]];
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
        m_glbMember = delegate->m_globalMembers;
        m_glbVar = delegate->m_globalVars;
        
        winScaleX = delegate->winScaleX;
        winScaleY = delegate->winScaleY;
        
        m_background = [CCSprite spriteWithImageNamed:[self ResourceName:@"empire"]];
        [m_background setPosition: ccp(240 * winScaleX, 160 * winScaleY)];
		[self addChild: m_background];	
        
        float rBaseY = (160 - m_btnPlay.contentSize.height /2) * winScaleY;
        float rLine = 35 * winScaleY;
        
        CCSprite *m_PlayBtnNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_single_play"]];
        CCSprite *m_PlayBtnSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_single_play_pressed"]];
        CCSprite *m_PlayBtnDisable = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_single_play_pressed"]];
        
        m_btnPlay = [CCButton buttonWithTitle:nil spriteFrame:m_PlayBtnNormal.spriteFrame highlightedSpriteFrame:m_PlayBtnSelect.spriteFrame disabledSpriteFrame:m_PlayBtnDisable.spriteFrame];
        [m_btnPlay setTarget:self selector:@selector(actionSinglePlay:)];
        
        [m_btnPlay setPosition: ccp( -100* winScaleX, rBaseY)];
        
        CCSprite *m_multiPlayBtnNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_multiplay"]];
        CCSprite *m_multiPlayBtnSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_multiplay_pressed"]];
        CCSprite *m_multiPlayBtnDisable = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_multiplay_pressed"]];
        
        m_btnMultiPlay = [CCButton buttonWithTitle:nil spriteFrame:m_multiPlayBtnNormal.spriteFrame highlightedSpriteFrame:m_multiPlayBtnSelect.spriteFrame disabledSpriteFrame:m_multiPlayBtnDisable.spriteFrame];
        [m_btnMultiPlay setTarget:self selector:@selector(actionMultiPlay:)];
        
        rBaseY -= rLine;
        [m_btnMultiPlay setPosition: ccp( -100* winScaleX, rBaseY)];

        CCSprite *m_LoadBtnNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_load"]];
        CCSprite *m_LoadBtnSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_load_pressed"]];
        CCSprite *m_LoadBtnDisable = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_load_pressed"]];
        
        m_btnLoad = [CCButton buttonWithTitle:nil spriteFrame:m_LoadBtnNormal.spriteFrame highlightedSpriteFrame:m_LoadBtnSelect.spriteFrame disabledSpriteFrame:m_LoadBtnDisable.spriteFrame];
        [m_btnLoad setTarget:self selector:@selector(actionLoad:)];
        
        rBaseY -= rLine;
        [m_btnLoad setPosition:ccp( 580* winScaleX, rBaseY)];
        
        rBaseY = (160 - m_btnPlay.contentSize.height /2) * winScaleY;
        id action_0 = [CCActionSequence actions:
                       [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 240* winScaleX, rBaseY)] period:0.5f],
                       nil];

        rBaseY -= rLine;
        id action_1 = [CCActionSequence actions:
                       [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 240* winScaleX, rBaseY)] period:0.5f],
                       nil];
        
        [m_btnPlay runAction:action_0];
        [m_btnLoad runAction:action_1];
        
        rBaseY -= rLine;
        id action_2 = [CCActionSequence actions:
                       [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 240* winScaleX, rBaseY)] period:0.5f],
                       nil];
        
        
        [m_btnMultiPlay runAction:action_2];
        [self addChild:m_btnPlay];
        [self addChild:m_btnMultiPlay];
        [self addChild:m_btnLoad];
        
        [self setVisible:true];
    }
    return  self;
}


- (void) actionSound: (id) sender {
//	BOOL bMute = ![AppSettings backgroundMute];
// 	[AppSettings setBackgroundMute: bMute];
//	[_btnSound setIconVisible: bMute];
//	[[SoundManager sharedSoundManager] setBackgroundMusicMute: bMute];
}

- (void) actionEffect: (id) sender {
//	BOOL bMute = ![AppSettings effectMute];
//	[AppSettings setEffectMute: bMute];
//	[_btnEffect setIconVisible: bMute];	
//	[[SoundManager sharedSoundManager] setEffectMute: bMute];
}


- (void) actionSinglePlay: (id) sender
{
	CCScene* layer = [EnemySelectionLyr node];
	ccColor3B color;
	color.r = 0x0;
	color.g = 0x0;
	color.b = 0x0;
   
    CCScene* scene = [CCScene node];
    [scene addChild:layer];
	[[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.7f]];
}

- (void) actionMultiPlay: (id) sender
{
    // Try to start Game Center
    [[GCHelper sharedInstance] authenticateLocalUser];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:4 viewController:delegate.window.rootViewController delegate:delegate->m_mulplayer];
}

- (void) actionLoad: (id) sender
{
    [m_glbVar init_var];
    FILE* fp = nil;
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
	NSString *filePath = [[documentsDirectoryPath stringByAppendingPathComponent:@"empire.dat"] retain];
	
    const char* filename = [filePath UTF8String];
    fp = fopen(filename,"rb");
    
    if ([m_glbVar resgam:fp])
    {
        [StartLyr winSetup];
    }
    else {
        [self Restore];
        m_glbMember->m_inited = true;
    }
    
    m_glbMember->m_bLoadFlag = true;
    CCScene* layer = [GameView node];
    CCScene* scene = [CCScene node];
    [scene addChild:layer];
	[[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.7f]];
}

-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}

+ (void) winSetup
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    /////////////////////////////////////////////////////////////////////////////////////
    Global* m_glbMembers = delegate->m_globalMembers;
    var* m_glbVars = delegate->m_globalVars;

    if (m_glbMembers->m_isMultiPlay)
    {
        if (m_glbMembers->m_isServer)
        {
            init * mapInit = [[init alloc] init];
            [mapInit selmap];
            [m_glbMembers SendMapInfo];
            [mapInit citini];
            [mapInit release];
            
            int numply = m_glbVars->m_numply = m_glbMembers->m_numPlayers;
            m_glbVars->m_numleft = m_glbVars->m_numply;
            
            for (int i = 0; i <= numply ; i++ ) 
            {
                Player *p = m_glbVars->m_player[i];
                
                p->m_display = [[ Display alloc] init];
                Display* d = p->m_display;
                [d initialize];
                
                p->m_num = i;
                
                
                if ( i == 0)
                    p->m_map = m_glbVars->m_map;
                else {
                    p->m_map =  (unsigned char*)malloc( sizeof(unsigned char) * MAPSIZE );
                }

                p->m_playerType = Human;
                p->m_watch = DAnone;
                
                if( p->m_playerType == Human )
                {
                    d->m_timeinterval = 1;
                }
                
                if(i == 1)
                {
                    p->m_secflg = 1;
                    p->m_watch = DAwindows;
                    d->m_maptab = MTcgacolor;
                }
            }
            for (int i = 1; i <= numply ; i++ )
            {
                Player *p = m_glbVars->m_player[i];
                unsigned char ctIdx = [p Citsel:-1];
                
                m_glbMembers->m_cityInfo[i-1] = ctIdx;
//                if (i > 1)
//                    [m_glbMembers SendCityIdx:i cityPosition:ctIdx];
            }
            m_glbVars->m_plynum = 1;
            m_glbMembers->m_playerNum = 1;
            
            [m_glbMembers SendCityIdx];
        }
        else 
        {
            init * mapInit = [[init alloc] init];
            [mapInit selmap];
            [mapInit citini];
            [mapInit release];
            
            int numply = m_glbVars->m_numply = m_glbMembers->m_numPlayers;
            m_glbVars->m_numleft = m_glbVars->m_numply;
            
            for (int i = 0; i <= numply ; i++ )
            {
                Player *p = m_glbVars->m_player[i];
                
                p->m_display = [[ Display alloc] init];
                Display* d = p->m_display;
                [d initialize];
                
                p->m_num = i;
                
                
                if ( i == 0)
                    p->m_map = m_glbVars->m_map;
                else {
                    p->m_map =  (unsigned char*)malloc( sizeof(unsigned char) * MAPSIZE );
                }
                
                p->m_playerType = Human;
                p->m_watch = DAnone;
                
                if( p->m_playerType == Human )
                {
                    d->m_timeinterval = 1;
                }
                
                if(i == 1)
                {
                    p->m_secflg = 1;
                    p->m_watch = DAwindows;
                    d->m_maptab = MTcgacolor;
                }
            }
            for (int i = 1; i <= numply ; i++ )
            {
                Player *p = m_glbVars->m_player[i];
                unsigned char ctIdx = [p Citsel:m_glbMembers->m_cityInfo[i-1]];
            }
            m_glbVars->m_plynum = m_glbMembers->m_playerNum;
            
        }
        
    }
    else
    {
        init * mapInit = [[init alloc] init];
        [mapInit selmap];
        [mapInit citini];
        [mapInit release];
        
        
        int numply = m_glbVars->m_numply = m_glbMembers->m_numPlayers;
        m_glbVars->m_numleft = m_glbVars->m_numply;
        
        for (int i = 0; i <= numply ; i++ ) 
        {
            Player *p = m_glbVars->m_player[i];
            
            p->m_display = [[ Display alloc] init];
            Display* d = p->m_display;
            [d initialize];
            
            p->m_num = i;
            if ( i == 0)
                p->m_map = m_glbVars->m_map;
            else {
                p->m_map =  (unsigned char*)malloc( sizeof(unsigned char) * MAPSIZE );
            }
            if ( i == 1)
                p->m_playerType = Human;
            p->m_watch = DAnone;
            
            if( p->m_playerType == Human )
            {
                d->m_timeinterval = 1;
            }
            
            if(i == 1)
            {
                p->m_secflg = 1;
                p->m_watch = DAwindows;
                d->m_maptab = MTcgacolor;
            }
        }
         for (int i = 1; i <= numply ; i++ )
         {
            Player *p = m_glbVars->m_player[i];
                 [p Citsel:-1];
         }
    
        m_glbVars->m_plynum = 1;
        m_glbMembers->m_playerNum = 1;
    }
}

-(void)Restore
{
//    text* t = ((Player*)m_glbVar->m_player[0])->m_display->m_text;
//    [t TTinit];
    for (int i = 0; i <= m_glbVar->m_numply; i++)
    {
        Player* p = m_glbVar->m_player[i];
        Display* d = [[Display alloc] init];
        p->m_display = d;
        [d initialize];
        
        if (i == 1)
        {
            p->m_secflg = true;
            p->m_watch = DAwindows;
//            [d->m_text TTinit];
//            d->m_text->m_watch = p->m_watch;
//            d->m_maptab = MTcgacolor;
//            [d setdispsize:d->m_text->m_nrows col:d->m_text->m_ncols];
//            [d->m_text clear];
//            [d->m_text block_cursor];
        }
    }
    m_glbVar->m_plynum = 1;
    m_glbMember->m_playerNum = 1;
}
@end
