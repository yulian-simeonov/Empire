

#import "GameView.h"
#import "AppDelegate.h"
#import "empire.h"
#import "mapdata.h"
#import "Player.h"
#import "StartLyr.h"
#import "CmdItem.h"

#define OPCITY  0.5f
#define CELLWIDTH 20.0f

#define TEST_CODE  FALSE

@implementation GameView
+ (CCScene*) scene {
    CCScene *scene = [CCScene node];
    [scene addChild:[GameView node]];
    return scene;
}

-(void)dealloc
{
    [super dealloc];
    [m_move release];
    [m_cityLyr release];
}

- (id) init 
{
    if ((self = [super init])) 
	{
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
        winScaleX = delegate->winScaleX;
        winScaleY = delegate->winScaleY;
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            CGSize size  = [[UIScreen mainScreen] bounds].size;
            if ( size.height == 568 || size.width == 568 ) {
                winScreenX = 568; winScreenY = 320;
            }
            else{
                winScreenX = 480; winScreenY = 320;
            }
        }
        else
        {
            winScreenY = 768; winScreenX = 1024;
        }
        self.userInteractionEnabled = true;

        m_glbMembers = delegate->m_globalMembers;
        m_glbVars = delegate->m_globalVars;
        
        m_blkLyr = [CCNode node];
        [self addChild: m_blkLyr z: 0];
        
        m_landLyr = [CCNode node];
        [self addChild: m_landLyr z: 1];
        
        m_DrawPosArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < MAPSIZE; i++ ) {
            if( m_glbMembers->m_visibleMap[i] )
                [m_DrawPosArr addObject: [NSNumber numberWithInt:i]];
        }
        
        [self LoadResource];
       
        [self drawBackground];
        [self drawButton];
        
        m_nColor = 0;

        m_move = [[move alloc] init];
             
        for (int i = 0; i <= PLYMAX; i++)
        {
            Player* p = m_glbVars->m_player[i];
            [p setDelegate:self];
        }
        
        //city Select Lyr
         m_cityLyr = [[CitySelectionLyr alloc] init];
        [m_cityLyr setPosition:ccp( 0, 400 * winScaleY)];

        [self addChild: m_cityLyr z: 20];
        
        //text 
        m_textSpr = [CCSprite spriteWithImageNamed: [self ResourceName:@"textBk"]];
        float rPosX = [m_textSpr contentSize].width / 2;
        float rPosY = [m_textSpr contentSize].height / 2;
        
        rPosY = (320 - rPosY) * winScaleY;
        rPosX *= winScaleX;
        
        [m_textSpr setPosition: ccp(rPosX, rPosY)];
        [self addChild: m_textSpr z: 12 ];
        [m_textSpr setVisible: false];
        
        float rLine = 15 * winScaleY;
        float rOffY = 320 * winScaleY;
        m_label0 = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12* winScaleY];
        [m_label0 setColor:[CCColor blackColor]];
        [m_label0 setAnchorPoint:ccp( 0.0f, 0.5f)];
        [m_label0 setPosition:ccp(10 * winScaleX, rOffY - rLine )];
        [self addChild:m_label0 z: 13];
        
        m_label1 = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12* winScaleY];
        [m_label1 setColor:[CCColor blackColor]];
        [m_label1 setAnchorPoint:ccp(0.0f, 0.5f)];
        [m_label1 setPosition:ccp( 10 * winScaleX, rOffY - 2 * rLine)];
        [self addChild:m_label1 z: 13];
        
        m_label2 = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12 * winScaleY];
        [m_label2 setColor:[CCColor blackColor]];
        [m_label2 setAnchorPoint:ccp(0.0f, 0.5f)];
        [m_label2 setPosition:ccp(10 * winScaleX, rOffY - 3 * rLine)];
        [self addChild:m_label2 z: 13];
        
        m_label3 = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize: 12* winScaleY];
        [m_label3 setColor:[CCColor blackColor]];
        [m_label3 setAnchorPoint:ccp(0.0f, 0.5f)];
        [m_label3 setPosition:ccp(10 * winScaleX, rOffY - 4 * rLine)];
        [self addChild: m_label3 z: 13];
        
        m_label4  = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12 * winScaleY];
        [m_label4 setColor: [CCColor blackColor]];
        [m_label4 setAnchorPoint:ccp(0.0f, 0.5f)];
        [m_label4 setPosition:ccp(10* winScaleX, rOffY - 5 * rLine)];
        [self addChild: m_label4 z: 13];

        m_glbMembers->m_GameView = self;
        
        m_CmdLyr = [CmdLyr node];
        [m_CmdLyr setPosition:ccp(0, 100 * winScaleY)];
        [m_CmdLyr setDelegate:self];
        
        [self addChild:m_CmdLyr z: 20];
        
        m_SurveyLyr = [SurveyLyr node];
        [self addChild:m_SurveyLyr z:19];
        
        int loc = m_glbVars->m_city[m_glbMembers->m_nSelectedCityIdx]->m_loc;
        int nRow = [empire ROW:loc];
        int nCol = [empire COL:loc];
        
        
        //HB TEST
        
        [m_landLyr setAnchorPoint:ccp(0, 1)];
        CGPoint movePt = CGPointMake(0, 0);
    
        int LocX = 0;
        int LocY = 0;
        
        
        if (TEST_CODE) {
            float cellWidth  = 1024.0f/100;
            float cellHeight = 768.0f/60;
            LocX= nCol * cellWidth;
            LocY= nRow * cellHeight;
        }
        else{
            LocX= nCol * CELLWIDTH;
            LocY= nRow * CELLWIDTH;
        }
        
        //hb
//      if (TEST_CODE)
        {
            if( LocY > winScreenY/2 )
            {
                float deltaY  = winScreenY/2 - LocY;
                float realY = 59 * CELLWIDTH;
                
                if( (realY+deltaY) < winScreenY )
                {
                    float dt  = winScreenY -( realY + deltaY ) + 50;
                    deltaY += dt;
                }
                movePt.y = deltaY;
            }
            else
            {
//                movePt.y = 50.0f;
            }

            if( LocX > winScreenX/2 )
            {
                float deltaX  = winScreenX/2 - LocX;
                float realX = 99 *  CELLWIDTH;

                if( (realX+deltaX) < winScreenX )
                {
                    float dt  = winScreenX -( realX + deltaX ) + 50;
                    deltaX += dt;
                }
                movePt.x = deltaX;
            }
//            else
//                movePt.x = 100;
            

        }
        
        NSLog(@"move X  = %f",  movePt.x );
        NSLog(@"move y = %f", movePt.y);
        
//        if ( LocX > winScreenX ) {
//            movePt.x = winScreenX * (LocX / (int)winScreenX );
//        }
//
//        if ( LocY  > winScreenY ) {
//            movePt.y = winScreenY * (LocY / (int)winScreenY );
//        }
//        
//        movePt.x = - 1 * movePt.x;
//        movePt.y = - 1 * movePt.y;
        
        ///////////////
        [m_landLyr setPosition:movePt];
        
        m_glbMembers->m_rMoveX = m_landLyr.position.x;
        m_glbMembers->m_rMoveY = m_landLyr.position.y;

        [self drawCity];
        [self moveScreen];
        
        [self setVisibleLyr:false];
         m_bThread = true;
        
         m_spOver = [CCSprite spriteWithImageNamed:@"theend.png"];
        [m_spOver setPosition:ccp( 1024/2, 768/2) ];
        [m_spOver setScale:3];
        [self addChild:m_spOver z: 20];
        [m_spOver setVisible:false];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                                 (unsigned long)NULL), ^(void) {
            [self Doit];
        });
        
        m_Blast = [CCSprite spriteWithImageNamed:[self ResourceName:@"blast"]];
        [self addChild: m_Blast z: 30];
        [m_Blast setVisible: false];
         m_BlastLoc = 0;
         m_BlastDur = 0;
        m_nCursolRepeat = 0;
        m_bCursol = false;
        m_nCursolPos    = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveCmd:) name:@"ReceiveCmd" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeletePlayer:) name:@"DeletePlayer" object:nil];
    }
    return self;
}

-(void) setVisibleLyr: (BOOL) bflag
{
    [m_CmdLyr setVisible: bflag];
    [m_landLyr setVisible: bflag];
    
    [m_btnleft setVisible: bflag];
    [m_btnRight setVisible: bflag];
    [m_btnTop setVisible: bflag];
    [m_btnDown setVisible:bflag];
    [m_btnTopleft setVisible:bflag];
    [m_btnTopRight setVisible:bflag];
    [m_btnDownleft setVisible:bflag];
    [m_btnDownRight setVisible:bflag];
    [m_btnSelect setVisible: bflag];
}

- (void)Doit
{
    while (m_bThread) 
    {
        if( [self isGameWin] )
        {
            int k = 0;
            k++;
        }
        else if( [self isGameOver] )
        {
            m_bThread = false;
            [m_spOver setVisible:true];
            [self schedule:@selector(gameOverProcess) interval:2.0f];
        }

        m_glbMembers->m_rMoveX = m_landLyr.position.x; 
        m_glbMembers->m_rMoveY = m_landLyr.position.y;
        
        if( m_glbMembers->m_inited )
            [m_move slice];
        sleep(0.001f);
        
        [self moveScreen];
    }
}

- (void) drawBackground 
{
    
    for (int i = 0; i < 3; i++ )
    {
        for (int j = 0; j < 3; j++ )
        {
            CCSprite * m_back = [CCSprite spriteWithImageNamed:[self ResourceName:@"background"]];
            float originX = -m_back.contentSize.width/2 + m_back.contentSize.width * i - 5 * i;
            float originY = -m_back.contentSize.height/2 + m_back.contentSize.height * j - 5 * j;
            
            [m_back setPosition: ccp( originX, originY )];
            [m_blkLyr addChild:m_back z:0];
        }
    }
}

- (NSString*) getPlayerType: (NSString*) str idx:(int) nIdx
{
    NSString* sTyp = nil;
    switch (nIdx) {
        case 0:
            sTyp = [str stringByAppendingString:@"0"];
            break;
        case 1:
            sTyp = [str stringByAppendingString:@"1"];
            break;
        case 2:
            sTyp = [str stringByAppendingString:@"2"];
            break;
        case 3:
            sTyp = [str stringByAppendingString:@"3"];
            break;
        case 4:
            sTyp = [str stringByAppendingString:@"4"];
            break;
        case 5:
            sTyp = [str stringByAppendingString:@"5"];
            break;
        default:
            break;
    }
    
    return  sTyp;
}

- (void) setVisbleMap
{
    if( m_glbMembers->m_bLoadFlag )
    {
        m_glbMembers->m_bLoadFlag = false;
        return;
    }
    
    [m_DrawPosArr removeAllObjects];
    memset(m_glbMembers->m_visibleMap, 0, sizeof(BOOL) * 6000);
    
    if( cursol != nil )
    {
        [cursol removeFromParent]; cursol = nil;
    }
    
    Player * ply = m_glbVars->m_player[m_glbMembers->m_playerNum];
    //unit 
    for (int i = 0; i < m_glbVars->m_unitop; i++ ) {
        Unit * unit = m_glbVars->m_unit[i];
        if(TEST_CODE)
        {
            if( unit->m_own == 1 || unit->m_own == 2 )
            {
                int loc = unit->m_loc;
                for ( int j = -1; j <= 7; j++) {
                    int arrowloc = loc + [ m_glbVars arrow: j ];
                    if( loc < 0 || loc > 5999 )
                        continue;
                    if( m_glbMembers->m_visibleMap[arrowloc] == false )
                    {
                        [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc]];
                        m_glbMembers->m_visibleMap[arrowloc] = true;
                    }
                    else
                    {
                        if( m_glbVars->m_map[arrowloc] != m_glbMembers->m_tempMapData[arrowloc] )
                        {
                            [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        }
                    }
                }
            }
            
        }
        else
        {
            if( unit->m_own == ply->m_num )
            {
                int loc = unit->m_loc;
                for ( int j = -1; j <= 7; j++) {
                    int arrowloc = loc + [ m_glbVars arrow: j ];
                    if( loc < 0 || loc > 5999 )
                        continue;
                    if( m_glbMembers->m_visibleMap[arrowloc] == false )
                    {
                        [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc]];
                        m_glbMembers->m_visibleMap[arrowloc] = true;
                    }
                    else
                    {
                        if( m_glbVars->m_map[arrowloc] != m_glbMembers->m_tempMapData[arrowloc] )
                        {
                            [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        }
                    }
                }
            }

        }
    }
    
//city
    for (int i = 0; i < CITMAX; i++ )
    {
        City * city = m_glbVars->m_city[i];
        if (TEST_CODE) {
            if( city->m_own == 1 || city->m_own == 2 )
            {
                int loc = city->m_loc;
                for ( int j = -1; j <= 7; j++ ) {
                    int arrowloc = loc +  [m_glbVars arrow:j ];
                    if( loc < 0 || loc > 5999 )
                        continue;
                    if( m_glbMembers->m_visibleMap[arrowloc] == false )
                    {
                        [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        m_glbMembers->m_visibleMap[arrowloc] = true;
                    }
                    else {
                        if( m_glbVars->m_map[arrowloc] != m_glbMembers->m_tempMapData[arrowloc] )
                        {
                            [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        }
                    }
                }
            }
        }
        else{
            if( city->m_own == ply->m_num )
            {
                int loc = city->m_loc;
                for ( int j = -1; j <= 7; j++ ) {
                    int arrowloc = loc +  [m_glbVars arrow:j ];
                    if( loc < 0 || loc > 5999 )
                        continue;
                    if( m_glbMembers->m_visibleMap[arrowloc] == false )
                    {
                        [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        m_glbMembers->m_visibleMap[arrowloc] = true;
                    }
                    else {
                        if( m_glbVars->m_map[arrowloc] != m_glbMembers->m_tempMapData[arrowloc] )
                        {
                            [m_DrawPosArr addObject:[NSNumber numberWithInt:arrowloc] ];
                        }
                    }
                }
            }

        }
    }
   
    for (int i = 0; i < MAPSIZE; i++ ) {
        if( (m_glbVars->m_map[i] != m_glbMembers->m_tempMapData[i]) && m_glbMembers->m_visibleMap[i] )
        {
            [m_DrawPosArr addObject:[NSNumber numberWithInt:i] ];
        }
        m_glbMembers->m_tempMapData[i] = m_glbVars->m_map[i];
    }
    
}


- (void) DeletePlayer:(NSNotification*) note
{
    CmdItem *item = [note object];
    [self deletePlayer: item->numPlay ];
    
    if ( m_glbMembers->m_numPlayers == 2) {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Player Exit this game." message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert1 show];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if(buttonIndex==0){
//        // do something
//    }
    
    [self GoMainMenu];
}

- (void) deletePlayer:( int) plyNum
{
    Player * ply = m_glbVars->m_player[plyNum];
    for (int i = 0; i < CITMAX; i++ )
    {
        City * city = m_glbVars->m_city[i];
        
        if( city->m_own == ply->m_num )
        {
            city->m_own = 0;
            city->m_phs = -1;
        }
    }
    
    //unit
    for (int i = 0; i < m_glbVars->m_unitop; i++ ) {
        Unit * unit = m_glbVars->m_unit[i];
        if( unit->m_own == ply->m_num )
        {
            [ply Killit:unit];
        }
    }
    
    
}



- (BOOL) isGameWin
{
    int l,m;
     l = 0, m = 0;
    for (int i = 0; i < m_glbVars->m_unitop; i++ )
    {
        Unit * unit = m_glbVars->m_unit[i];
        if( unit->m_own == m_glbVars->m_plynum )
        {
            l ++;
        }
    }
    for (int i = 0; i < CITMAX; i++ )
    {
        City * city = m_glbVars->m_city[i];
        if( city->m_own == m_glbVars->m_plynum )
        {
           m ++;
        }
    }
    if( l == m_glbVars->m_unitop && m_glbVars->m_cittop == m )
        return true;
    return false;
}

- (BOOL) isGameOver
{
    int l,m;
    l = 0;m=0;
    for (int i = 0; i < m_glbVars->m_unitop; i++ ) {
        Unit * unit = m_glbVars->m_unit[i];
        if( unit->m_own != m_glbVars->m_plynum )
        {
            l ++;
        }
    }
    for (int i = 0; i < CITMAX; i++ )
    {
        City * city = m_glbVars->m_city[i];
        if( city->m_own != m_glbVars->m_plynum )
        {
            m ++;
        }
        
    }
    if( l == m_glbVars->m_unitop && m_glbVars->m_cittop == m )
        return true;
    return false;

}

- (void) drawCity
{
    dispatch_async(dispatch_get_main_queue(), ^{

        if ( TEST_CODE ) {
            
            float cellWidth  = 1024.0f/100;
            float cellHeight = 768.0f/60;
            
            [self setVisbleMap];
            
            
            float rCellWidth = cellWidth ;
            float rCellHeight = cellHeight ;
            float rOffsetX = cellWidth / 2;
            float rOffsetY = cellHeight / 2;
            
            Player* player = m_glbVars->m_player[ m_glbMembers->m_playerNum];
            m_nCursolPos = player->m_curloc;
            
            if (m_glbVars->m_unitop == 0 || m_glbVars->m_unitop == 1 ) {
                cursol  = [CCSprite spriteWithImageNamed:@"land.png"];
            }
            
            for(NSNumber* item in [m_DrawPosArr copy])
            {
                int i = [item intValue];
                
                int col, row;
                col = i % 100;
                row = i / 100;
                
                if ( row == 0 || row == 59 || col == 0 || col == 99)
                {
                    continue;
                }
                
                float rRow = cellWidth / 2  + row * cellWidth;
                float rCol = cellHeight / 2  + col * cellHeight;
                
                rRow +=  m_glbMembers->m_rMoveY;
                rCol +=  m_glbMembers->m_rMoveX;
                
                CCSprite * sprite = [CCSprite spriteWithTexture:[self getImgMapData:i].texture];
                if ( !sprite ) {
                    
                }
                [sprite setPosition:ccp( rOffsetX + rCellWidth * col, rOffsetY + rCellHeight * row )];
                
                
                float width =  sprite.contentSize.width;
                float height = sprite.contentSize.height;
                
                [sprite setScaleX: cellWidth/width];
                [sprite setScaleY: cellHeight/height];
                
                [m_landLyr addChild:sprite z:0];
            }
            [self getImgMapData:m_nCursolPos];
            
            float width =  25;
            float height = 25;
            
            int nVal = 0;
            nVal = m_glbVars->m_map[m_nCursolPos];
            int type = m_glbVars->m_typ[nVal];
            if (type == X) {
                cursol  = [CCSprite spriteWithImageNamed:@"land.png"];
            }
            
            if ( cursol != nil ) {
//                [cursol removeFromParent]; cursol = nil;
                [cursol setScaleX: cellWidth/width];
                [cursol setScaleY: cellHeight/height];
                float curPosX = rOffsetX + rCellWidth * [empire COL:m_nCursolPos];
                float curPosY = rOffsetY + rCellHeight * [empire ROW:m_nCursolPos];
                [cursol setPosition: ccp( curPosX, curPosY)];
                //        [cursol setTag:13];
                [m_landLyr addChild:cursol z:2];
                
                cursol.visible = YES;
                CCActionFadeIn* fadeIn = [CCActionFadeIn actionWithDuration:0.5f];
                CCActionFadeOut* fadeOut = [CCActionFadeOut actionWithDuration:0.5f];
                CCActionSequence *pulseSequence = [CCActionSequence actions:fadeIn, fadeOut, nil];
                CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:pulseSequence];
                [cursol runAction:repeat];
            }

        }
        else
        {
            [self setVisbleMap];
            float rCellWidth = CELLWIDTH ;
            float rCellHeight = CELLWIDTH ;
            float rOffsetX = CELLWIDTH / 2;
            float rOffsetY = CELLWIDTH / 2;
            
            Player* player = m_glbVars->m_player[m_glbMembers->m_playerNum];
            m_nCursolPos = player->m_curloc;
            
            if (m_glbVars->m_unitop == 0 || m_glbVars->m_unitop == 1 ) {
                cursol  = [CCSprite spriteWithImageNamed:@"land.png"];
            }
            
            for(NSNumber* item in [m_DrawPosArr copy])
            {
                int i = [item intValue];
                
                int col, row;
                col = i % 100;
                row = i / 100;
                
                if ( row == 0 || row == 59 || col == 0 || col == 99)
                {
                    continue;
                }
                
//                float rRow = CELLWIDTH / 2  + row * CELLWIDTH;
//                float rCol = CELLWIDTH / 2  + col * CELLWIDTH;
//                
//                rRow +=  m_glbMembers->m_rMoveY;
//                rCol +=  m_glbMembers->m_rMoveX;
                
                CCSprite * sprite = [CCSprite spriteWithTexture:[self getImgMapData:i].texture];
                if ( !sprite ) {
                    
                }
                [sprite setPosition:ccp( rOffsetX + rCellWidth * col, rOffsetY + rCellHeight * row )];
                
                
                float width =  sprite.contentSize.width;
                float height = sprite.contentSize.height;
                
                [sprite setScaleX: CELLWIDTH/width];
                [sprite setScaleY: CELLWIDTH/height];
                
                [m_landLyr addChild:sprite z:0];
            }
            [self getImgMapData:m_nCursolPos];
            
            float width =  25;
            float height = 25;
            
            int nVal = 0;
            nVal = m_glbVars->m_map[m_nCursolPos];
            int type = m_glbVars->m_typ[nVal];
            if (type == X) {
                cursol  = [CCSprite spriteWithImageNamed:@"land.png"];
            }

            if ( cursol ) {
                [cursol setScaleX: CELLWIDTH/width];
                [cursol setScaleY: CELLWIDTH/height];
                float curPosX = rOffsetX + rCellWidth * [empire COL:m_nCursolPos];
                float curPosY = rOffsetY + rCellHeight * [empire ROW:m_nCursolPos];
                [cursol setPosition: ccp( curPosX, curPosY)];
            
                [m_landLyr addChild:cursol z:2];

                cursol.visible = YES;
                CCActionFadeIn* fadeIn = [CCActionFadeIn actionWithDuration:0.5f];
                CCActionFadeOut* fadeOut = [CCActionFadeOut actionWithDuration:0.5f];
                CCActionSequence *pulseSequence = [CCActionSequence actions:fadeIn, fadeOut, nil];
                CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:pulseSequence];
                [cursol runAction:repeat];
            }
        }
    });
}

- (void) showCursol:(id) sender
{
    [cursol setVisible:true];
}

- (void) unShowCursol:(id) sender
{
    [cursol setVisible:false];
}

-(void)LoadResource
{
    m_sea = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"sea.png"]] retain];
    m_land = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"land.png"]] retain];
    for (int i = 0; i < 6; i++)
    {
        m_city[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"city%d.png", i+1]] retain];
        m_army[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"tank%d.png", i+1]] retain];
        m_flighter[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"flighter%d.png", i+1]] retain];
        m_fs[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"fs%d.png", i+1]] retain];
        m_destroyer[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"destroyer%d.png", i+1]] retain];
        m_transport[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"transport%d.png", i+1]] retain];
        m_submarine[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"submarine%d.png", i+1]] retain];
        m_cruiser[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"cruiser%d.png", i+1]] retain];
        m_carrier[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"carrier%d.png", i+1]] retain];
        m_battleship[i] = [[CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"battleship%d.png", i+1]] retain];
    }
}

- (CCSprite*) getImgMapData : (int) loc
{
    CCSprite* retSprite = nil;
    int nVal = 0;
    nVal = m_glbVars->m_map[loc];
    int type = m_glbVars->m_typ[nVal];
    int plyNumber = m_glbVars->m_own[nVal];
    
    switch (type) {
        case J:
        {
            switch (nVal) {
                case MAPsea:
                {
                    retSprite = m_sea;
                    break;
                }
                case MAPland:
                {
                    retSprite = m_land;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case X:
        {
            retSprite = m_city[plyNumber];
            if ( loc == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"land.png"];
            }
            break;
        }
        case A:
        {
            retSprite = m_army[plyNumber];
            if ( loc == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"land.png"];
            }
            break;
        }
        case F:
        {
            int fType = (nVal - 4) % 10;
            if (fType == 2)
            {
                retSprite = m_flighter[plyNumber];
                if ( loc == m_nCursolPos ) {
                    cursol = [CCSprite spriteWithImageNamed:@"land.png"];
                }

            }
            else if (fType == 3)
            {
                retSprite = m_fs[plyNumber];
                if ( loc == m_nCursolPos ) {
                    cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
                }

            }
            break;
        }
        case D:
        {
            retSprite = m_destroyer[plyNumber];
            if ( loc  == m_nCursolPos )
            {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        case T:
        {
            retSprite = m_transport[plyNumber];
            if ( loc == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        case S:
        {
            retSprite = m_submarine[plyNumber];
            if ( loc == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        case R:
        {
            retSprite = m_cruiser[plyNumber];
            if ( loc == m_nCursolPos) {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        case C:
        {
            retSprite = m_carrier[plyNumber];
            if ( loc == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        case B:
        {
            retSprite = m_battleship[plyNumber];
            if ( loc  == m_nCursolPos ) {
                cursol = [CCSprite spriteWithImageNamed:@"sea.png"];
            }
            break;
        }
        default:
        {
            assert(0);
            break;
        }
    }
    return retSprite;
}

- (void) drawButton
{
    CCSprite * leftNormal = [CCSprite spriteWithImageNamed:[self ResourceName: @"1"]];
    CCSprite * leftSelect = [CCSprite spriteWithImageNamed: [self ResourceName:@"1"]];
    CCSprite * leftAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"1"]];
    
    [leftNormal setColor:[CCColor whiteColor]];
    [leftSelect setColor:[CCColor whiteColor]];
    [leftAvail setColor:[CCColor whiteColor]];

    m_btnleft = [CCButton buttonWithTitle:nil spriteFrame:leftNormal.spriteFrame highlightedSpriteFrame:leftSelect.spriteFrame disabledSpriteFrame:leftAvail.spriteFrame];
    [m_btnleft setTarget:self selector:@selector(actionLeft:)];
    
    [m_btnleft setPosition: ccp( 390 * winScaleX, 60 * winScaleY )];
    [m_btnleft setColor:[CCColor whiteColor]];
    [m_btnleft setOpacity: OPCITY];
    
    CCSprite *rightNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"2"]];
    CCSprite *rightSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"2"]];
    CCSprite *rightAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"2"]];
    
    [rightNormal setColor:[CCColor whiteColor]];
    [rightSelect setColor:[CCColor whiteColor]];
    [rightAvail setColor:[CCColor whiteColor]];
    
    m_btnRight = [CCButton buttonWithTitle:nil spriteFrame:rightNormal.spriteFrame highlightedSpriteFrame:rightSelect.spriteFrame disabledSpriteFrame:rightAvail.spriteFrame];
    [m_btnRight setTarget:self selector:@selector(actionRight:)];
    
    [m_btnRight setPosition:ccp(450 * winScaleX, 60 * winScaleY)];
    [m_btnRight setColor:[CCColor whiteColor]];
    [m_btnRight setOpacity:OPCITY];
    
    CCSprite *topNormal = [CCSprite spriteWithImageNamed: [self ResourceName:@"4"]];
    CCSprite *topSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"4"]];
    CCSprite *topAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"4"]];
    
    [topNormal setColor:[CCColor whiteColor]];
    [topSelect setColor:[CCColor whiteColor]];
    [topAvail setColor:[CCColor whiteColor]];
    
    m_btnTop = [CCButton buttonWithTitle:nil spriteFrame:topNormal.spriteFrame highlightedSpriteFrame:topSelect.spriteFrame disabledSpriteFrame:topAvail.spriteFrame];
    [m_btnTop setTarget:self selector:@selector(actionTop:)];
    
    [m_btnTop setPosition: ccp( 420 *winScaleX, 90 * winScaleY)];
    [m_btnTop setOpacity: OPCITY];
    [m_btnTop setColor:[CCColor whiteColor]];
    
    CCSprite *downNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"3"]];
    CCSprite *downSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"3"]];
    CCSprite *downAvail = [CCSprite spriteWithImageNamed: [self ResourceName:@"3"]];
    
    [downNormal setColor:[CCColor whiteColor]];
    [downSelect setColor:[CCColor whiteColor]];
    [downAvail setColor:[CCColor whiteColor]];

    m_btnDown = [CCButton buttonWithTitle:nil spriteFrame:downNormal.spriteFrame highlightedSpriteFrame:downSelect.spriteFrame disabledSpriteFrame:downAvail.spriteFrame];
    [m_btnDown setTarget:self selector:@selector(actionDown:)];
    
    [m_btnDown setPosition:ccp( 420*winScaleX,30*winScaleY)];
    [m_btnDown setOpacity:OPCITY];
    [m_btnDown setColor:[CCColor whiteColor]];
    
    CCSprite *topleftNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"5"]];
    CCSprite *topleftSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"5"]];
    CCSprite *topleftAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"5"]];
    
    [topleftNormal setColor:[CCColor whiteColor]];
    [topleftAvail setColor:[CCColor whiteColor]];
    [topleftSelect setColor:[CCColor whiteColor]];

    m_btnTopleft = [CCButton buttonWithTitle:nil spriteFrame:topleftNormal.spriteFrame highlightedSpriteFrame:topleftSelect.spriteFrame disabledSpriteFrame:topleftAvail.spriteFrame];
    [m_btnTopleft setTarget:self selector:@selector(actionTopleft:)];
    
    [m_btnTopleft setPosition:ccp(390*winScaleX, 90 * winScaleY)];
    [m_btnTopleft setOpacity: OPCITY ];
    [m_btnTopleft setColor:[CCColor whiteColor]];
    
    CCSprite *topRightNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"8"]];
    CCSprite *topRightSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"8"]];
    CCSprite *topRightAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"8"]];
    
    [topRightAvail setColor:[CCColor whiteColor]];
    [topRightNormal setColor:[CCColor whiteColor]];
    [topRightSelect setColor:[CCColor whiteColor]];

    m_btnTopRight = [CCButton buttonWithTitle:nil spriteFrame:topRightNormal.spriteFrame highlightedSpriteFrame:topRightSelect.spriteFrame disabledSpriteFrame:topRightAvail.spriteFrame];
    [m_btnTopRight setTarget:self selector:@selector(actionTopRight:)];
    
    [m_btnTopRight setPosition:ccp(450*winScaleX, 90*winScaleY)];
    [m_btnTopRight setOpacity: OPCITY];
    [m_btnTopRight setColor:[CCColor whiteColor]];
    
    CCSprite *downleftNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"7"]];
    CCSprite *downleftSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"7"]];
    CCSprite *downleftAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"7"]];
    
    [downleftAvail setColor:[CCColor whiteColor]];
    [downleftNormal setColor:[CCColor whiteColor]];
    [downleftSelect setColor:[CCColor whiteColor]];
    
    m_btnDownleft = [CCButton buttonWithTitle:nil spriteFrame:downleftNormal.spriteFrame highlightedSpriteFrame:downleftSelect.spriteFrame disabledSpriteFrame:downleftAvail.spriteFrame];
    [m_btnDownleft setTarget:self selector:@selector(actionDownLeft:)];
    [m_btnDownleft setPosition:ccp( 390* winScaleX, 30*winScaleY)];
    [m_btnDownleft setOpacity:OPCITY];
    [m_btnDownleft setColor:[CCColor whiteColor]];
    
    CCSprite *downRightNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"6"]];
    CCSprite *downRightSelect = [CCSprite spriteWithImageNamed:[self ResourceName:@"6"]];
    CCSprite *downRightAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"6"]];
   
    [downRightNormal setColor:[CCColor whiteColor]];
    [downRightAvail setColor:[CCColor whiteColor]];
    [downRightSelect setColor:[CCColor whiteColor]];
    
    m_btnDownRight = [CCButton buttonWithTitle:nil spriteFrame:downRightNormal.spriteFrame highlightedSpriteFrame:downRightSelect.spriteFrame disabledSpriteFrame:downRightAvail.spriteFrame];
    [m_btnDownRight setTarget:self selector:@selector(actionDownRight:)];
    [m_btnDownRight setPosition:ccp(450*winScaleX, 30*winScaleY)];
    [m_btnDownRight setOpacity:OPCITY];
   
    
    CCSprite * selectNormal = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_skip"]];
    CCSprite * select = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_skip"]];
    CCSprite * selectAvail = [CCSprite spriteWithImageNamed:[self ResourceName:@"btn_skip"]];
    
    [selectAvail setColor:[CCColor whiteColor]];
    [select setColor:[CCColor whiteColor]];
    [selectNormal setColor:[CCColor whiteColor]];
    
    m_btnSelect = [CCButton buttonWithTitle:nil spriteFrame:selectNormal.spriteFrame highlightedSpriteFrame:select.spriteFrame disabledSpriteFrame:selectAvail.spriteFrame];
    [m_btnSelect setTarget:self selector:@selector(actionSelect:)];
    [m_btnSelect setPosition:ccp(50*winScaleX, 30*winScaleY)];
    [m_btnSelect setOpacity:OPCITY];
    
    [self addChild:m_btnleft z:11];
    [self addChild:m_btnRight z:11];
    [self addChild:m_btnTop z:11];
    [self addChild:m_btnDown z:11];
    [self addChild:m_btnTopRight z:11];
    [self addChild:m_btnTopleft z:11];
    [self addChild:m_btnDownleft z:11];
    [self addChild:m_btnDownRight z:11];
    [self addChild:m_btnSelect z:11];
}

-(NSString*)ResourceName:(NSString*)orgString
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [NSString stringWithFormat:@"%@_iPad.png", orgString];
    else
        return [NSString stringWithFormat:@"%@.png", orgString];
}

-(void) actionLeft:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
            if( nCol != 0 )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:Left];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = Left;
            [self GiveAction:Left];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:Left];
    [self moveScreen];
}

-(void) actionRight:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
            if(  nCol != Mcolmx )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:Right];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = Right;
            [self GiveAction:Right];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:Right];  
    [self moveScreen];  
}

-(void) actionTop:(id)sender
{
         
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            if( nRow != Mrowmx )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:Top];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = Top;
            [self GiveAction:Top];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:Top];
    [self moveScreen];
}

-(void) actionDown:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            if( nRow != 0 )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:Bottom];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = Bottom;
            [self GiveAction:Bottom];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:Bottom];    
    [self moveScreen];
}

-(void) actionTopleft:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
            int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            if( nRow != Mrowmx && nCol != 0 )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:LeftTop];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = LeftTop;
            [self GiveAction:LeftTop];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:LeftTop];
    [self moveScreen];
}

-(void) actionTopRight:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
             int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            if( nRow != Mrowmx  && nCol != Mcolmx )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:RightTop];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = RightTop;
            [self GiveAction:RightTop];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:RightTop];
    [self moveScreen];
}

-(void) actionDownLeft:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:
        {
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
             int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            
            if( nRow != 0  && nCol != 0 )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:LeftBottom];
            
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = LeftBottom;            
            [self GiveAction:LeftBottom];
            [self GiveAction:Direction];
            m_glbMembers->m_CmdMode = mdMOVE;
            
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:LeftBottom];
    [self moveScreen];
}

-(void) actionDownRight:(id)sender
{
    switch (m_glbMembers->m_CmdMode) {
        case mdMOVE:
            break;
        case mdSURV:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
        {          
            m_glbMembers->m_CmdMode = mdSURV;
            int nCol = [empire COL:m_glbMembers->m_Surveyloc ];
            int nRow = [empire ROW:m_glbMembers->m_Surveyloc ];
            if( nCol != Mcolmx  && nRow != 0 )
                m_glbMembers->m_Surveyloc += [m_glbVars arrow:RightBottom];
        }
            break;
        case mdDIR:
        {
            m_glbMembers->m_prevCmdMode = RightBottom;
            [self GiveAction:RightBottom];
            [self GiveAction:Direction];

            m_glbMembers->m_CmdMode = mdMOVE;
            return;
        }
            break;
        case mdTO:
            break;
        default:
            break;
    }
    [self GiveAction:RightBottom];
    [self moveScreen];
}

-(void) actionSelect:(id)sender
{
    [self GiveAction:Skip];
}

-(void)GiveAction:(enum CmdType)actionValue
{
    for ( int i = 0; i <= m_glbVars->m_numply; i++ ) 
    {
        Player *p = (Player*)(m_glbVars->m_player[i]);
        if( p->m_playerType == Human && p->m_num == m_glbMembers->m_playerNum )
        {
            [p->m_cmdQueue enqueue:[NSNumber numberWithInt:actionValue]];
            int nRand  = 0;
            if (( arc4random() % 60) >= 30 ) {
                nRand = 1;
            }
            m_glbMembers->m_nRand = nRand;
            [m_glbMembers SendCmd:actionValue command: p->m_num random:nRand];
            break;
        }
    }
}

- (void) ReceiveCmd:(NSNotification*) note
{
    CmdItem *item = [note object];
    [self GiveAction:item->cmdType playNum:item->numPlay];
}

-(void)GiveAction:(enum CmdType)actionValue playNum:(int) idx
{
    Player *p = (Player*)(m_glbVars->m_player[idx]);
    [p->m_cmdQueue enqueue:[NSNumber numberWithInt:actionValue]];
}


- (void)GoMainMenu
{
    m_bThread = false;
    [self unscheduleAllSelectors];
    [[CCDirector sharedDirector] replaceScene: [StartLyr scene]];
    
    [m_glbMembers SendExitCmd: m_glbMembers->m_playerNum];
}

- (void) gameOverProcess
{
    [self GoMainMenu];
}

- (void) showSelectDlg
{
    id action = [CCActionSequence actions:
                 [CCActionEaseElasticInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.5f position:ccp( 0 * winScaleX, 0 * winScaleY )] period:0.5f],
                 nil];
    [m_cityLyr runAction:action];
}

- (void) moveScreen
{
    if (TEST_CODE) {
        return;
    }
    Player* player  = m_glbVars->m_player[m_glbMembers->m_playerNum];
    
    if( player->m_curloc == 0)
        return;
    
    int loc = 0;
    if( player->m_mode != mdSURV )
        loc = player->m_curloc;
    else {
        loc = m_glbMembers->m_Surveyloc;
    }
    
    float rRow = CELLWIDTH/2 + [empire ROW:loc] * CELLWIDTH;
    float rCol = CELLWIDTH/2 + [empire COL:loc] * CELLWIDTH;

    rRow += m_landLyr.position.y;
    rCol += m_landLyr.position.x;
    
    CGPoint point = CGPointMake(rCol + CELLWIDTH * 3/2, rRow + CELLWIDTH * 3/2);
    
    CGRect m_ScreenRect = CGRectMake(CELLWIDTH * 7/2, CELLWIDTH * 7/2, 480* winScaleX -CELLWIDTH * 7/2 , 320 * winScaleY - CELLWIDTH * 7/2);
    
    CGPoint origin = m_landLyr.position;
    
    CGPoint pt  = m_blkLyr.position;
    
    if( !CGRectContainsPoint(m_ScreenRect, point) )
    {
        if( point.x < CELLWIDTH * 7/2  )
        {
            origin.x += CELLWIDTH * 7/2 -  point.x;
            pt.x += CELLWIDTH * 7/2 -  point.x;
        }
        if( point.x > (480 * winScaleX - CELLWIDTH) )
        {
            origin.x -= point.x - 480 * winScaleX;
            pt.x -=  point.x - 480 * winScaleX;
        }
        if( point.y < CELLWIDTH * 7/2 )
        {
            origin.y += CELLWIDTH * 7/2  - point.y;
            pt.y += CELLWIDTH * 7/2  - point.y;
        }
        if( point.y > 320 * winScaleY )
        {
            origin.y -= point.y - 320 * winScaleY;
            pt.y -= point.y - 320 * winScaleY;
        }
        
        [m_blkLyr setPosition:pt];
        [m_landLyr setPosition:origin];
    }
    
}


- (void) setLabelString
{
    for (int i = 0; i < 5; i++)
    {
        NSString * str = [NSString stringWithCString:m_glbMembers->m_vbuffer[i] encoding: NSUTF8StringEncoding];
        switch ( i ) {
            case 0:
                [m_label0 setString:str];
                break;
            case 1:
                [m_label1 setString:str];
                break;
            case 2:
                [m_label2 setString:str];
                break;
            case 3:
                [m_label3 setString:str];
                break;
            case 4:
                [m_label4 setString:str];
                break;
            default:
                break;
        }
    }
}

- (void) showBlast : (int) loc
{
    m_BlastLoc = loc;
    
    int col, row;
    col = loc % 100;
    row = loc / 100;
    
    float rRow = CELLWIDTH/2 + row * CELLWIDTH;
    float rCol = CELLWIDTH/2 + col * CELLWIDTH;
    
    rRow +=  m_glbMembers->m_rMoveY;
    rCol +=  m_glbMembers->m_rMoveX;

    [m_Blast setPosition:ccp( rCol, rRow )];
    if( m_glbMembers->m_visibleMap[loc] )
        [m_Blast setVisible: true];    
//    [self schedule:@selector(actionBlast) interval:0.1f];
    
    CCActionFadeIn* fadeIn = [CCActionFadeIn actionWithDuration:0.5f];
    CCActionFadeOut* fadeOut = [CCActionFadeOut actionWithDuration:0.5f];
    CCActionSequence *pulseSequence = [CCActionSequence actions:fadeIn, fadeOut, nil];
    [m_Blast runAction:pulseSequence];
}


- (void) actionBlast
{
    m_BlastDur ++ ;
    if( m_BlastDur >= 10 )
    {
        m_BlastDur = 0;
        [m_Blast setVisible: false];
        [self unschedule:@selector(actionBlast)];
    }
}

@end
