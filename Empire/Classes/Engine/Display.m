//
//  Display.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Display.h"
#import "Unit.h"
#import "AppDelegate.h"
#import "Player.h"
#import "OALSimpleAudio.h"
#import "GameView.h"

@implementation Display

- (id) init
{
    if( self = [super init])
    {
        m_text = [[text alloc] init];
        m_mapManager = [[ maps alloc] init];
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_glbMember = delegate->m_globalMembers;
        m_globalVar = delegate->m_globalVars;
        
        [self initialize];
        
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
    [m_text release];
    [m_mapManager release];
}
/***********************************
 * Clear the current sector that's showing.
 */

-(void) clrsec
{
    m_secbas =1;          // indicate screen is blank
}


/***************************
 * Print out map value at loc.
 */

-(void) mapprt:(loc_t) loc
{
//    if (!m_text->m_watch) return;
//    assert(loc < MAPSIZE);
//    if (![self insect:loc location: 0]) return;		// if not in current sector
    
 // [self invalidateLoc:(loc)];
}


/***************************
 * Return true if loc is in the current sector showing,
 * with a border of n spaces. If the sector edge lies on
 * a map edge, the n spaces do not apply for that edge.
 * Return false if secbas[] = -1.
 */

-(int) insect:(loc_t) loc location:(uint) n
{
    int br,bc,lr,lc;
    int x;
    int sb;
    Display *d = self;
    
    assert(loc < MAPSIZE && n < 100);
    sb = d->m_secbas;
    if (sb == -1)
        return false;
    br = sb / (Mcolmx + 1);
    bc = sb % (Mcolmx + 1);
    
    lr = loc / (Mcolmx + 1);
    lc = loc % (Mcolmx + 1);
    
    x = (br) ? br + n : br;		// min row we can be on
    if (lr < x) return false;
    
    x = (bc) ? bc + n : bc;		// min col we can be on
    if (lc < x) return false;
    
    br += (d->m_Smax - d->m_Smin) >> 8;
    bc += (d->m_Smax - d->m_Smin) & 0xFF;
    
    x = (br != Mrowmx) ? br - n : br;	// max row we can be on
    if (lr > x) return false;
    
    x = (bc != Mcolmx) ? bc - n : bc;	// max col we can be on
    return lc <= x;
    return 1;
}

/************************************
 * Adjust loc so it makes a valid sector base.
 */

-(loc_t) adjust:(loc_t) loc
{
 
    int row,col,size,rowsize,colsize;
    Display *d = self;
    
    row = [empire ROW:loc];
    col = [empire COL:loc];
    if (col == Mcolmx)			// kludge to fix wrap-around
    {   col = 0;
        row++;
    }
    size = d->m_Smax - d->m_Smin;			// display size
    rowsize = size >> 8;			// # of rows - 1
    colsize = size & 0xFF;
    if (row < 0) row = 0;
    if (row > Mrowmx - rowsize) row = Mrowmx - rowsize;
    if (col < 0) col = 0;
    if (col > Mcolmx - colsize) col = Mcolmx - colsize;
    return (row * (Mcolmx + 1) + col);	// return adjusted value
    
}

-(void) initialize
{

    m_text->m_watch = true;
    m_text->m_TTtyp = 0;
    m_text->m_cursor = 0;
    m_text->m_speaker = 1;
    m_text->m_Tmax = (23 << 8) + 78;
    
    m_text->m_narrow = 0;
    m_maptab = 0;
    m_timeinterval = 0;
    m_secbas = -1;
    m_Smin = 0x400;
    m_Smax = m_text->m_Tmax - ((1 << 8) + 2);
    
}

-(int) rusure
{
    return 1;
}

-(void) your
{
    [m_text smes:(m_text->m_narrow ? @"Yr " : @"Your ")];
}


-(void) enemy
{
    [m_text smes:(m_text->m_narrow ? @"En " : @"Enemy ")];
}

/**********************
 */

-(void) city_attackown
{
    [m_text cmes:[m_text DS:2] type:@"Attacked your own city!\1\2"];
    [m_text cmes:[m_text DS:3] type:@"\1"];
    if (m_text->m_watch)
    {
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"gun_1.wav" loop:false];
    }
    [m_text cmes:[m_text DS:3] type:@"Your army was executed.\1\2"];
    [self  delay:1];
}

/*****************
 */

-(void) city_repelled:(loc_t) loc
{
    if (m_text->m_watch)
    {
        [m_text TTcurs:[ m_text DS:2]];
        int nRow = [empire ROW:loc];
        int nCol = [empire COL:loc];
        [ m_text vsmes:[NSString stringWithFormat:@"City under attack at %d,%d.", nRow,nCol]];
        [m_text deleol]; // delete to end of line
//        [self    sound_subjugate];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"intro.wav" loop:false];
        [m_text cmes:[ m_text DS:3] type:[NSString stringWithFormat:@"Enemy invasion repelled.\1\2"]];
        [self delay:1];
    }
}

/**********
 * Your city was conquered.
 */

-(void) city_conquered:(loc_t) loc
{
    
    if (m_text->m_watch)
    {
        [m_text TTcurs:[m_text DS:2]];
        [m_text vsmes:[NSString stringWithFormat:@"City is under attack at %d,%d.", [empire ROW:loc], [empire COL:loc] ]];
        [m_text deleol]; 	// delete to end of line
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"explode.wav" loop:false];
        [m_text cmes:[m_text DS:3] type: @"Your city was conquered!\1\2"];
        [self delay:1];
    }
}

/**************************
 */

-(void) city_subjugated
{
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:2] type: @"Attacking city!\1"];

        [m_text cmes:[m_text DS:3] type:@"\1"];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"intro.wav" loop:false];
        if (m_text->m_narrow > 1)
        {
            [m_text cmes:[m_text DS:2] type:@"City subjugated! Army\1"];
            [m_text cmes:[m_text DS:3] type:@"enforces iron control.\1\2"];
        }
        else
        {
            [m_text cmes:[m_text DS:2] type:@"The city has been subjugated! The army\1"];
            [m_text cmes:[m_text DS:3] type:@"was dispersed to enforce iron control.\1\2"];
        }
        [self delay:1];
    }
}

/**************************
 */

-(void) city_crushed
{
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:2] type:@"Attacking city!\1"];
        [m_text cmes:[m_text DS:3] type:@"\1"];
        if( m_text->m_speaker)
            [[OALSimpleAudio sharedInstance] playEffect:@"explode.wav" loop:false];
        if (m_text->m_narrow > 1)
        {
            [m_text cmes:[m_text DS:2] type:@"Your assault crushed!\1"];
            [m_text cmes:[m_text DS:3] type:@"Your army destroyed.\1\2"];
        }
        else
        {
            [m_text cmes:[m_text DS:2] type:( m_text->m_narrow ? @"The city crushed your assault!\1\2" : @"The city's defenses crushed your assault!\1\2" )];
            [m_text cmes:[m_text DS:3] type: @"Your army destroyed.\1\2"];
        }
        [self delay:1 ];
    }
}

/**********************
 * Print number of units destroyed
 */

-(void) killml:(int) type number:(int) num
{
    if (m_text->m_watch)
    {
        [m_text curs:[m_text DS:3]];
        [m_text vsmes:[ NSString stringWithFormat:@"%d %@ destroyed.",num,[self nmes_p:type number:num]]];
        [m_text deleol];
        [self delay:3];
    }
}

/*************************************
 * Overloaded T or C.
 */

-(void) overloaded:(loc_t) loc type:(int) typabd number:(int) numdes
{ 
    if (m_text->m_watch)
    {
        [m_text curs:[m_text DS:2]];
        [m_text vsmes:[NSString stringWithFormat:@"Your ship is overloaded at %d,%d.", [empire ROW:loc], [empire COL:loc] ]];
        [m_text deleol];
        [self killml:typabd number:numdes];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"error.wav" loop:false];
    }
}

/************************************
 * Type out the heading of the unit.
 */

-(void)  headng:(Unit *)u
{
    int type,abd;
    NSString *y;
    NSString *buffer;
    
    if (!m_text->m_watch)
        return;
    [m_text curs:[m_text DS:0]];
    if (u->m_typ == A)
    {
        buffer = [NSString stringWithFormat:@"Your army at %d,%d.", [empire ROW:u->m_loc], [empire COL:u->m_loc] ];
    }
    else
    {
        NSString *  buf;
        
        y = m_text->m_narrow ? @"Yr" : @"Your";
        int nRow = [empire ROW:u->m_loc];
        int nCol = [empire COL:u->m_loc];
        buffer = [NSString stringWithFormat:@"%@ %@ at %d,%d.",y, [self nmes_p:u->m_typ number:1], nRow, nCol ];

        
        if ((type = [m_mapManager tcaf:(u)]) >= 0)		// if we have a T or C
        {   
            NSString * subbuf = nil;
            
            abd = [m_mapManager aboard:u];  // # aboard
            

            subbuf = [NSString stringWithFormat: @" %d ", abd];
            [buffer stringByAppendingString:subbuf];
            [buffer stringByAppendingString:[self nmes_p:type number:abd] ];
            
        }
        if (u->m_typ == F)		// if a fighter
            [buffer stringByAppendingString:@" Range: "];
        else				// else ship
            [buffer stringByAppendingString:@" Hits: "];
        
        buf = [NSString stringWithFormat:@"%d", u->m_hit];
        [buffer stringByAppendingString:buf];

    }

    [m_text smes:buffer];
    [m_text deleol];
    [m_text curs:[m_text DS:1]];
    [self fncprt:u];		// print function
}


/*********************
 * Type out unit message, plural or singular
 */

-(NSString *) nmes_p:(int) type number:(int) num
{
    char *msg[8][2] =
    {   {	"army",			"armies"		},
        {   "fighter",		"fighters"		},
        {   "destroyer",		"destroyers"  },
        {   "troop transport",	"troop transports"	},
        {   "submarine",		"submarines"		},
        {   "cruiser",		"cruisers"		},
        {   "aircraft carrier",	"aircraft carriers"	},
        {   "battleship",		"battleships"		}
    };

    // For narrow displays
    char msgn[8][2][3] =
    {
        {   "A","As" },
        {   "F","Fs" },
        {   "D","Ds" },
        {   "T","Ts" },
        {   "S","Ss" },
        {   "R","Rs" },
        {   "C","Cs" },
        {   "B","Bs" },
    };

    
    if (m_text->m_narrow)
    {
        NSString* str1 = nil; 
        NSString* str2 = nil;
        
        str1 = [NSString stringWithCString:msgn[type][0] encoding:NSUTF8StringEncoding];
        str2 =  [NSString stringWithCString:msgn[type][1] encoding:NSUTF8StringEncoding];
        return (num == 1) ? str1 : str2;
    }
    else
    {
        NSString* str1 = nil;
        NSString* str2 = nil;
        
        str1 = [NSString stringWithCString: msg[type][0] encoding:NSUTF8StringEncoding];
        str2 = [NSString stringWithCString: msg[type][1] encoding:NSUTF8StringEncoding];        
        return (num == 1) ? str1 : str2;
    }

}

-(void) landing:(Unit *)u
{  
    
    if (m_text->m_watch)
    {

        [m_text curs:[m_text DS:1]];

        int nRow = [empire ROW: u->m_loc];
        int nCol = [empire COL: u->m_loc];
        
        [m_text vsmes:[NSString stringWithFormat:@"Landing confirmed at %d,%d.", nRow, nCol]];
        [m_text deleol];
        [self delay:2];
    }
}

-(void) boarding:(Unit *)u
{   
    
    if (m_text->m_watch)
    {
        [m_text curs:[m_text DS:1]];

        int nRow = [empire ROW:u->m_loc];
        int nCol = [empire COL:u->m_loc];
        [m_text vsmes:[NSString stringWithFormat:@"Boarding confirmed at %d,%d.",nRow, nCol]];
        [m_text deleol];
        [self delay:2];
    }
}

-(void) aground:(Unit *)u
{
    if (m_text->m_watch)
    {
        if ( m_text->m_narrow > 1)
            [m_text cmes:[m_text DS:1] type:@"Ship ran aground, sank.\1\2"];
        else
            [m_text cmes:[m_text DS:1] type: @"Your ship ran aground and sank.\1\2"];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"error.wav" loop:false];
    }
}

-(void) armdes:(Unit *)u
{
    if (m_text->m_watch)
        [m_text cmes:[m_text DS:1] type:@"Your army was destroyed.\1\2"];
}

-(void) drown:(Unit *)u
{    
 //   if (m_text->m_watch)
    if(1)
    {
        if (m_text->m_narrow > 1)
        {
            [m_text cmes:[m_text DS:1] type:@"Army marched into sea!\1"];
        }
        else
        {
            [m_text curs:[m_text DS:1]];
            [self your];
            [m_text vsmes:[NSString stringWithFormat:@"%@ marched into the sea and drowned!",[self nmes_p:A number:1]]];
            [m_text imes:@"\1\2"];
        }

        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"splash.wav" loop:false];
    }
}

-(void) shot_down:(Unit *)u
{
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:2] type:@"Fighter attacks city!\1"];

        if( m_text->m_speaker )
        {
            [[OALSimpleAudio sharedInstance] playEffect:@"flyby.wav" loop:false];
            [[OALSimpleAudio sharedInstance] playEffect:@"ackack1.wav" loop:false];
            [[OALSimpleAudio sharedInstance] playEffect:@"ackack1.wav" loop:false];
        }
        [m_text cmes:[m_text DS:3] type:@"Fighter shot down!\1"];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"explosi1.wav" loop:false];
    }
}

-(void) no_fuel:(Unit *)u
{ 
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:2] type:@"Fighter ran out of fuel...\1\2"];
        [[OALSimpleAudio sharedInstance] playEffect:@"fuel.wav" loop:false];
        [m_text cmes:[m_text DS:3] type: @"...and crashed!\1\2"];
//        sound_fcrash();
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"explosi1.wav" loop:false];
    }
}

-(void) docking:(Unit *)u location:(loc_t) loc
{
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:1] type:@"Ship docked at \1"];
        [m_text locdot:loc];
        [m_text deleol];
    }
}

/***************************************
 * Unit u is under attack.
 */

-(void) underattack:(Unit *)u
{
    if (m_text->m_watch)
    {   NSString *p;
        
        [m_text curs:[m_text DS:2]];
        p = m_text->m_narrow ? @"Yr" : @"Your";
        int nRow = [empire ROW: u->m_loc];
        int nCol = [empire COL: u->m_loc];
        [m_text vsmes:[NSString stringWithFormat:@"%@ %@ is under attack at %d,%d.",
                      p, [self nmes_p:u->m_typ number:1],nRow, nCol ]];
        
        [m_text deleol];
        [self delay:2];
    }
}

/***************************************
 * Perform battle.
 * Input:
 *	pnum	player number for this display
 *	uwin	winner
 *	ulos	loser
 */

-(void) battle:(Player *)p winner:(Unit *)uwin loser:(Unit *)ulos
{
    NSString* p1;
    NSString* p2;
    
    if (m_text->m_watch)
    {   int abd;
        
        [m_text curs:[m_text DS:2]];
        NSString * str = [NSString stringWithFormat:@"%@%@ destroyed.",[self youene_p:p number: ulos->m_own],[self nmes_p:ulos->m_typ number:1] ];
        
        [m_text vsmes:str];
        [m_text deleol];
        
        abd = [m_mapManager aboard:(ulos)];
        if (abd)
            [self killml:[m_mapManager tcaf:ulos] number:abd ];
        [m_text curs:[m_text DS:3]];
        
        if (uwin->m_typ != A && uwin->m_typ != F)
        {
            p1 = [self youene_p:p number: uwin->m_own ];
            p2 = [self nmes_p:uwin->m_typ number:1];
            if (uwin->m_hit == 1)
                [m_text vsmes:[NSString stringWithFormat:@"%@%@ has 1 hit left",p1,p2]];
            else
                [m_text vsmes:[NSString stringWithFormat:@"%@%@ has %d hits left",p1,p2,uwin->m_hit]];
        }
        [m_text deleol];
        [m_text flush];
        
        [(GameView*)m_glbMember->m_GameView showBlast:ulos->m_loc ];

        switch (ulos->m_typ)
        {
            case A:
            {
                if( m_text->m_speaker )
                    [[OALSimpleAudio sharedInstance] playEffect:@"gun_1.wav" loop:false];
            }
                break;
            case F:
            {
                if( m_text->m_speaker )
                    [[OALSimpleAudio sharedInstance] playEffect:@"ackack1.wav" loop:false];
            }
                break;
            default:
            {
                if( m_text->m_speaker )
                    [[OALSimpleAudio sharedInstance] playEffect:@"bubbles.wav" loop:false];
            }
                break;
        }
        [(GameView*)m_glbMember->m_GameView showBlast:ulos->m_loc ];
    }
}

/*************************************
 */


//-(NSString *) youene_p:(Player *)p number:(int) num
//hb change p->m_num ==> m_num
-(NSString *) youene_p:(Player *)p number:(int) num
{
    if (p->m_num == num)
    {
        return m_text->m_narrow ? @"Yr " : @"Your ";
    }
    else
    {
        return m_text->m_narrow ? @"En " : @"Enemy ";
    }
}

/******************************
 * Notify player that pdef has been defeated.
 */

-(void) plyrcrushed:(Player *)pdef
{
    if (m_text->m_watch)
    {
        [m_text cmes:[m_text DS:2] type:@"Player "];
        [m_text decprt:pdef->m_num];
        [m_text imes:@" has been crushed.\1\2"];
        [m_text curs: [m_text DS:3]];
        [m_text deleol];
        if( m_text->m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"taps.wav" loop:false];
        
        [self delay:4];
    }
}

/***********************************
 * Notify player that he's lost.
 */

-(void) lost
{
    if (m_text->m_watch)
    {   
        [m_text cmes:[m_text DS:0] type: @"The enemy has crushed your feeble forces!\1"];
        [m_text cmes:[m_text DS:1] type: @"Your contemptible dreams of world\1"];
        [m_text cmes:[m_text DS:2] type: @"Empire are finished!\1"];
        [m_text cmes:[m_text DS:3] type: @"\1"];
        [self delay:10];
    }
}

/**************************************
 */

-(void) produce:(City *)c
{
    if (m_text->m_watch)
    {   NSString *p;
        
        [m_text curs:[m_text DS:0]];
        p = (c->m_phs == A || c->m_phs == C ) ? @"n" : @"";
        
        int nRow = [empire ROW: c->m_loc ];
        int nCol = [empire COL: c->m_loc ];
        
        NSString* str = [NSString stringWithFormat:@"City at %d,%d has completed a%@ %@.", nRow, nCol, p, [self nmes_p:c->m_phs number:1] ];
        [m_text vsmes:str];
        [m_text imes:@"\1\2"];
    }
}

/**************************************
 */

-(void) overpop:(int) flag
{
    if (m_text->m_watch)
    {
        [m_text cmes: [m_text DS:2] type: (flag ? @"Overpop" : @"       " )];
    }
}

/**********************************
 * Print function of unit.
 */

-(void) fncprt:(Unit *)u
{
    static char dtab[9] = "DEWQAZXC";	// directions
    Player *p =  m_globalVar->m_player[u->m_own];
    
    if (!m_text->m_watch)			// if not watching this guy
        return;
    switch (p->m_playerType) {
        case Human:
        {
            if (u->m_ifo != fnAW)
                [m_text smes:@"Function: "];
            switch (u->m_ifo)
            {
                case fnAW:
                    //t.smes("None");
                    break;
                case fnSE:
                    [m_text smes:@"Sentry"];
                    break;
                case fnRA:
                    [m_text smes:@"Random"];
                    break;
                case fnMO:
                    [m_text smes:@"Move To "];
                    [m_text locprt:u->m_ila];
                    break;
                case fnDI:
                    [m_text smes:@"Direction = "];
                    [m_text output:dtab[u->m_ila]];
                    break;
                case fnFI:
                    [m_text smes:@"Load "];
                    if (u->m_typ == T)
                        [m_text smes: @"Armies"];
                    else
                        [m_text smes:@"Fighters"];
                    break;
                default:
                    //          assert(0);
                    break;
            }

            break;
        }   
        case NetUser:
        case Computer:
        {
            [m_text smes: @"IFO: "];
            [m_text decprt:u->m_ifo];
            [m_text smes:@" ILA: "];
            [m_text locdot: u->m_ila];

            break;
        }
        default:
            break;
    }
    [m_text deleol];
}

/************************************
 */

-(void) setdispsize:(int)rows col:(int) cols
{
    //PRINTF("Display::setdispsize(rows=%d, cols=%d)\n",rows,cols);
    
//    version (Windows)
//    {
//        version (0)
//        {
//            text.narrow = 0;
//            if (global.cxClient < 75 * 10)
//                text.narrow = 1;
//            if (global.cxClient <= 12 * 10)
//                text.narrow = 2;
//        }
//        else
//        {
//            text.narrow = (cols < 75);	// use 40 column formatting
//            text.narrow = 2;
//        }
//        text.Tmax = (rows - 1) * 256 + cols - 1;
//    }
//    else
//    {
//        text.narrow = (cols < 75);	// use 40 column formatting
//        if (text.narrow)
//            Smin = (5 * 256) + 0;		// u l edge of map
//        else
//            Smin = (4 * 256) + 0;
//        
//        text.Tmax = (rows - 1) * 256 + cols - 1;
//        
//        // Scale back if display is bigger than we can use
//        if (cols > Mcolmx + 1 + 3 - 1)
//            cols = Mcolmx + 1 + 3 - 1;
//        if (rows > 4 + Mrowmx + 1 + 1)
//            rows = 4 + Mrowmx + 1 + 1;
//        
//        Smax = (rows - 2) * 256 + cols - 3;
//    }
}


/********************************
 * Position cursor where loc is.
 */

-(void) pcur:(loc_t) loc
{
//    version (Windows)
//    {
//        loc_t oldloc;
//        
//        if (!text.watch)
//            return;
//        assert(loc < MAPSIZE);
//        if (global.cursor == loc)
//            return;
//        
//        oldloc = global.cursor;
//        global.cursor = loc;
//        if (adjSector(global.scalex, global.scaley))
//            InvalidateRect(global.hwnd, &global.sector, false);
//        else
//        {
//            if (global.player.mode == mdTO)
//            {
//                invalidateLocRect(global.player.frmloc, oldloc);
//                invalidateLocRect(global.player.frmloc, loc);
//            }
//            else if (global.player.mode == mdSURV)
//            {
//                InvalidateRect(global.hwnd, &global.sector, false);
//            }
//            else
//            {
//                invalidateLoc(oldloc);
//                invalidateLoc(loc);
//            }
//        }
//    }
//    else
//    {
//        assert(loc < MAPSIZE);
//        text.curs(rowcol(loc - secbas) + Smin);
//    }
}


/*********************************
 * Remove any sticky messages.
 */

-(void) remove_sticky
{
    if (m_text->m_watch)
    {   
        [m_text curs:[m_text DS:1]]; [m_text deleol];
        [m_text curs:[m_text DS:2]]; [m_text deleol];
        [m_text curs:[m_text DS:3]];[m_text deleol];
     }
}

/****************************
 * Print out list of valid commands per mode.
 */

-(void) valcmd:(int) mode
{
    static char *valmsg[] =
    {   "valcmd()",			// just a place holder
     "QWEADZXC,FGHIKLNRSUVY<>,space", // Move
     "QWEADZXC,FGHIKLNPRSU<>,esc",	// Survey
     "QWEADZXC,esc",			// Dir
     "QWEADZXC,HKNT<>,esc",		// From To
     "AFDTSRCB"			// City Prod
    };
    
    [m_text curs: [m_text DS:3]];
    if (!m_text->m_narrow)
        [m_text smes: @"Valid commands: "];
   
    NSString* str = [NSString stringWithCString:valmsg[mode] encoding:NSUTF8StringEncoding];
    [m_text smes: str];
    
    [m_text deleol];
    if( m_text->m_speaker )
        [[OALSimpleAudio sharedInstance] playEffect:@"error.wav" loop:false];
}

/************************************
 */

-(void) cityProdDemands
{
    [m_text cmes:[m_text DS:0] type: @"City production demands: \1"];
}

-(void) delay:(int) n
{ 
    if (m_text->m_watch)
    {   
        [m_text flush];
        if ( m_timeinterval)
            sleep(n * m_timeinterval);
    }
}

-(void) wakeup
{
    [m_text cmes: [m_text DS:2] type:@"Wakeup performed.\1\2"];
}


/*******************************
 * Type data on a city.
 */
-(void)typcit:(id)p city:(City*)c
{
               
    if (m_text->m_watch)
    {
        if (c->m_phs == -1)
            return;	// invalid city phase
        NSString * str = nil;
        if( m_text->m_narrow )
            str = @"Prod: ";
        else {
            str = @"Producing: ";
        }
        [m_text cmes:[m_text DS:1] type:str ];
        [m_text vsmes:[NSString stringWithFormat:@"%@ Completion: %d", [ self nmes_p:c->m_phs number:2 ], c->m_fnd ]];
        if (((Player*)p)->m_playerType == Human &&  c->m_fipath )
            [m_text vsmes:[NSString stringWithFormat:@" Fipath: %d,%d", [empire ROW:c->m_fipath], [empire COL:c->m_fipath]]];
        
        [m_text deleol];
    }

}

-(void)savgam
{
    Player* p = m_globalVar->m_player[0];
    text* t = p->m_display->m_text;
    [t cmes:[t DS:3] type:@"Saving game...\1"];
    if ([m_globalVar var_savgam:@"empire.dat"])
        [t cmes:[t DS:3] type:@"Error writing EMPIRE.DAT\1"];
    else {
        [t cmes:[t DS:3] type:@"Game Saved.\1"];
    }
}

-(void)lstvar
{}

@end
