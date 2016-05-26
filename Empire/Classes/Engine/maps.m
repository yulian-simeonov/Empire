//
//  maps.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "maps.h"
#import "Unit.h"
#import "empire.h"
#import "Global.h"
#import "AppDelegate.h"

@implementation maps
-(id)init
{
    if (self = [super init])
    {
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        /////////////////////////////////////////////////////////////////////////////////////
        m_glbMembers = delegate->m_globalMembers;
        m_glbVars = delegate->m_globalVars;

    }
    return self;
}
/***********************************
 * Count how many As (Fs) are aboard a T (C).
 * Returns:
 *	Number of As (Fs) are aboard. Returns 0 if unit is not a T (C).
 *	Returns 0 if unit is in a city.
 */

- (int) aboard:(Unit*)u
{ 
    int loc,type,i,total;
    
    loc = u->m_loc;

    
    if ((type = [self tcaf:u]) < 0) return 0;	// if not a T or C
    if (m_glbVars->m_typ[m_glbVars->m_map[loc]] == X) return 0;	// if in a city
    total = 0;				// number aboard
    for (i = m_glbVars->m_unitop; i--;)		// loop thru units
        if (m_glbVars->m_unit[i]->m_loc == loc &&	// locations match
            m_glbVars->m_unit[i]->m_typ == type &&	// if it's the right type
            m_glbVars->m_unit[i]->m_own == u->m_own)
            total++;
    return total;
}

/**************************************
 * Look for troop transports or carriers.
 * Returns:
 *	A	if unit is a T
 *	F	if unit is a C
 *	-1	else
 */

-(int) tcaf:(Unit *)u
{	
    //    A  F  D  T  S  R  C  B
    static int tcaftab[8] = {-1,-1,-1, A,-1,-1, F,-1};
    
    return tcaftab[u->m_typ];
}


/*******************************
 * Find and return distance between loc1 and loc2.
 */

-(int) dist:(loc_t) loc1 location:(loc_t) loc2
{ 
    int r1,c1,r2,c2;
    
    r1 = [empire ROW:(loc1)];
    c1 = [empire COL:(loc1)];
    r2 = [empire ROW:(loc2)];
    c2 = [empire COL:(loc2)];
    
    return [self max:[self abs:(r1 -r2)] b:[self abs:(c1-c2)]];
}

/******************************
 * Find direction to go in to go from loc1
 * to loc2.
 */

-(int) movdir:(loc_t) loc1 location: (loc_t) loc2
{
    static int mov[] = {3,4,5,2,-1,6,1,0,7};
    int i = 0;
    int r1,c1,r2,c2;
    
    r1 = [empire ROW:(loc1)];
    c1 = [empire COL:(loc1)];
    r2 = [empire ROW:(loc2)];
    c2 = [empire COL:(loc2)];
    
    if (c2 >  c1) i++;
    if (c2 >= c1) i++;
    i *= 3;			/* i=0,3,6 for (3,4,5),(2,-1,6),(1,0,7) */
    
    if (r2 >  r1) i++;
    if (r2 >= r1) i++;
    
    return mov[i];		/* correct direction to move		*/
}

/****************************
 * Return true if we're on the edge.
 */

-(int) border:(loc_t) loc
{
    int r1,c1;
    
    r1 = [empire ROW:(loc)];
    c1 = [empire COL:(loc)];
    return ((r1 == 0) || (r1 == Mrowmx) || (c1 == 0) || (c1 == Mcolmx));
}

/**********************************
 * Convert location to row*256+col
 */

-(int) rowcol:(loc_t) loc
{
    return ([empire ROW:(loc)]<<8) + [empire COL:(loc)];
}

/**************************
 * Total up amount of sea around loc and return it.
 */

-(int) edger:(loc_t) loc
{ 
    int sum = 0;				/* running total		*/
    int i = 8;				/* # of directions		*/
    while (i--)				/* continue till i = -1		*/
    {
        if (m_glbVars->m_sea[m_glbVars->m_map[loc + [m_glbVars arrow:i]]]) 
            sum++;
    }
    return sum;
}

/*********************
 * Check routines
 */

/**************************
 * Return true if loc is a valid location.
 */

-(int) chkloc:(loc_t) loc
{
//hb mark
//      return loc < MAPSIZE && !border(loc);
    return 1;
}

-(void) chkmov:(dir_t) r2 error: (int) errnum
{
  //  assert(r2 >= -1 && r2 <= 7);
}


/* Miscellaneous
 */

-(int) max:(int) a b: (int) b
{
    return (a > b) ? a : b;
}

-(int) abs:(int) a
{
    return (a < 0) ? -a : a;
}
@end
