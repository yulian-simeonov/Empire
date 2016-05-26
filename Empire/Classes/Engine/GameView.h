//
//  GameView.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "empire.h"
#import "maps.h"
#import "var.h"
#import "cocos2d.h"
#import "Global.h"
#import "var.h"
#import "move.h"
#import "GameViewDelegate.h"
#import "CitySelectionLyr.h"
#import "CmdLyr.h"
#import "SurveyLyr.h"

@interface GameView : CCNode<GameViewDelegate>
{
    // For each display
    
    CCSprite * m_background;

    float   winScaleX;
    float   winScaleY;
    
    float   winScreenX;
    float   winScreenY;
    
    CCButton * m_btnleft;
    CCButton * m_btnRight;
    CCButton * m_btnTop;
    CCButton * m_btnDown;
    CCButton * m_btnTopleft;
    CCButton * m_btnTopRight;
    CCButton * m_btnDownleft;
    CCButton * m_btnDownRight;
    
    CCButton * m_btnSelect;
    
    Global*         m_glbMembers;
    var*            m_glbVars;    
    move*           m_move;
    
    CCNode *       m_blkLyr;
    CCNode *       m_landLyr;
    
    int             m_nColor;
    CGPoint        m_startPt;
    CGPoint        m_endPt;
    CGPoint        m_originPt;
    
    CitySelectionLyr * m_cityLyr;
    
    //text
    CCSprite *     m_textSpr;
    CCSprite *     cursol;
    
    CCLabelTTF*    m_label0;
    CCLabelTTF*    m_label1;
    CCLabelTTF*    m_label2;
    CCLabelTTF*    m_label3;
    CCLabelTTF*    m_label4;
    
    CmdLyr *       m_CmdLyr;
    SurveyLyr *    m_SurveyLyr;
    
    CCSprite *     m_Blast; 
    int            m_BlastLoc; 
    int            m_BlastDur; 
    
    CCSprite*       m_sea;
    CCSprite*       m_land;
    CCSprite*       m_city[7];
    CCSprite*       m_army[7];
    CCSprite*       m_flighter[7];
    CCSprite*       m_fs[7];
    CCSprite*       m_destroyer[7];
    CCSprite*       m_transport[7];
    CCSprite*       m_submarine[7];
    CCSprite*       m_cruiser[7];
    CCSprite*       m_carrier[7];
    CCSprite*       m_battleship[7];
    
    CCSprite *      m_spOver;
    BOOL            m_bThread;
    
    
    int             m_nCursolRepeat;
    BOOL            m_bCursol;
    int             m_nCursolPos;
@public
    NSMutableArray * m_DrawPosArr;
    
}

- (BOOL) isGameWin;
- (BOOL) isGameOver;

-(NSString*)ResourceName:(NSString*)orgString;

-(void) actionLeft:(id)sender;
-(void) actionRight:(id)sender;
-(void) actionTop:(id)sender;
-(void) actionDown:(id)sender;
-(void) actionTopleft:(id)sender;
-(void) actionTopRight:(id)sender;
-(void) actionDownLeft:(id)sender;
-(void) actionDownRight:(id)sender;
-(void) actionSelect:(id)sender;
-(void)GiveAction:(enum CmdType)actionValue;
-(void)GiveAction:(enum CmdType)actionValue playNum:(int) idx;

- (void) drawButton;
- (void) drawCity;
- (void) drawBackground;

- (CCSprite*) getImgMapData : (int) loc;
- (NSString*) getPlayerType: (NSString*) str idx:(int) nIdx;

- (void) showSelectDlg;
- (void) moveScreen;
- (void) setLabelString;
- (void) setVisbleMap;
-(void) setVisibleLyr: (BOOL) bflag;
- (void) showBlast : (int) loc;
- (void)GoMainMenu;
@end
