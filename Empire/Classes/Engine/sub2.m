//
//  sub2.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "sub2.h"

@implementation sub2


-(id) init
{
    if(self = [super init])
    {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_globalVar = delegate->m_globalVars;
        m_glbMember = delegate->m_globalMembers;
    }
    return self;
}

/*********************************
 * Return city number given city location.
 */
-(City *) fndcit:(loc_t) loc
{
    int i;

    for (i = CITMAX; i--;)
    {
        City * city = m_globalVar->m_city[i];
        if ( city->m_loc == loc)
            return city;		// we found the city
    }
    return nil;
}


/*******************************
 * Create a new unit, given it's loc and type.
 * Output:
 *	unitop = max(unitop, uninum + 1)
 * Returns:
 *	true	if successful
 *	false	if overpopulation
 */

- (int) newuni:(Unit *)pu location:(loc_t) loc intTy: (uint) ty intpn:(uint) pn
{
    int i;
    Unit *u;

    for (i = 0; i < UNIMAX; i++)
    {
        u = m_globalVar->m_unit[i];
        
        if (! m_globalVar->m_unit[i]->m_loc)		// if unit doesn't exist
        {  
            if (i >= m_globalVar->m_unitop)
                m_globalVar->m_unitop = i + 1;		// set unitop to 1 past max uninum

            u->m_loc = loc;
            u->m_own = pn;
            u->m_typ = ty;
            u->m_hit = m_globalVar->m_typx[ty]->m_hittab;
            u->m_dir = (i & 1) ? 1 : -1;
            pu = u;			// return unit # created
            return true;		// successful
        }
    }
    return false;				// overpopulation
}
@end
