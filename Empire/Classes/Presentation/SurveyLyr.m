//
//  SurveyLyr.m
//  Empire
//
//  Created by 陈玉亮 on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SurveyLyr.h"
#import "AppDelegate.h"
#import "Player.h"

#define CELLWIDTH 20.0f

@implementation SurveyLyr

+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[SurveyLyr node]];
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
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        winScaleX = delegate->winScaleX;
        winScaleY = delegate->winScaleY;
        
        [self update:0.1f];
    }
    return self;
}


-(void) update:(double) delta
{
    [self draw];
}

- (void) draw
{
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    Player* ply = delegate->m_globalVars->m_player[delegate->m_globalMembers->m_playerNum];
    
    [self removeAllChildren];

    m_Cousor = [CCSprite spriteWithImageNamed:[ self ResourceName:@"cursor"]];
    [m_Cousor setPosition:ccp( -100* winScaleX, -100 *  winScaleY)];
    [m_Cousor setVisible:false];
    [self addChild:m_Cousor z: 2];

    
    switch (delegate->m_globalMembers->m_CmdMode) {
        case mdSURV: //survey
        {
            [m_Cousor setVisible:false];
            
//            glLineWidth(2);
            
            int loc = delegate->m_globalMembers->m_Surveyloc;
            float rRow = CELLWIDTH/2 + [empire ROW:loc] * CELLWIDTH;
            float rCol = CELLWIDTH/2 + [empire COL:loc] * CELLWIDTH;
            
            rRow +=  delegate->m_globalMembers->m_rMoveY;
            rCol +=  delegate->m_globalMembers->m_rMoveX;
            
            if (rRow <= 10 * winScaleY ) {
                rRow = 10 * winScaleY;
            }
            if( rRow >= 310 * winScaleY ) {
                rRow = 310 * winScaleY ;
            }
            if( rCol <= 10 * winScaleX  ) {
                rCol = 10 * winScaleX;
            }
            if( rCol >= 470 * winScaleX ) {
                rCol = 470 * winScaleX;
            }
            
            
            
            CGPoint Start = CGPointMake(0, 0);
            CGPoint End = CGPointMake(0, 0);
            
            Start.x = 0.0f; Start.y = rRow;
            End.x = rCol - 5 * winScaleX; End.y = rRow;
            
            CCDrawNode *_line01 = [CCDrawNode node];
            [_line01 drawSegmentFrom: Start to: End radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line01];
            
            Start.x = rCol + 5 * winScaleX; Start.y = rRow;
            End.x = 480 * winScaleX; End.y = rRow;
            
            CCDrawNode *_line02 = [CCDrawNode node];
            [_line02 drawSegmentFrom: Start to: End radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line02];

            
            
            Start.x = rCol; Start.y = rRow + 5 * winScaleY;
            End.x = rCol; End.y = 320 * winScaleY;

            CCDrawNode *_line03 = [CCDrawNode node];
            [_line03 drawSegmentFrom: Start to: End radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line03];
            
            Start.x = rCol; Start.y = rRow - 5 * winScaleY;
            End.x = rCol; End.y = 0.0f;
            CCDrawNode *_line04 = [CCDrawNode node];
            [_line04 drawSegmentFrom: Start to: End radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line04];


        }
            break;
        case mdDIR://Direction
        {
            [m_Cousor setVisible:false];
            glLineWidth(1);
            
            int loc = ply->m_curloc;
            float rRow = CELLWIDTH/2 + [empire ROW:loc] * CELLWIDTH;
            float rCol = CELLWIDTH/2 + [empire COL:loc] * CELLWIDTH;
            
            rRow +=  delegate->m_globalMembers->m_rMoveY;
            rCol +=  delegate->m_globalMembers->m_rMoveX;
            
            CGPoint start = CGPointMake(0, 0);
            CGPoint end = CGPointMake(0, 0);
            
            start.x = rCol -CELLWIDTH/2; start.y = rRow;
            end.x = rCol - CELLWIDTH * 5; end.y = rRow;

            CCDrawNode *_line01 = [CCDrawNode node];
            [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line01];
            
            
            start.x = rCol - CELLWIDTH/2; start.y = rRow + CELLWIDTH/2;
            end.x = rCol - CELLWIDTH * 5; end.y = rRow + CELLWIDTH * 5;

            CCDrawNode *_line02 = [CCDrawNode node];
            [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line02];

            
            start.x = rCol; start.y = rRow + CELLWIDTH/2;
            end.x = rCol; end.y = rRow +  5 * CELLWIDTH;

            CCDrawNode *_line03 = [CCDrawNode node];
            [_line03 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line03];

            
            start.x = rCol + CELLWIDTH/2; start.y = rRow + CELLWIDTH/2;
            end.x = rCol + 5 * CELLWIDTH; end.y = rRow + 5 * CELLWIDTH;

            CCDrawNode *_line04 = [CCDrawNode node];
            [_line04 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line04];

            
            start.x = rCol + CELLWIDTH/2; start.y = rRow;
            end.x = rCol + 5 * CELLWIDTH; end.y = rRow;

            CCDrawNode *_line05 = [CCDrawNode node];
            [_line05 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line05];

            
            start.x = rCol + CELLWIDTH/2; start.y = rRow - CELLWIDTH/2;
            end.x = rCol + 5 * CELLWIDTH; end.y = rRow - 5 * CELLWIDTH;

            CCDrawNode *_line06 = [CCDrawNode node];
            [_line06 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line06];

            
            start.x = rCol; start.y = rRow - CELLWIDTH/2;
            end.x = rCol; end.y = rRow - 5 * CELLWIDTH;

            CCDrawNode *_line07 = [CCDrawNode node];
            [_line07 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line07];

            
            start.x = rCol - CELLWIDTH/2; start.y = rRow - CELLWIDTH/2;
            end.x = rCol - 5 * CELLWIDTH; end.y = rRow - 5 * CELLWIDTH;

            CCDrawNode *_line08 = [CCDrawNode node];
            [_line08 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
            [self addChild:_line08];

            
        }
            break;
        case mdTO:
        {
             glLineWidth(1);
            [m_Cousor setVisible:true];
            int loc = ply->m_curloc;
            if( ply->m_curloc == ply->m_frmloc )
            {
                [m_Cousor setVisible:false];
                return;
            }
            
            if( ply->m_frmloc == 0 )
                return;
            
            float curRow = CELLWIDTH/2 + [empire ROW:loc] * CELLWIDTH;
            float curCol = CELLWIDTH/2 + [empire COL:loc] * CELLWIDTH;
            
            float oldRow = CELLWIDTH/2 + [empire ROW:ply->m_frmloc] * CELLWIDTH;
            float oldCol = CELLWIDTH/2 + [empire COL:ply->m_frmloc] * CELLWIDTH;
            
            float deltaX =  oldCol - curCol;
            float deltaY =  oldRow - curRow;
            
            curRow +=  delegate->m_globalMembers->m_rMoveY;
            curCol +=  delegate->m_globalMembers->m_rMoveX;
            
            oldRow +=  delegate->m_globalMembers->m_rMoveY;
            oldCol +=  delegate->m_globalMembers->m_rMoveX;
            
            CGPoint start = CGPointMake(0, 0);
            CGPoint end = CGPointMake(0, 0);
            
            [m_Cousor setPosition:ccp( curCol, curRow)];
            if( oldCol == curCol || curRow == oldRow )
            {
                start.x = curCol; start.y = curRow;
                end.x = oldCol; end.y = oldRow;

                CCDrawNode *_line01 = [CCDrawNode node];
                [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                [self addChild:_line01];

            }
            else {
                if ( fabsf(deltaX)  > fabsf(deltaY) ) {
                    
                    if( deltaX >= 0 && deltaY >= 0 )
                    {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaY; end.y = oldRow - deltaY;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];
                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];

                        
                    }
                    else if( deltaX < 0 && deltaY < 0) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaY; end.y = oldRow - deltaY;
                        CCDrawNode *_line03 = [CCDrawNode node];
                        [_line03 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line03];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line04 = [CCDrawNode node];
                        [_line04 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line04];

                    }
                    else if( deltaX >= 0 && deltaY < 0 ) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol + deltaY; end.y = oldRow - deltaY;
                        CCDrawNode *_line05 = [CCDrawNode node];
                        [_line05 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line05];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        
                        CCDrawNode *_line06 = [CCDrawNode node];
                        [_line06 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line06];

                        
                    }
                    else if( deltaX < 0 && deltaY >= 0) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol + deltaY; end.y = oldRow - deltaY;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];
                    }
                    
                }
                else {
                    if( deltaX >= 0 && deltaY >= 0 )
                    {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaX; end.y = oldRow - deltaX;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];

                        
                    }
                    else if( deltaX < 0 && deltaY < 0) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaX; end.y = oldRow - deltaX;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];

                    }
                    else if( deltaX >= 0 && deltaY < 0 ) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaX; end.y = oldRow + deltaX;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];

                    }
                    else if( deltaX < 0 && deltaY >= 0) {
                        start.x = oldCol; start.y = oldRow;
                        end.x = oldCol - deltaX; end.y = oldRow + deltaX;
                        CCDrawNode *_line01 = [CCDrawNode node];
                        [_line01 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line01];

                        
                        start.x = end.x ; start.y = end.y;
                        end.x = curCol; end.y = curRow;
                        CCDrawNode *_line02 = [CCDrawNode node];
                        [_line02 drawSegmentFrom: start to: end radius: 2.f color: [CCColor whiteColor]];
                        [self addChild:_line02];

                    }

                }
            }
        }
            break;
        case mdMOVE:
            [m_Cousor setVisible:false];
            break;
        default:
            
            break;
    }
    
    
}

-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}



@end
