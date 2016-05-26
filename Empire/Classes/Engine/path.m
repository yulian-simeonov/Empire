//
//  path.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "path.h"
#import "Player.h"
#import "AppDelegate.h"
#import "maps.h"

@implementation path

static char tblinit;
 -(id) init
{
    if (self = [super init])
    {

    }
    return self;
}
    
+(void) dotblinit
{
    int i;
    int j;
    int k;
    
    for (i = 4; i < (4 + 10); i++)
    {
        for (j = 1; j < PLYMAX; j++)
        {
            k = 4 + j * 10;
           
            okblk[k] = okblk[i];
            okcnt[k] = okcnt[i];
            oklnd[k] = oklnd[i];
            oksea[k] = oksea[i];
        }
    }
    tblinit++;
}

+(BOOL) mapinm:(unsigned char*)ok map:(unsigned char*)mapb location:(loc_t)loc endLocation:(loc_t)end
{
    return (ok[*(mapb + loc)] || loc == end);
}

+(BOOL)armap:(int*)loc currentLoc:(int)curloc trialMoveDirection:(int)trymov
    mapValueAry:(unsigned char*)ok map:(unsigned char*)mapb endLocation:(loc_t)end
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]  delegate];
    
    return (*loc = curloc + [delegate->m_globalVars arrow:trymov]) , [self mapinm:ok map:mapb location:*loc endLocation:end];
}

+(BOOL)armain:(int*)loc currentLoc:(int)curloc trialMoveDirection:(int*)trymov 
  mapValueAry:(unsigned char*)ok map:(unsigned char*)mapb endLocation:(loc_t)end
{
    maps* map = [[[maps alloc] init] autorelease];
    
    return (*trymov = [map movdir:curloc location:end]), [self armap:loc currentLoc:curloc
                                                 trialMoveDirection:*trymov mapValueAry:ok map:mapb endLocation:end];
}

/*****************************************
 * Find path from beg to end.
 * Two entry points:
 *	patho():	optimize path
 *	pathn():	don't optimize path
 * Input:
 *	beg	beginning location
 *	end	ending location
 *	dir	1 or -1, direction to turn in case of obstacle
 *	ok[]	array of map vals with yea or nay
 *	*pr2	where we write the final move to (garbage if fail)
 * Output:
 *	*pr2
 * Returns:
 *	true	if a path is found
 */


//locationEnd :(loc_t) end			/* end				*/
//  direction: (int) dir			/* direction to turn in obstacle */
//   mapValue: (byte*) ok			/* array of ok map values	*/
//initMovePtr: (dir_t*) pr2			/* pointer to initial move	*/
//   optimize:(int) opt			/* if true then optimize	*/
//
+(int) path:(id)player locationStart :(loc_t)beg locationEnd:(loc_t)end direction:(int)dir mapValueAry:(unsigned char*)ok
initMoveDir:(dir_t*)pr2 optimize:(BOOL)opt;

{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]  delegate];
    maps* map = [[[maps alloc] init] autorelease];
    Player* p = (Player*)player;
    int i;
    int movsav;
    int t;
    int curloc;			/* current location		*/
    int loc;			/* trial move location		*/
    int bakadr;			/* ret from okmove		*/
    int dir3;			/* 3 * dir			*/
    unsigned char *mapb;			/* base of map array		*/
    int movnum;			/* # of moves tried		*/
    int movmax;			/* max # of tries		*/
    int trymov;			/* trial move direction		*/
    int begdir;			/* dir that we started out with	*/

    const int TRACKMAX = 100;
    int track[TRACKMAX];		/* list of locs where we stopped */
    /* following the shore and went	*/
    /* straight. This is necessary	*/
    /* so we don't go around in circles */


//    /* initialize
//     */

    if (!tblinit)
        [path dotblinit];

    *pr2 = -1;					// in case beg == end
    curloc = beg;
    dir3 = dir *3;
    begdir = dir;
    t = 0;
    movmax = movnum = 50 + 2 * [map dist:beg location:end];	// max # of tries
    mapb = p->m_map;					// base addr of map
//
//    /* move straight towards end
//     */

strght:
    if (curloc == end) return true;		/* if already there	*/
    if (![path armain:&loc currentLoc:curloc trialMoveDirection:&trymov mapValueAry:ok map:mapb endLocation:end])				/* if we can't move there */
        goto folshr;			/* try following shore	*/

okstr:
    bakadr = true;				/* return to strght	*/

    // The move trymov is legit and we will use it.

okmove:
    if (curloc == beg)		/* if at beginning		*/
        *pr2 = trymov;		/* set initial move		*/
    curloc = loc;			/* set current loc		*/
    if (curloc == end) return true;
    if (!--movnum)			/* if run out of moves		*/
        goto trydir;		/* try another direction	*/
    if (bakadr)			/* goto strght or chknxt	*/
        goto strght;
    else
    {   
        if (opt)			/* attempt to optimize path	*/
        { 
            int move1 = [map movdir:beg location:curloc];	/* initial move		*/
            
            loc = beg;
            while (loc != curloc)	/* while we haven't arrived	*/
            {
                loc += [delegate->m_globalVars arrow:[map movdir:loc location:curloc]];
                if (![path mapinm:ok map:mapb location:loc endLocation:end])		/* if we can't move there	*/
                    goto chknxt;
            }
            *pr2 = move1;		/* set initial move		*/
        }
        goto chknxt;
    }

trydir:
    dir3 = -dir3;			/* try the other direction	*/
    dir = -dir;
    if (dir == begdir)		/* if already tried		*/
        return false;		/* then failed			*/
    movnum = movmax;
    curloc = beg;
    t = 0;				/* reset variables		*/
    goto strght;			/* and try again		*/

    /* We've run into an obstacle. Follow the shore.
     */
folshr:
    trymov = (trymov - dir3) & 7;	/* go back 3			*/
    if ([path armap:&loc currentLoc:curloc trialMoveDirection:trymov mapValueAry:ok map:mapb endLocation:end])			/* if we can move there		*/
        trymov = (trymov + dir3) & 7; /* then don't go back 3	*/
    for (i = 8; i; i--, trymov = (trymov + dir) & 7)
    {  
        loc = curloc + [delegate->m_globalVars arrow:trymov];
        if (![map border:loc] &&		/* if location isn't on edge	*/
           [self mapinm:ok map:mapb location:loc endLocation:end])		/* and we can move there	*/
        {	
            bakadr = false;		/* return from okmove to chknxt	*/
            goto okmove;		/* the move is ok		*/
        }
    }
    return false;			// can't do anything

    /* See if we can break away from following the shore and go
     * straight.
     */
chknxt:
    movsav = [map movdir:curloc location:end];	/* move straight to end		*/
    loc = curloc + [delegate->m_globalVars arrow:movsav];
    if (![self mapinm:ok map:mapb location:loc endLocation:end])			/* if we can't			*/
        goto folshr;		/* resume following the shore	*/
    for (i = t; i--;)		/* loop backwards thru track	*/
        if (track[i] == loc)	/* if we already tried this	*/
            goto folshr;		/* resume following shore	*/
    track[t++] = loc;		/* enter this try into track	*/
    if (t == TRACKMAX)		/* overflow array		*/
        goto trydir;		/* try other direction		*/
    trymov = movsav;		/* go straight			*/
    goto okstr;			/* all clear for going straight	*/
}

@end
