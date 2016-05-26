//
//  init.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "init.h"
#import "mapdata.h"
#import "AppDelegate.h"

@implementation init

/*****************************
 * Initialize city variables.
 */

- (id) init
{
    if( self = [super init] )
    {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        m_glbMember = delegate->m_globalMembers;
        m_globalVar = delegate->m_globalVars;
    }
    return  self;
}

-(void) citini
{ 
    int loc,i,j,k;
    
    for (i = CITMAX; i--;)
    {	
        m_globalVar->m_city[i]->m_loc = m_globalVar->m_city[i]->m_own = 0;
        m_globalVar->m_city[i]->m_phs = -1;			// no phase
    }
    for (i = 0, loc = MAPSIZE; loc--;)
    {
        if ( m_globalVar->m_typ[ m_globalVar->m_map[loc] ] == X)
        {
            if( i <= 69 )
                m_globalVar->m_city[i++]->m_loc = loc;
            else {
                int ladCnt = 0;
                for(i = 0; i < 7; i++)
                {
                    int arndLoc = loc + [m_globalVar arrow:i];
                    if (m_globalVar->m_map[arndLoc] == 3)
                        ladCnt++;
                }
                if (ladCnt > 3)
                {
                    m_globalVar->m_map[loc] = 3;
                }
                else {
                    m_globalVar->m_map[loc] = 2;
                }
            }
        }
    }
    
    
    if ( m_glbMember->m_isMultiPlay ) {
        
    }
    else
    {
        for (i = CITMAX / 2; i--;)
        {
            j = CCRANDOM_0_1() * (CITMAX);
            k = CCRANDOM_0_1() * (CITMAX);

            loc = m_globalVar->m_city[j]->m_loc;
            m_globalVar->m_city[j]->m_loc =  m_globalVar->m_city[k]->m_loc;
            m_globalVar->m_city[k]->m_loc = loc;		// swap city locs
        }
    }
}


/*****************************
 * Select a map.
 * Returns:
 *	0	success
 *	!=0	failure
 */

-(int) selmap
{
    // Use internal maps
    unsigned char *d;
    int i,a, c,n, j;
    
    j = arc4random() % 5;
    
    if (m_glbMember->m_isMultiPlay)
        if (!m_glbMember->m_isServer)
            j =  m_glbMember->m_mapInfo[0];
    
    m_glbMember->m_mapInfo[0] = j;
    
    d = (unsigned char*)(m_glbMember->m_map->m_mapData[j]);
    
    i = MAPSIZE - 1;
    
    while ((c = *d) != 0)		// 0 marks end of data
    {	
        
        n = (c >> 2) & 63;		// count of map values - 1
        a = c & 3;			// bottom 2 bits
        if (a == 0 ||			// a must be 1,2,3
            c == -1 ||			// error reading file
            i - n < 0)			// too much data
        {
            break;
        }
        while (n-- >= 0)
        {
            m_glbMember->m_map->m_mapData[j][i--] = a;
        }
        d++;
    }
    m_globalVar->m_map = m_glbMember->m_map->m_mapData[j];
    
    int rand  = arc4random() & 4;

    if (m_glbMember->m_isMultiPlay)
        if (!m_glbMember->m_isServer)
            rand = m_glbMember->m_mapInfo[1];
    m_glbMember->m_mapInfo[1] = rand;

    if (rand)
    {
        [self flip];
    }
    
    rand  = arc4random() & 4;
    
    if (m_glbMember->m_isMultiPlay)
        if (!m_glbMember->m_isServer)
            rand = m_glbMember->m_mapInfo[2];
    m_glbMember->m_mapInfo[2] = rand;
    
    if (rand)
    {
        [self klip];		// random map rotations
    }

    
    return 0;
}


/***********************
 * Flip map corner to corner.
 */
    
-(void) flip
{
    int i,j,c;
    unsigned char* map;
    
    map = m_globalVar->m_map;
    i = j = MAPSIZE / 2;
    while (i--)
    {	
        c =  map[j];
        map[j++] = map[i];
        map[i] = c;
    }
}


/************************
 * Flip map end to end.
 */

-(void) klip
{ 
    int rw,i,j,c;
    unsigned char* map;
    
    map = m_globalVar->m_map;
    rw = 0;
    while (rw < MAPSIZE)
    {	i = j = (Mcolmx + 1) / 2;
        
        while (i--)
        {
            c = map[rw + j];
            map[rw + j++] = map[rw + i];
            map[rw + i] = c;
        }
        rw += Mcolmx + 1;
    }
}
@end
