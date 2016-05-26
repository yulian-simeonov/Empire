//
//  move.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "move.h"
#import "Player.h"
#import "sub2.h"
#import "empire.h"

@implementation move

-(id) init
{
    if(self = [super init])
    {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        m_glbMember = delegate->m_globalMembers;
        m_globalVar = delegate->m_globalVars;
        
        m_MapManager = [[maps alloc] init];
    }
    
    return  self;
    
}

-(void) dealloc
{
    [super dealloc];
    [m_MapManager release];
}

/***********************************
 * Do a time slice.
 * Returns:
 *	0	continue
 *	!=0	end program
 */

-(int) slice
{
    int newnum;
    Player *p;
    
    switch ( m_globalVar->m_numply )
    {
        case 1:
        {
            [m_globalVar->m_player[m_globalVar->m_plynum] Tslice];
            break;            
        }   
        case 2:
        {
            p = m_globalVar->m_player[ m_globalVar->m_plynum];
            [p Tslice];
            newnum = (m_globalVar->m_plynum) ^ 3;	// 2 -> 1; 1 -> 2
            Player* player = m_globalVar->m_player[newnum];
            if ( m_glbMember->m_isMultiPlay ) {
//                newnum = (m_glbMember->m_nPlayerPos) ^ 3;	// 2 -> 1; 1 -> 2
                m_globalVar->m_plynum = newnum;
            }
            else
                m_globalVar->m_plynum = (player->m_round > p->m_round + HYSTERESIS) ? m_globalVar->m_plynum : newnum;
            break;
        }   
        case 3:
        { 
            static int e1[4] = {0,2,1,1};	// 0th element is a dummy
            static int e2[4] = {0,3,3,2};
            
            // Only allow move if we're not HYSTERESIS moves ahead of the others.
            
            p = m_globalVar->m_player[m_globalVar->m_plynum];
            Player * player1 = m_globalVar->m_player[e1[m_globalVar->m_plynum]];
            Player * player2 = m_globalVar->m_player[e2[m_globalVar->m_plynum]];

            if( player1->m_round + HYSTERESIS > p->m_round &&
               player2->m_round + HYSTERESIS > p->m_round)
                [p Tslice];                     	// move the player
            
            m_globalVar->m_plynum = (m_globalVar->m_plynum >= 3) ? 1 : m_globalVar->m_plynum + 1;
        }
        break;
        default:
        {	int r;
            int i;
            
            p = m_globalVar->m_player[m_globalVar->m_plynum];
            r = p->m_round;
            for (i = 1; 1; i++)
            {
                if (i > m_globalVar->m_numply)
                {	
                    [p Tslice];
                    break;
                }
                if (i == m_globalVar->m_plynum)
                    continue;
                
                // Only allow move if we're not HYSTERESIS moves ahead of the others.
                Player * player = m_globalVar->m_player[i];
                if (r >=  player->m_round + HYSTERESIS)
                    break;			// too far ahead, next player
            }
            
           m_globalVar->m_plynum = (m_globalVar->m_plynum >= m_globalVar->m_numply ) ? 1 : m_globalVar->m_plynum + 1;
        }
        break;
    }
    return 0;
}



/*****************************
 * Produce units in the cities and reset for next production.
 */

-(void) hrdprd:(id)plyr
{ 
    Player* p = (Player*)plyr;
    Unit *u;

    for (int i = CITMAX; i--;)
    {	
        City *c = m_globalVar->m_city[i];
        
        if (c->m_own != p->m_num)
            continue;                       /* if we don't own the city	    */
        
        if (!c->m_loc)
            continue;                       /* if the city doesn't exist	*/

        [p Sensor:(c->m_loc)];              /* keep map up to date          */
        if (c->m_fnd > p->m_round)          /* if unit is not produced yet	*/
            continue;
        
        sub2 * sub = [[sub2 alloc] init];
        
        // create new unit
        if( [sub newuni:u location:c->m_loc intTy:c->m_phs intpn:p->m_num ] )
        {
            c->m_fnd = p->m_round + m_globalVar->m_typx[c->m_phs]->m_prodtime;
        } 
        [sub release];
    }
}


/****************************
 * See if anybody won or if computer concedes defeat.
 */

-(void) chkwin
{ 
    int n[PLYMAX+1];			/* # of cities owned by plyr #	*/
    int i,j;
    Player *p;
    
    memset(n , 0,sizeof(int));
    
    for (i = CITMAX; i--;)
        n[m_globalVar->m_city[i]->m_own]++;		// inc number owned
    
    for (j = 1; j <= m_globalVar->m_numply; j++)		// loop thru the players
    {	p = m_globalVar->m_player[j];
        if (n[j] != 0 ||		// player j hasn't lost yet
            p->m_defeat)			// if already defeated
            continue;
        
        // If any armies, then player is not defeated
        for (i = m_globalVar->m_unitop; i--;)
        {   if (m_globalVar->m_unit[i]->m_loc && m_globalVar->m_unit[i]->m_own == j && m_globalVar->m_unit[i]->m_typ == A)
            goto L1;
        }
        
        p->m_defeat = true;		// player is defeated
        m_globalVar->m_numleft--;			// number of players left
        for (i = 1; i <= m_globalVar->m_numply; i++)
        {
            [m_globalVar->m_player[i] Notify_defeated:p];
        }
        
        if (m_globalVar->m_numleft != 1)
            for (i = 1; i < m_globalVar->m_numply; i++)
            {
                Player * player = m_globalVar->m_player[i];
                if (!player->m_defeat && player->m_watch)
                goto L1;
            }
        [self  done:0];
        
    L1:
        ;
    }
}


/**************************************
 */

-(void) done:(int) i
{
//    version (Windows)
//    {
//    }
//    else
//    {
//        printf("\n");
//        win32close();
//        exit(i);
//    }
}


/**************************************
 */

-(void) updlst:(loc_t) loc type:(int)type		// update map value at loc
{
    int ty = m_globalVar->m_typ[m_globalVar->m_map[loc]];		// what's there
    
    if ((ty != X) &&			// if not a city
        ((type != A) || (ty != T)) &&	// and not an A leaving a T
        ((type != F) || (ty != C)) )	// and not an F leaving a C
        [self  updmap:(loc)];		// then update the map
}


/*************************************
 * Change map to land or sea, depending on whether what's on it
 * is over land or sea (i.e. an 'A' would be changed to '+').
 */

-(int) updmap:(loc_t) loc
{

    return m_globalVar->m_map[loc] = (m_globalVar->m_land[m_globalVar->m_map[loc]]) ? MAPland : MAPsea;

}




/************************************
 * Find & return the unit number of the unit at loc.
 */

-(Unit *)fnduni:(loc_t) loc
{
    int ab,n;
    ab = m_globalVar->m_map[loc];
    
    [m_MapManager  chkloc:(loc)];

    
    n = m_globalVar->m_unitop;				/* max unit # + 1		*/
    while (n--)
    {	Unit *u = m_globalVar->m_unit[n];
        
        if (u->m_loc == loc && m_globalVar->m_typ[ab] == u->m_typ)
            return u;
    }

    return nil;
}


/***********************
 * Destroy a unit given unit number. If a T or C, destroy any
 * armies or fighters which may be aboard.
 * Watch out for destroying other pieces by mistake!
 */

-(void) kill:(Unit *)u
{ 
    int i,loc,ty,ndes;
    Player *p = m_globalVar->m_player[ u->m_own];
    
    loc = u->m_loc;				// loc of unit

    ty = [m_MapManager tcaf:u];
//    [p notify_destroy:(u)];
    [u destroy];				// destroy unit
    if (ty == -1)				// if not T or C
        return;
    
    if (m_globalVar->m_typ[m_globalVar->m_map[loc]] == X)		// if in a city
        return;				// assume A's & Fs are off ship
    
    ndes = 0;
    for (i = m_globalVar->m_unitop; i--;)
    {	if (m_globalVar->m_unit[i]->m_loc == loc &&
            m_globalVar->m_unit[i]->m_typ == ty &&
            m_globalVar->m_unit[i]->m_own == p->m_num)
    {
        //[p notify_destroy:(&m_globalVar->m_unit[i])];
        [m_globalVar->m_unit[i] destroy];		// destroy it
        ndes++;			// keep track of # destroyed
    }
    }
}




/**********************************
 * Select and return a random direction,
 * giving priority to moving diagonally.
 */

-(int)Randir
{
    int r2;
    empire* e = [[empire alloc] init];
    r2 =  [e Random:24];		// r2 = 0..23
    if (r2 >= 8)			// move diagonally (67%)
    {	r2 &= 7;			// convert to 0..7
        r2 |= 1;			// pick a diagonal move
    }
    return r2;
}



/**********************************
 * Given a pointer to an array of locs, and the number of elements
 * in the array, search for one within range. If found, set ifo,
 * ila and return true.
 */

-(BOOL)Fndtar:(Unit*)u location:(uint*)p entryNum:(uint)n;
{ 
    maps* map = [[[maps alloc] init] autorelease];
    uint loc;
    
    loc = u->m_loc;

    for (; n--; p++)			// look at n entries
    {	if (*p == 0) continue;		// 0 location
      
        if ([map dist:loc location:*p] > u->m_fuel)	// if too far
            continue;
        if (u->m_fuel == u->m_hit)		// if kamikaze
            u->m_ifo = IFOtarkam;
        else
            u->m_ifo = IFOtar;
        u->m_ila = *p;			// set location of target
        return true;
    }
    return false;
}



/**********************************
 * If unit is an A on a T, and is surrounded by water or friendly
 * stuff, return true.
 */

-(BOOL)Sursea:(Unit*)u;
{
    int loc,ac,i;
    
    loc = u->m_loc;
    if ((u->m_typ != A) || (m_globalVar->m_typ[m_globalVar->m_map[loc]] != T))
        return(false);
    for (i = 8; i--;)
    {	ac = m_globalVar->m_map[loc + [m_globalVar arrow:(i)]];	/* ltr map value		*/
        if ((m_globalVar->m_land[ac] || m_globalVar->m_typ[ac] == X) && m_globalVar->m_own[ac] != u->m_own)
            return(false);		/* found land or unowned city	*/
    }
    return(true);				/* guess it must be so		*/
}



/*************************************
 * Given unit number of a T (C), see if it is full.
 * Unit must not be in a city!
 * Use:
 *	full(uninum)
 * Input:
 *	uninum =	unit # of T or C
 * Returns:
 *	true		if the T (C) is full.
 */

-(BOOL)Full:(Unit*)u
{
    int max;
    
    max = u->m_hit;
    if (u->m_typ == T)
        max <<= 1;			// *2 for transports
    maps* map = [[maps alloc] init];
    return [map aboard:(u)] >= max;		// check # aboard against max
}


/***********************************
 * Return true if there aren't any '+'s around loc.
 * Input:
 *	loc
 */

-(BOOL) Ecrowd:(loc_t) loc
{
    int i;
    
    for (i = 8; i--;)
        if (m_globalVar->m_map[loc + [m_globalVar arrow:(i)]] == 3)		// if '+'
            return false;
    return true;
}




@end
