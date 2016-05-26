//
//  Player.m
//  Scott'sEmpire
//
//  Created by ZhiXing Li on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "GameView.h"

@implementation Player

static int st_locold;       // previous loc of unit
static int st_snsflg;       // set if do sensor for enemy
static int dirtab[9] = {0, 1, 2, 3, 4, 5, 6, 7, 8}; // to minimize chars sent to screen

@synthesize delegate;

-(id)init
{
    if (self = [super init])
    {
        AppDelegate *appDele = (AppDelegate*)[[UIApplication sharedApplication]  delegate];
        
        m_glbMembers = appDele->m_globalMembers;
        m_globalVar = appDele->m_globalVars;
        
        m_mapManager = [[maps alloc] init];
        m_empire = [[empire alloc] init];
        m_move = [[move alloc] init];
        m_cmdQueue = [[JSQueue alloc] init];
        m_sub = [[sub2 alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
    [m_mapManager release];
    [m_empire release];
    [m_move release];
    [m_sub release];
    [m_cmdQueue release];
}

+(Player*)Get:(int)num
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]  delegate];
    
    return delegate->m_globalVars->m_player[num];
}

-(void)Save:(FILE*)fp
{
    fwrite(&m_num, sizeof(loc_t), 1, fp);
    fwrite(&m_round, sizeof(unsigned char), 1, fp);
    fwrite(&m_playerType, sizeof(unsigned char), 1, fp);
    fwrite(&m_watch, sizeof(unsigned char), 1, fp);
    fwrite(&m_movedone, sizeof(unsigned int), 1, fp);
    fwrite(&m_uninum, sizeof(unsigned char), 1, fp);
    fwrite(&m_secflg, sizeof(unsigned char), 1, fp);
    fwrite(&m_defeat, sizeof(int), 1, fp);
    fwrite(&m_turns, sizeof(unsigned int), 1, fp);
    fwrite(&m_mode, sizeof(int), 1, fp);
    fwrite(&m_curloc, sizeof(int), 1, fp);
    fwrite(&m_frmloc, sizeof(int), 1, fp);
    fwrite(&m_maxrng, sizeof(int), 1, fp);
    fwrite(&m_citnum, sizeof(int), 1, fp);
    fwrite(&m_savmod, sizeof(int), 1, fp);
    fwrite(&m_nrdy, sizeof(int), 1, fp);
    fwrite(&m_modsave, sizeof(int), 1, fp);
}

-(void)Load:(FILE*)fp
{
    fread(&m_num, sizeof(loc_t), 1, fp);
    fread(&m_round, sizeof(unsigned char), 1, fp);
    fread(&m_playerType, sizeof(unsigned char), 1, fp);
    fread(&m_watch, sizeof(unsigned char), 1, fp);
    fread(&m_movedone, sizeof(unsigned int), 1, fp);
    fread(&m_uninum, sizeof(unsigned char), 1, fp);
    fread(&m_secflg, sizeof(unsigned char), 1, fp);
    fread(&m_defeat, sizeof(int), 1, fp);
    fread(&m_turns, sizeof(unsigned int), 1, fp);
    fread(&m_mode, sizeof(int), 1, fp);
    fread(&m_curloc, sizeof(int), 1, fp);
    fread(&m_frmloc, sizeof(int), 1, fp);
    fread(&m_maxrng, sizeof(int), 1, fp);
    fread(&m_citnum, sizeof(int), 1, fp);
    fread(&m_savmod, sizeof(int), 1, fp);
    fread(&m_nrdy, sizeof(int), 1, fp);
    fread(&m_modsave, sizeof(int), 1, fp);
}

// Give time slice to a player
-(void)Tslice
{
    int i;
    Unit* u;
    Player* p = self;
                  
    if (m_globalVar->m_numleft == 1)
        return;
    
    // Loop through all the units making sure that each unit moves once per round.
    for (; p->m_uninum < m_globalVar->m_unitop; p->m_uninum++)
    {
        i = p->m_uninum;                                        // get unit number
        u = m_globalVar->m_unit[i];         
        if (u->m_mov ||                                         // if unit has already moved
            !u->m_loc ||                                        // if unit doesn't exist
            u->m_own != p->m_num)                               // if the unit isn't ours
            continue;
        if (p->m_secflg &&                                      // if move by sector and
            ![p->m_display insect:u->m_loc location:2] &&       // not in the current sector and
            p->m_movedone)                                      // previous move was completed
            continue;
        if (p->m_watch)
            p->m_secflg = true;                                 // back to moving by sector
        p->m_movedone = [p Mmove:u];                            // move the unit
        if (p->m_movedone)
            u->m_mov = true;                                    // indicate that it's moved
        return;
    }   
    
    // we've moved all the units for this round that are in this sector
    p->m_uninum = 0;                                            // reset
    if (p->m_secflg)    
    {   // if only in the sector showing
        p->m_secflg = false;                                    // try anybody
        return;
    }
    
    // we've moved all the units for this round.
    if (p->m_watch)                                             // only by sector if we're watching
        p->m_secflg = true;                                     // back to moving by sector
    
    for (i = m_globalVar->m_unitop; i--;)
    {
        u = m_globalVar->m_unit[i];
        if (u->m_own == p->m_num)
            u->m_mov = false;                                   // reset all the unimov entries
    }
    
    [self Finrnd];                                              // finish up round
}
 
// Finish up the round for this player.
-(void)Finrnd
{
    if (m_playerType == Computer)                                           // if computer player
        [self Cityph];                                      // adjust city phases as req'd
    
    [m_display remove_sticky];
    [m_move hrdprd:self];                                   // hardware production
    [m_move chkwin];                                        //see if anybody won
    m_round++;                                              // next round
    for (int i = 1; i <= m_globalVar->m_numply; i++) 
        [[Player Get:i] Notify_round:self round:m_round];   // type out the round #
    [m_display->m_text flush];
}

// Perform a move for a unit. Return true if move was successfully completed.
-(int)Mmove:(Unit*)u
{
    dir_t r2;
    int e;
    Player* p = self;
    do {
        [p Sensor:u->m_loc];                        // get up to date before move 
               
        switch (p->m_playerType) 
        {
            case Human:		
            {
                if (![p Hmove:u direction:&r2])         // do human move
                    return 0;
                break;
            }
            case NetUser:
            {
                if (![p Nmove:u direction:&r2])
                    return 0;
                break;
            }
            case Computer:
            {
                if(![p CMove:u direction:&r2])          
                    return 0;
                break;
            }
            default:
                break;
        }
        // see if unit was destoryed while lin cmove or hmove
        if (!u->m_loc || u->m_own != p->m_num)      // unit was destoryed
            break;                         // check for legit move
       
        e = [p Evalu8:u diret:r2];  
   //     [(GameView*)m_glbMembers->m_GameView Draw];
    } while (e);
    p->m_turns = 0;                                 // reset
    
    return 1;                                       // done with this piece
}

//Evaluate the move. Input: uninum = unit number, r2 = move, Returns: true if we get another move
-(BOOL)Evalu8:(Unit*)u diret:(int)r2
{
    loc_t loc = u->m_loc;                               // location of unit
    int type = u->m_typ;                                // what type of unit we have
    int ab = m_globalVar->m_map[loc];                   // what's there
    int ac;
    Player* p = self;
    Display* d = p->m_display;
    
    
    // Perform the move
    st_locold = loc;                                    // remember for drag
    st_snsflg = false;                                  // don't do sensor for enemy
    
    
    [m_move updlst:loc type:type];                      // fixup map location left
    loc += [m_globalVar arrow:r2 ];                     // move to new loc
    
    if( loc > MAPSIZE - 1 )
        return false;
    
    ac = m_globalVar->m_map[loc];                       // map value of where we are
    u->m_loc = loc;                                     // update unit location
    
    // Watch out for an A on a T attempting to attack a ship
    if (type == A && m_globalVar->m_sea[ac] && m_globalVar->m_typ[ab] == T && r2 != -1)
    {
        [d drown:u];                                    // can't do this
        [self Killit:u];
        return false;
    }
    
    //perform battles as req's, watch for A on T or F on C
    if (m_globalVar->m_typ[ac] >= A)                    //if ac is a unit
    {
        if (m_globalVar->m_own[ac] == p->m_num)         //if we own the piece
        {
            if (type == A && m_globalVar->m_typ[ac] == T)
            {
                if (m_globalVar->m_typ[ab] != T)
                {
                    [d boarding:u];                     //if A boarding a transport
                    [self Eomove:u->m_loc];
                }
                return false;
            }
            if (type == F && m_globalVar->m_typ[ac] == C)
            {
                if (m_globalVar->m_typ[ab] != C)
                {
                    //if F landing on a carrier
                    u->m_hit = m_globalVar->m_typx[F]->m_hittab;    //reset range of F
                    [d landing:u];
                    [self Eomove:u->m_loc];
                }
                return false;
            }
        }
        else 
            st_snsflg = m_globalVar->m_own[ac];         //do sensor for enemy
        if ([self Fight:u location:loc])                //If we fight & lose
        {
            [self Killit:u];                            //remove the carcass
            return false;                               //All done
        }
        ac = [m_move updmap:loc];                       // fix up map
    }
    
    //Take care of special stuff for armies
    if (type == A)                                      // if army
    {
        if (ac == MAPsea)                               // if moving onto sea
        {
            [d drown:u];                                // drown him
            [self Killit:u];
        }
        else if (ac == MAPland)                         // if moving onto land
        {
            [self Change:type location:loc areaOrland:ac];      //update map loc
            [self Eomove:loc];                                  // do end of move processing
        }
        else {
            [self Attcit:loc];                          //Then must be attacking a city
            [self Killit:u];                            //always destroyed
        }
        return false;                                   // all done
    }
    
    //Take care of special stuff for fighters
    if (type == F)                                      // if Fighter
    {
        if (m_globalVar->m_typ[ac] == X)                //if moving onto a city
        {                       
            if (m_globalVar->m_own[ac] == p->m_num)     // if the city is ours
            {
                // land the plane
                u->m_hit = m_globalVar->m_typx[F]->m_hittab;        //reset range of F
                [d landing:u];
                [self Eomove:u->m_loc];
            }
            else {                                      // unowned city
                [d shot_down:u];
                [self Killit:u];                        // a fatal error
            }
            return false;
        }
        else {                                                  // moving onto sea or land
            if (--u->m_hit)                                     // if not run out of fuel yet
                [self Change:type location:loc areaOrland:ac];  // good move
            else {                                              // ran out of fuel
                [d no_fuel:u];
                [self Killit:u];
                return false;
            }
        }
    }
    
    // Take care of ships
    if (type >= D)
    {
        if (ac == MAPsea)                                       //if moving onto sea
            [self Change:type location:loc areaOrland:ac];      //then fix map & we're done
        else {                                                  // ran aground or docked
            if (m_globalVar->m_own[ac] != p->m_num)             // if not owned
            {
                [d aground:u];                                  // ran aground
                [self Killit:u];
                return false;
            }
            if (u->m_hit < m_globalVar->m_typx[type]->m_hittab)
                u->m_hit++;                                     // ship in port, repair it
            [d docking:u location:loc];
        }
    }
    
    [self Eomove:loc];                                  // do ending sensor probes
    switch (type) {
        case F:
        {
            if (u->m_hit % 4 == 0)
                return false;
            break;
        }   
        case T:
        case C:
        {
            [p Drag:u];
        }
        case D:
        case S:
        case R:
        case B:
        {
            if (p->m_turns ||                                           // if already got extra move
                 u->m_hit <= m_globalVar->m_typx[type]->m_hittab / 2)   // or half damaged
                return false;
            break;
        }
        default:
            break;
    }
    
    if (m_globalVar->m_typ[ac] == X)            // if in city
        return false;                           // then no extra moves
    p->m_turns++;                               // # of turns completed
    return true;                                // get another move
}

//Attack city at loc and determine outcome.
-(void)Attcit:(loc_t)loc
{
    int ab = m_globalVar->m_map[loc];
    Player* patt = self;
    Player* pdef = [Player Get:m_globalVar->m_own[ab]];
    City* c;
    
    
    BOOL bRand = ( arc4random() % 60) >= 30;
    
    if ( m_glbMembers->m_isMultiPlay) {
        
        if ( m_glbMembers->m_nRand ) {
            bRand = true;
        }
        else
            bRand = false;
    }
    
    c = [m_sub fndcit:loc];
    if ([patt isEqual:pdef])
        [patt->m_display city_attackown];
    else if ( bRand )          // 50% chance of take over
    {
        int mapval;                     // city map value
        int i;
        [pdef->m_display city_conquered:loc];
        [patt->m_display city_subjugated];
        [pdef Notify_city_lost:c];
        mapval = 4 + 10 * (patt->m_num - 1);            // map val of conquered city
        m_globalVar->m_map[loc] = mapval;               // set reference map
        st_snsflg = c->m_own;                           // !=0 if do sensor for enemy
        c->m_own = patt->m_num;                         // set new owner
        
        // destory any enemy pieces in the city.
        for (i = 0; i < m_globalVar->m_unitop; i++)
        {
            Unit* u = m_globalVar->m_unit[i];
            if (u->m_loc == loc && u->m_own != patt->m_num)
            {
                [pdef Notify_destory:u];
                [u destroy];
            }
        }
        
        c->m_phs = -1;                                  // select new phase
        [patt Notify_city_won:c];
    }
    else {
        
        if( c != nil )
        {
            [pdef Notify_city_repelled:c];
            [pdef->m_display city_repelled:loc];            // invasion was repelled
            [pdef->m_display city_crushed];                 // assault was crushed
        }
    }
}

-(void)CapturedCity:(loc_t)loc
{
    int ab = m_globalVar->m_map[loc];
    Player* patt = self;
    Player* pdef = [Player Get:m_globalVar->m_own[ab]];
    City* c;
    
    c = [m_sub fndcit:loc];
    if ([patt isEqual:pdef])
        [patt->m_display city_attackown];
    else          // 50% chance of take over
    {
        int mapval;                     // city map value
        int i;
        [pdef->m_display city_conquered:loc];
        [patt->m_display city_subjugated];
        [pdef Notify_city_lost:c];
        mapval = 4 + 10 * (patt->m_num - 1);            // map val of conquered city
        m_globalVar->m_map[loc] = mapval;               // set reference map
        st_snsflg = c->m_own;                           // !=0 if do sensor for enemy
        c->m_own = patt->m_num;                         // set new owner
        
        // destory any enemy pieces in the city.
        for (i = 0; i < m_globalVar->m_unitop; i++)
        {
            Unit* u = m_globalVar->m_unit[i];
            if (u->m_loc == loc && u->m_own != patt->m_num)
            {
                [pdef Notify_destory:u];
                [u destroy];
            }
        }
        
        c->m_phs = -1;                                  // select new phase
        [patt Notify_city_won:c];
        
    }
}

// Type out sector indicated by upper left conner loc.
-(void)Sector:(int)loc
{
    Player* p = self;
    Display* d = p->m_display;
    text* t = p->m_display->m_text;
    if (!t->m_watch)
        return;                 // not watching this player
    
    if (loc == d->m_secbas)
        return;                     // this sector is already showing
    m_glbMembers->m_player = p;
    m_glbMembers->m_ulcorner = loc;
//    m_glbMembers->m_map->m_mapData[] = m_map;
    m_glbMembers->m_offsetx = 0;
    m_glbMembers->m_offsety = 0;
    d->m_secbas = loc;              // set new sector base
    //refresh
}

// Do sensor probe around loc. Update player mpas, screen and computer player variables. 
//If an enemy is detected, call sensor for him also
-(void)Sensor:(loc_t)loc
{
    int i, r2, o;
    uint z6;
    ushort pab, rab;
    Player* p = self;
    for (i = 9; i--;)           // look at 9 directions
    {
        r2 = dirtab[i];         // get direction
        z6 = loc + [m_globalVar arrow:r2];          // get new location
        
        if( z6 > 5999 )
            continue;
            
        pab = m_map[z6];               // get player map value
        rab = m_globalVar->m_map[z6];               // and reference map value
        
        if (pab != rab)                             // if there is a change
        {
            m_map[z6] = rab;           // update player map
            if (p->m_watch)
                [p->m_display mapprt:z6];           // print map value on screen
            if (p->m_playerType == Computer)
                [p Updcmp:z6];                          // update computer strat variables
        }
        
        // check to see if it's an enemy piece or city. If so, do a sensor
        // probe about this loc for the enemy
        o = m_globalVar->m_own[rab];
        if (o && o != p->m_num)
        {
            Player* pe = [Player Get:o];
            pab = pe->m_map[loc];
            rab = m_globalVar->m_map[loc];
            if (pab != rab)                     // if there is a change
            {
                pe->m_map[loc] = rab;           // update player map
                if (pe->m_watch)
                    [pe->m_display mapprt:loc];     // print map value on screen
                if (pe->m_playerType == Computer)
                    [pe Updcmp:loc];                // update computer strat variables
            }
        }
    }
}

// Center the sector about loc
-(void)Center:(int)loc
{
    int row, col, rowsize, colsize, size;
    Player* p = self;
    Display* d = p->m_display;
    row = [empire ROW:loc];
    col = [empire COL:loc];
    size = d->m_Smax - d->m_Smin;           // display size
    rowsize = size >> 8;                    // # of rows - 1
    colsize = size & 0xff;
    row -= rowsize / 2;
    col -= colsize / 2;
    if (row < 0 )   row = 0; 
    if (row > Mrowmx - rowsize) row = Mrowmx - rowsize;
    if (col < 0)    col = 0;
    if (col > Mcolmx - colsize) col = Mcolmx - colsize;
    [p Sector:row * (Mcolmx + 1) + col];        // type new sector
}

// Select initial city for player
-(int)Citsel:(int)cityIdx;
{
    int n;
    loc_t loc;
    City* c;
    Player* p = self;
    do {
        n = [m_empire Random:CITMAX];       // select a city at random
        c = m_globalVar->m_city[n];
        loc = c->m_loc;
    } while (!loc ||                        // if city doesn't exist or
             [m_mapManager edger:loc] == 8||       // island city or
             c->m_own);                     // already owned
  
    if (cityIdx != -1)
    {
        n = cityIdx;
        c = m_globalVar->m_city[cityIdx];
        loc = c->m_loc;
    }
    
    c->m_own = p->m_num;                    // clain the city
    // JS
    m_globalVar->m_map[loc] = 4 + (p->m_num - 1) * 10;          // set map value
    [p Sensor:loc];                         // do a sensor probe
    switch (p->m_playerType) {
        case Human:
        {
            // if human player
            [p Phasin:c];                       // get city phase
            
            //hb insert
            m_glbMembers->m_nSelectedCityIdx = n;
            break;
        }   
        case NetUser:
        {
            
            break;
        }
        case Computer:
        {
            [p CPhasin:c]; 
            break;
        }
        default:
            break;
    }
    return n;
}

/* =============================Human strategy=========================================*/
// Get move from player. Watch out for unit begin destoryed while in tty input wait for a move.
-(BOOL)Hmove:(Unit*)u direction:(int*)pr2
{
    loc_t oldloc;
    enum CmdType cmd;
    Player* p = self;
    Display* d = p->m_display;
    text * t = d->m_text;
     
    if (![u isEqual:p->m_usv])
        p->m_nrdy = 0;                      // it's different unit!
    if (p->m_nrdy == 1)     goto cmdin;     // get command
    if (p->m_nrdy == 2)     goto dirin;     // get direction in cmdI
    
bhmove:
    p->m_usv = u;                           // remember unit number
    *pr2 = -1;                              // default no move
    if ([m_move Sursea:u])  return 1;        // if A on T at sea
    if ([p MyCode:u direction:pr2])          // if automatic move
    {
        [t flush];
done:   [p SetMode:mdNONE];
        [p ChkSleep:u direction:*pr2];      // see if we put it to sleep
        [t speaker_click];
        return 1;
    }
    
// Enter movement mode.
movmod:
    p->m_curloc = u->m_loc;                 // set current location
    [(GameView*)m_glbMembers->m_GameView drawCity];
    [d headng:u];                           // print heading
//    if (![d insect:p->m_curloc location:2]) // if not in current sector
//        [self Center:p->m_curloc];           // then print out the sector
    [p SetMode:mdMOVE];                     // put in move mode
  
    goto cmdscn;

    //Bad command
cmderr:
    [self CmdError];
    //command scanner
cmdscn:
    [p Sensor:u->m_loc];
cmdin:
    [d pcur:p->m_curloc];                // position cursor
    if (self->m_cmdQueue.count == 0)       // if no input from tty
    {
        p->m_nrdy = 1;
        return 0;                       // not ready
    }
    cmd = [[self->m_cmdQueue dequeue] intValue];
    p->m_nrdy = 0;                          //reset flag
    
    // Evaluate result if it's a direction command
    oldloc = p->m_curloc;               //remember
    if ([self Cmdcur:&p->m_curloc command:cmd direction:pr2])           // if direction command
    {
        if (p->m_curloc == oldloc)                                      // if bad direction command
        {
            goto cmderr;                                                // then error
        }
        if (p->m_mode == mdMOVE)                                        // if in move mode
        {
            if (![p Seeifok:u direction:*pr2] &&                        // if move is destructive
                ![p->m_display rusure])                                 // and he backs out
            {
                p->m_curloc = u->m_loc;
                goto cmdscn;                                            // give him another change
            }

            goto done;                                                  // we're done
        }
        
        if (p->m_mode == mdTO)                                          // if in TO mode
        {
            if ([m_mapManager dist:p->m_curloc location:p->m_frmloc] > p->m_maxrng)
            {
                p->m_curloc = oldloc;
                goto cmderr;                                            // to far away
            }
        }
        [p TypHdg];                                                     // update heading
        goto cmdscn;
    }
    
    //check for command in our table
    switch (cmd) {
        default:
        {
            goto cmderr;                // no defaults!
            break;
        }
        case Skip:                                                       // stay put
        {
            *pr2 = -1;
            if (p->m_mode == mdMOVE)
            {
                if (![p Seeifok:u direction:*pr2] &&                    // if move is destructive
                    ![p->m_display rusure])                             // and he backs out
                    goto cmdscn;                                        // give him another chance
                goto done;                                              // only allowed in move mode
            }
            [self CmdError];                                            
            break;
        }
        case FromTo:
        {
            [p MoveFromTo:u];
            break;
        }
        case GotoCity:
        {
            if ([p GotoNearestCity:u])                      
                goto bhmove;
            break;
        }
        case TwentyFree:
        {
            if (![p->m_display rusure])
                goto cmdin;                     // give him a chance to back out
            [p SetMode:mdNONE];
            p->m_round += 20;                   // use this as our machanism
            return 0;
            break;
        }
        case Direction:
        {
            if (![p Valid:u] || p->m_mode == mdTO)
            {
                [self CmdError];
                break;
            }
            p->m_modsave = p->m_mode;
            [p SetMode:mdDIR];              // new mode
        dirinp: [d pcur:p->m_curloc];       // position cursor
            
        dirin:   /* if ( (cmd = m_glbMembers->m_prevCmdMode ) == -1 )*/
                if(false)
                {
                    p->m_nrdy = 2;
                    return 0;               // player is not ready
                }
            
            p->m_nrdy = 0;                  // reset flag
            if (cmd == ESC)
            {
                [p SetMode:p->m_modsave];
                break;
            }
            oldloc = p->m_curloc;
            if (![self Cmdcur:&oldloc command:cmd direction:pr2] || oldloc == p->m_curloc)
            {
                [self CmdError];
                goto dirinp;                // try again
            }
            [p SetMode:p->m_modsave];       // back to old mode
            if ([p mycmod:u ifo:fnDI ila:*pr2])
                goto bhmove;                // back to begining
            break;
        }
        case SoundControl:                           // toggle sound on/off
        {
            if( t->m_speaker )
            {
                t->m_speaker = false;
            }
            else {
                t->m_speaker = true;
            }
            break;
        }
        case Wake:                           // wake up
        {
            [p AwakeUnit:u];
            break;
        }
        case Load:
        {
            if ([p LoadUnits:u])                // load armies
                goto bhmove;
            break;
        }
//        case 'N':                               // new screen
//        {
//            [self Center:p->m_curloc];
//            break;
//        }
        case CityPro:
        {
            [p EnterNewCity];
            break;
        }
        case MoveRandom:                               // random
        {
            if ([p mycmod:u ifo:fnRA ila:0])
                goto bhmove;                    // back to begining
            break;
        }
        case Sentry:                               // sentry
        {
            if (m_globalVar->m_typ[m_globalVar->m_map[p->m_curloc]] == X)
                goto cmderr;                                    // can't put in sentry in a city
            if( [p mycmod:u ifo:fnSE ila:0 ])
                goto bhmove;
            break;
        }
        case FromToOk:                               // To
        {
            if ([p ConfirmFromToMove:u])
                goto bhmove;                // if ifo and ila were changed
            break;
        }
//        case 'U':                           // wake up units aboard
//        {
//            [p AboardUnits:u];
//            break;
//        }
        case Save:
        {
            if (p->m_mode != mdMOVE)
                goto cmderr;                // only in move mode
            [m_display savgam];             // save game next time around
            return 0;                       // move not completed
        }
        case Survey:
        {
            if (p->m_mode == mdSURV)
                goto cmderr;                // allready in survey mode
            [p SetMode:mdSURV];
            [p TypHdg];
            break;
        }
//        case ESC:
//        {
//            if (p->m_mode == mdMOVE)
//                goto cmderr;                    // already in move mode
//            goto movmod;                        // return to move mode
//            break;
//        }
//        case '<':
//        {
//            d->m_timeinterval = (d->m_timeinterval < 1) ? 0 : d->m_timeinterval - 1;
//            break;
//        }
//        case '>':
//        {
//            d->m_timeinterval++;
//            break;
//        }
    }
    goto cmdscn;

}

//Net User Move Action
-(BOOL)Nmove:(Unit*)u direction:(int*)pr2
{
    loc_t oldloc;
    enum CmdType cmd;
    Player* p = self;
    
    if (![u isEqual:p->m_usv])
        p->m_nrdy = 0;                      // it's different unit!
    if (p->m_nrdy == 1)     goto cmdin;     // get command
    
bhmove:
    p->m_usv = u;                           // remember unit number
    *pr2 = -1;                              // default no move
    if ([m_move Sursea:u])  return 1;        // if A on T at sea
    
    // Enter movement mode.
movmod:
    p->m_curloc = u->m_loc;                 // set current location
    [p SetMode:mdMOVE];                     // put in move mode
    goto cmdscn;
    
    //Bad command
cmderr:
    [self CmdError];
    //command scanner
cmdscn:
    [p Sensor:u->m_loc];
cmdin:
    if (self->m_cmdQueue.count == 0)       // if no input from tty
    {
        p->m_nrdy = 1;
        return 0;                       // not ready
    }
    cmd = [[self->m_cmdQueue dequeue] intValue];
    p->m_nrdy = 0;                          //reset flag
    
    // Evaluate result if it's a direction command
    oldloc = p->m_curloc;               //remember
    if ([self Cmdcur:&p->m_curloc command:cmd direction:pr2])           // if direction command
    {
        if (p->m_curloc == oldloc)                                      // if bad direction command
        {
            goto cmderr;                                                // then error
        }
        if (p->m_mode == mdMOVE)                                        // if in move mode
        {
            if (![p Seeifok:u direction:*pr2] &&                        // if move is destructive
                ![p->m_display rusure])                                 // and he backs out
            {
                p->m_curloc = u->m_loc;
                goto cmdscn;                                            // give him another change
            }
            
            goto done;                                                  // we're done
        }
        goto cmdscn;
    }
    goto cmdscn;
    
done:   [p SetMode:mdNONE];
        [p ChkSleep:u direction:*pr2];      // see if we put it to sleep
    return 1;
}

// Process the 'F' command
-(void)MoveFromTo:(Unit*)u
{
    int ab, md;
    Player* p = self;
    md = p->m_mode;             // short hand
    if (md == mdTO)      goto err;
    ab = m_globalVar->m_map[p->m_curloc];
    p->m_maxrng = 100;                          // default unless fighter
    p->m_citnum = -1;                           // default unless from city
    
    if (![p Valid:u] ||                         // if not a unit
        (md == mdSURV && m_globalVar->m_typ[ab] == X))  // or we're sitting on a city
    {
        if (![p Cittst])                        // if not an owned city
            goto err;
        p->m_maxrng = m_globalVar->m_typx[F]->m_hittab;         // set to max fighter range
        p->m_citnum = [m_sub fndcit:p->m_curloc]->m_num; // find city #
    }
    else if (p->m_curloc != u->m_loc ||
             (md == mdSURV && u->m_typ == F && m_globalVar->m_typ[ab] == C))
    {
        Unit* ui;
        ui = [m_move fnduni:p->m_curloc];           // get unit number
        if (ui->m_typ == F)                         // if it's a fighter
            p->m_maxrng = u->m_hit;                 // set max range
    }
    else {
        if (u->m_typ == F)                          // if it's a fighter
            p->m_maxrng = u->m_hit;                 
    }
    p->m_savmod = p->m_mode;                        // save current mode
    [p SetMode:mdTO];                               // swithc to TO mode
    p->m_frmloc = p->m_curloc;                      // set from location
    return;
err:
    [self CmdError];
}
    
// Command 'G' Find the nearest city or carrier we can fly to. Works.
// For setting fipath[]s also. Return true if we modified the ifo and ila of the unum unit.
-(BOOL)GotoNearestCity:(Unit*)u
{
    int md, cloc, i, mindist, minloc;
    Player* p = self;
    md = p->m_mode;
    if (md == mdTO) goto err;
    cloc = p->m_curloc;
    
    //first find nearest city.
    mindist = m_globalVar->m_typx[F]->m_hittab + 1;         // we want one within range
    for (i = CITMAX; i--;)
    {
        if (m_globalVar->m_city[i]->m_own == p->m_num &&    // if we own the city and
            cloc != m_globalVar->m_city[i]->m_loc &&        // we're not already there and
            m_globalVar->m_city[i]->m_loc &&                // the city exists and
            [m_mapManager dist:cloc location:m_globalVar->m_city[i]->m_loc] < mindist)
        {
            minloc = m_globalVar->m_city[i]->m_loc;
            mindist = [m_mapManager dist:cloc location:minloc];
        }
    }
    
    // look for a closer carrier
    for (i = m_globalVar->m_unitop; i--;)
    {
        if (m_globalVar->m_unit[i]->m_typ == C &&               // if it's a carrier and
            m_globalVar->m_unit[i]->m_own == p->m_num &&         // we own it and
            m_globalVar->m_unit[i]->m_loc &&                    // it exists and
            cloc != m_globalVar->m_unit[i]->m_loc &&            // we're not already there and
            [m_mapManager dist:cloc location:m_globalVar->m_unit[i]->m_loc])
        {
            minloc = m_globalVar->m_unit[i]->m_loc;
            mindist = [m_mapManager dist:cloc location:minloc];
        }
    }
    
    if (mindist == m_globalVar->m_typx[F]->m_hittab + 1)    goto err;   // if we failed
    
    if (md == mdMOVE)
    {
        if (u->m_typ != F)  goto err;
        if (u->m_hit < mindist)     goto err;       // if out of range
        return [p mycmod:u ifo:fnMO ila:minloc];
    }
    
    if( [p Cittst] )
    {
        [m_sub fndcit:cloc]->m_fipath = minloc;
        [p TypHdg];
        return false;
    }
    
    if ([p Valid:u])            // if valid unit
    {
        Unit* ui = [m_move fnduni:cloc];            // find the unit number
        if (ui->m_typ != F || ui->m_hit < mindist)
            goto err;
        return [p mycmod:u ifo:fnMO ila:minloc];
    }
err:
    [self CmdError];
    return false;
}

// Wake up unit if on a unit, clear fipath[] if on a city
-(void)AwakeUnit:(Unit*)u
{
    Player* p = self;
    if (p->m_mode == mdMOVE)
    {
        [p mycmod:u ifo:fnAW ila:0];
        return;
    }
    
    if ([p Cittst])                     // if we're on a valid city
    {
        [m_sub fndcit:p->m_curloc]->m_fipath = 0;                       // zero out fipath
        [p TypHdg];
        return;
    }
    
    if ([p Valid:u])                    // if a valid unit
        [p mycmod:u ifo:fnAW ila:0];    // wake up unit
    else {
        [self CmdError];
    }
}

// Process 'L' cmd. Load armies/fighters on transports/carriers. Don/t allow it if he's in a city
// Return true if we modified the ifo and ila of the unum unit
-(BOOL)LoadUnits:(Unit*)u
{
    int ab;
    Player* p = self;
    ab = m_globalVar->m_map[p->m_curloc];
    if (m_globalVar->m_own[ab] == p->m_num &&               // if we own the unit and
        (m_globalVar->m_typ[ab] == T || m_globalVar->m_typ[ab] == C))    // it's a transport or carrier
        return [p mycmod:u ifo:fnFI ila:0];
    [self CmdError];
    return false;
}

// Enter new city production phase.
-(void)EndterNewCity
{
    Player* p = self;
    if (p->m_mode != mdSURV)            // only allowed in survey mode
    {
        [self CmdError];
        return;
    }
    
    if (![p Cittst])            // not a valid city
    {
        [self CmdError];
        return;
    }
    
    [p SetMode:mdPHAS];
    [p Phasin:[m_sub fndcit:p->m_curloc]];     // get new phase for city
    [p SetMode:mdSURV];
}

// Process 'T' command. Returns rue if we modified the ifo and ila of the unum unit.
-(BOOL)ConfirmFromToMove:(Unit*)u
{
    int ila;
    Player* p = self;
    if (p->m_mode != mdTO)      // if not in TO mode
    {
        [self CmdError];
        return false;
    }
    
    [p SetMode:p->m_savmod];            // back to previous mode
    ila = p->m_curloc;
    p->m_curloc = p->m_frmloc;
    if (p->m_citnum == -1)              // it it wasn't a city
        return [p mycmod:u ifo:fnMO ila:ila];   // set new functioni for device
    else                                // else it was a city
    {
        m_globalVar->m_city[p->m_citnum]->m_fipath = ila;
        [p TypHdg];
        return false;
    }
    return true;
}

// Wake up units aboard.
-(void)AboardUnits:(Unit*)u
{
    int i, type;
    Player* p = self;
    if ([p Cittst])                             // if we're sitting on a city
    {
        for (i = m_globalVar->m_unitop; i--;)
        {
            if (m_globalVar->m_unit[i]->m_loc == p->m_curloc && m_globalVar->m_unit[i]->m_own == p->m_num)
                m_globalVar->m_unit[i]->m_ifo = 0;          // wake up the unit
        }
    }
    else {
        if (![p Valid:u])                                   // if not valid unit
        {
            [self CmdError];
            return;
        }
        type = m_globalVar->m_typ[m_globalVar->m_map[p->m_curloc]];
        if (type != T && type != C)
        {
            [self CmdError];
            return;
        }
        type = (type == T) ? A : F;                 // type we want to wake up
        for (i = m_globalVar->m_unitop; i--;)
        {
            if (m_globalVar->m_unit[i]->m_loc == p->m_curloc &&
                m_globalVar->m_unit[i]->m_typ == type &&
                m_globalVar->m_unit[i]->m_own == p->m_num)
                m_globalVar->m_unit[i]->m_ifo = 0;          // wake up the unit
        }
    }
    [p->m_display wakeup];
}

// Modify ifo and ila of the unit the cursor is on.
-(BOOL)mycmod:(Unit*)u ifo:(int)fo ila:(int)la
{
    Player* p = self;
    if (![p Valid:u])                   //if not a valid unit
    {
        [self CmdError];
        return false;
    }
    if (p->m_mode != mdMOVE)            // then look at visible piece
    {
        Unit* ui = [m_move fnduni:p->m_curloc];
        ui->m_ifo = fo;
        ui->m_ila = la;
        [p->m_display headng:ui];
        return false;
    }
    else {
        u->m_ifo = fo;
        u->m_ila = la;
        [p->m_display headng:u];
        return true;
    }
}

//Return true if (curloc = loc) or (we're sitting on an owned unit).
-(BOOL)Valid:(Unit*)u
{
    int ab;
    Player* p = self;
    if (p->m_mode == mdMOVE && p->m_curloc == u->m_loc) return true;
    ab = m_globalVar->m_map[p->m_curloc];
    return (m_globalVar->m_typ[ab] >= A && m_globalVar->m_own[ab] == p->m_num);
}

// Return true if we're sitting on an owned city.
-(BOOL)Cittst
{
    int ab;
    Player* p = self;
    
    ab = m_globalVar->m_map[p->m_curloc];
    return (m_globalVar->m_typ[ab] == X && m_globalVar->m_own[ab] == p->m_num);
}

//Print current mode if necessary.
-(void)SetMode:(int)newMode
{
    static char* modmsg[] = 
    {
        "           \n",
        "Move       \n",
        "Survey     \n",
        "Direction  \n",
        "From To    \n",
        "City Prod  \n"
    };
    
    if (m_mode != newMode)          // if it is a new mode
    {
         NSString* str1 = [NSString stringWithCString:modmsg[newMode] encoding:NSUTF8StringEncoding];
        NSString* str = [NSString stringWithFormat:@"%@", str1 ];
        [m_display->m_text cmes:[m_display->m_text DS:2] type: str ];
//        if (newMode == mdSURV || newMode == mdDIR ||
//            m_mode == mdSURV || m_mode == mdTO || m_mode == mdDIR)
            m_mode = newMode;
    }
}

// There was a command error
-(void)CmdError
{
    [m_display->m_text bell];
    [m_display valcmd:m_mode];
}

//Type out information on what we're sitting on.
-(void)TypHdg
{
    int ab;
    loc_t loc;
    Player* p = self;
    loc = p->m_curloc;              // current location
    ab = m_globalVar->m_map[loc];   // get map val of where we are
    if (m_globalVar->m_own[ab] == p->m_num)  //only if it's ours
    {
        
        if (m_globalVar->m_typ[ab] == X) {  // if it's a city
            [m_display typcit:p city:[m_sub fndcit:loc]];
        }
        else {
            [p->m_display headng:[m_move fnduni:loc]];
        }
    }
}

//If it's an army moving onto a troop transport in fnFI mode, put the army to sleep.
-(void)ChkSleep:(Unit*)u direction:(int)r2
{
    uint loc, ab;
    Player* p = self;
    
    if (u->m_typ != A) return;      // if not an army
    loc = u->m_loc + [m_globalVar arrow:r2];
    ab = m_globalVar->m_map[loc];
    if (m_globalVar->m_typ[ab] != T || m_globalVar->m_own[ab] != p->m_num)
        return;
    if ([m_move fnduni:loc]->m_ifo != fnFI)     // if not in fill mode
        return;
    u->m_ifo = fnSE;                            // put army in sentry mode
}

//Ask him if he's sure he wants to do this. Return true if he's sure
-(BOOL)RuSure
{
    return [m_display rusure];
}

/*Given a unit number and a trial move, see if it's ok.
 *Note it's ok to attack enemy pieces (even ships against armies!).
 *Watch out for case with r2 = -1 (stay in place)!
 *Use: seeifok(uninum, r2), input:unit number, trial move. Return true if the movement is ok
 */
-(BOOL)Seeifok:(Unit*)u direction:(int)r2
{
    loc_t z6;
    int ac, ab, type;
    Player* p = self;
    z6 = u->m_loc + [m_globalVar arrow:r2];             // see where we're going
    ab = m_globalVar->m_map[u->m_loc];                  // see where we are
    ac = m_globalVar->m_map[z6];                        // see where we are going
    type = u->m_typ;                                    // what's our unit type?
    if (type == A)                                      // if dealing with an A
    {       
        if (ac == MAPland)                              // If '+'
            return true;
        if (m_globalVar->m_typ[ac] == X)                // if attacking a city
            return m_globalVar->m_own[ac] != p->m_num;  // ok if not our own city
        if (r2 == -1)                                   // if staying put
            return true;
        if (m_globalVar->m_typ[ab] == T && m_globalVar->m_sea[ac])  // can't move from T onto sea
            return false;
        if ((m_globalVar->m_typ[ac] >= A) && (m_globalVar->m_own[ac] != p->m_num))
            return true;                                        // ok if enemy
        return m_globalVar->m_typ[ac] == T && ![m_move Full:[m_move fnduni:z6]];        // not full T
    }
    
    if (ac == MAPsea)           // if '.'
        return true;
    if ((m_globalVar->m_typ[ac] >= A) && m_globalVar->m_own[ac] != p->m_num)
        return true;                    // it's enemy
    if (m_globalVar->m_typ[ac] == X && m_globalVar->m_own[ac] == p->m_num)      // if owned city
        return ![m_mapManager aboard:u];                                   // false if T (C) with As (Fs) aboard
    if (type == F && (ac == MAPland || (m_globalVar->m_typ[ac] == C && ![m_move Full:[m_move fnduni:z6]])))
        return true;
    return r2 == -1;
}

/*Handle human function moves
 *Input: *pr2 = pointer to move variable
 *Output: r2 = selected move if true
 *Return true if a move has been selected or false if caller must pick a move*/
-(BOOL)MyCode:(Unit*)u direction:(int*)pr2
{
    int loc, type, ab, ifo, ila;
    
    Player* p = self;
    loc = u->m_loc;
    type = u->m_typ;
    ab = m_globalVar->m_map[loc];
    ifo = u->m_ifo;
    ila = u->m_ila;
    
    if([self Eneltr:loc])                   // if enemies in ltr
    {
        u->m_ifo = 0;                       // wake up
        return false;                       // caller must pick move
    }
    
    // take care of fipaths
    if ((type == F) && m_globalVar->m_typ[ab] == X)         // if fighter in a city
    {
        City* c = [m_sub fndcit:loc];                      // find the city
        if (c->m_fipath)                                    // if there is one
        {
            ila = u->m_ila = c->m_fipath;
            ifo = u->m_ifo = fnMO;
        }
    }
    
    if (type == A &&            // if army and
        [self Citltr:loc direction:pr2])        // unowned city in ltr
        return false;                           // caller must pick move
    
    switch (ifo) {
        case fnAW:
        {
            return false;                       // caller picks move
            break;
        }
        case fnSE:
        {
            *pr2 = -1;          // stay put
            return true;
        }
        case fnRA:
        {
            if (type == A)          // if army
            {
                if ([self Tltr:loc direction:pr2])      // if a T to get on
                {
                    u->m_ifo = 0;                       // wake up
                    return true;
                }
            }
            *pr2 = [m_empire Random:8];         // pick a move at random
            if ([self Around:u direction:pr2])  // if we got a move
                goto di2;
            return false;
        }
        case fnMO:
        {
            *pr2 = [m_mapManager movdir:loc location:ila];   // move from loc to ila
            if (*pr2 == -1)                             // if arrived at lia
            {
                u->m_ifo = 0;                          // wake up
                return false;
            }
            return [p OkMove:u direction:*pr2];
        }
        case fnDI:
        {
            *pr2 = ila;         // set inital move
        di2:
            if ([m_mapManager border:loc + [m_globalVar arrow:*pr2]])      // if trial move is bad
                return false;
            if (type == F)                  // if fighter
                if (u->m_hit == m_globalVar->m_typx[F]->m_hittab / 2)   // at 1 / 2 range
                    return false;
            return [p OkMove:u direction:*pr2];
        }
        case fnFI:
        {
            if ([m_move Full:u])                // if T or C is full
            {
                u->m_ifo = 0;                   // wake up
                return false;
            }
            *pr2 = -1;                          // stay put
            return true;
        }
        default:
            return false;                       // bad ifo
            break;
    }
}

// Given a unit number and a trial move, see if it's ok.
// Input: uninum = unit number, r2 = the trial move, Return true if the move is ok
-(BOOL)OkMove:(Unit*)u direction:(int)r2
{
    int z6, ac, ab, type;
    Player* p = self;
    z6 = u->m_loc + [m_globalVar arrow:r2];                 // see where we're going
    if ([m_mapManager border:z6])                                  // if on edge
        return false;
    ac = m_globalVar->m_map[z6];                            // see where we are going
    if ((m_globalVar->m_typ[ac] >= A) && (m_globalVar->m_own[ac] != p->m_num))
        return false;               // it's enemy
    ab = m_globalVar->m_map[u->m_loc];              // see where we are
    type = u->m_typ;                                // what's our unit type?
    if (type == A)                                  // if dealing with an A
    {
        Unit * ut;
        if (ac == MAPland)                  // if '+'
            return true;
        if ((m_globalVar->m_typ[ab] == T) && m_globalVar->m_sea[ac])         // can't move from T onto sea
            return false;
        if (m_globalVar->m_typ[ac] != T)                                    // it it's not an owned T
            return false;
        ut = [m_move fnduni:z6];
        if ((p->m_playerType == Computer) && u->m_hit < m_globalVar->m_typx[T]->m_hittab && u->m_ifo == IFOdamaged)
            return false;                       // don't get on damaged T
        return ![m_move Full:ut];               // can't get on it it's full
    }
    
    if (ac == MAPsea)                       // if '.'
        return true;
    if (m_globalVar->m_typ[ac] == X && m_globalVar->m_own[ac] == p->m_num)              // if owned city
    {
        if (u->m_ifo == IFOloadarmy)            // if computer strategy
            return false;
        if ([m_mapManager aboard:u])                   // if T (C) with As (Fs) aboard
            return false;
        return true;                            // can move into city
    }
    if (type == F && (ac == MAPland || (m_globalVar->m_typ[ac] == C && ![m_move Full:[m_move fnduni:z6]])))
        return true;
    return false;
}

// For a human player, get a production phase for a city.
//Input: citnum, Output: city[citnum].phs
-(void)Phasin:(City*)c
{
    loc_t loc;
    int ab, i;
    Player* p = self;
    Display* d = p->m_display;
    text *t = d->m_text;
    
    loc = c->m_loc;             // city location
//    if (![d insect:loc location:2])                 // if not in current sector
//        [self Center:loc];                          // center sector about city

    i = 0; // dialogCity seelct(c.phs)
    ab = m_globalVar->m_typx[i]->m_unichr;
    
    [t bell];
    [t curs:[t DS:0] + 25 ];
    [t output:ab];
    c->m_phs = i;               // set city phase
    c->m_fnd = p->m_round + m_globalVar->m_typx[i]->m_phstart;
    
    [m_display delay:1];
}

//Look for unloaded Ts in LTR.
//Use: tltr(loc, &tr)
//Input: *pr2 = place to store direction, loc = location
//Output: *pr2 = if (true) then direction of unloaded T
//Return true if there is an unloaded T in LTR
-(BOOL)Tltr:(int)loc direction:(int*)pr2
{
    int d, z6;
    Unit* u;
    for (d = 8; d--;)               // loop thru directions
    {
        z6 = loc + [m_globalVar arrow:d];           // trial location
        if (m_globalVar->m_typ[m_globalVar->m_map[z6]] != T)                // if any troop transport
            continue;                               // try next direction
        u = [m_move fnduni:z6];                 // find unit number of T
        if (u->m_own == m_num &&                // if we own it and
            ![m_move Full:u])                   // the T isn't full
        {
            *pr2 = d;                           // we found one
            return true;
        }
    }
    return false;                               // didn't find one
}

//Return true if there is an enemy unit in LRT.
//Use: eneltr(loc)
//Input: loc
-(BOOL)Eneltr:(int)loc
{
    int r2, ab;
    for (r2 = 8; r2--;)
    {
        ab = m_globalVar->m_map[loc + [m_globalVar arrow:r2]];
        if (m_globalVar->m_typ[ab] >= A && m_globalVar->m_own[ab] != m_num)
            return true;
    }
    return false;
}

//Search for unowned cities in LTR.
//Use: citltr(loc, &r2)
//Input: &t2, loc
//Output: if true then r2 = direction of unowned city
//else r2 preserved.
//Return true if unowned city in LTR
-(BOOL)Citltr:(int)loc direction:(int*)pr2
{
    int i, ab;
    for (i = 8; i--;)
    {
        ab = m_globalVar->m_map[loc + [m_globalVar arrow:i]];
        if (m_globalVar->m_typ[ab] == X && m_globalVar->m_own[ab] != m_num)
        {
            *pr2 = i;                               // return direction of city
            return true;
        }
    }
    return false;
}

/*===================================================Computer strategy =========================================*/
//Calculate move for computer piece.
//Designed to run concurrently with hmove(), but is not itself
//reentrant! i.e. cmove() cannot calll idle().
//Use: cmove(uninum, &r2);
//Output: *pr2 = direction to move
//Return false if move not completed or true if move successfully completed.
-(BOOL)CMove:(Unit*)u direction:(int*)pr2
{
    Player* p = self;
    Display* d = p->m_display;
    
    u->m_abd = [m_mapManager aboard:u];                            // count how many are aboard
    [self Arrloc:u->m_loc];                                 // update loci & troopt
    if (p->m_watch)
    {
//        if (![d insect:u->m_loc location:2])
//            [self Center:u->m_loc];
        p->m_curloc = u->m_loc;
        [d headng:u];                                       // type out the heading
        [d pcur:p->m_curloc];
    }
//versio None    
//    if ([self iFoeva:u]) 
//    {// see if we need a new ifo
//        [m_display->m_text imes:@" newifo " ];
//        [self NewIfo:u];                                    // select a new ifo
//        [m_display->m_text curs:(0x100 + 47)];
//        [p->m_display fncprt:u];
//    }
//    else {
//        [m_display->m_text imes:@" movsel "]; 
//    }
//    *pr2 = [self Movsel:u];                                 // select a trial move
//    
//    [m_display->m_text cmes:[m_display->m_text DS:2 ] type:@"movsel: " ];
//    [m_display->m_text decprt: *pr2]; 
//    [self Movcor:u direction:pr2];
//    
//    [m_display->m_text imes:@"movcor: "];
//    [m_display->m_text decprt:(*pr2)];
//    [m_display->m_text deleol ];
//    
//    if( !p->m_watch)
//        return 1;
    
    if( [self iFoeva:u] )
        [self NewIfo:u];
    
    *pr2 = [self Movsel:u];
//    dir_t oldr2 = *pr2; // return corrected move
    [self Movcor:u direction:pr2];
    
    return 1;

}
//Evaluate IFO to see if we should change it.
//Output: unit[uninum].lia may change
//Return true if a new IFO needs to be selected
-(BOOL)iFoeva:(Unit*)u
{
    // if it's a damaged ship, look for a port to go to
    
    if (u->m_typ >= D &&                // if it's a ship and
        u->m_hit <= (m_globalVar->m_typx[u->m_typ]->m_hittab >> 1) &&   // half damaged and
        u->m_ifo != IFOdamaged &&                               // not already heading for port
        (u->m_typ != T || !u->m_abd))                           // not a T with As aboard
        [self Port:u];                                          // search for a port
    
    // if it's a T with u.ifo != IFOloadarmy and no armes aboard, clear u.ifo
    if (u->m_typ == T && u->m_ifo != IFOloadarmy && u->m_abd == 0 && u->m_ifo != IFOdamaged)
        u->m_ifo = IFOnone;
    
    switch (u->m_ifo) {
        case IFOnone:
        case IFOescort:
        case IFOfolshore:
        case IFOonboard:    return true;            // select a new ifo
        case IFOgotoT:      return [self ifo_gotoT:u];
        case IFOdirkam:     return [self ifo2:u];
        case IFOdir:        return [self ifo3:u];
        case IFOtarkam:
        case IFOtar:
        case IFOcity:       return [self ifo_city:u];
        case IFOgotoC:      return [self ifo6:u];
        case IFOdamaged:    return [self ifo8:u];
        case IFOstation:    return [self ifo9:u];
        case IFOgstation:   return [self ifo10:u];
        case IFOcitytar:    return [self ifo11:u];
        case IFOshipexplor: return [self ifo13:u];
        case IFOloadarmy:   return [self ifo14:u];
        case IFOacitytar:   return [self ifo15:u];
        default:
            break;
    }
    return false;
}

//Go to TT# (armies only)
//Input: u.lia = TT unit number
-(BOOL)ifo_gotoT:(Unit*)u
{
    Unit* ua = m_globalVar->m_unit[u->m_ila];
    if (ua->m_typ != A || ua->m_ifo != IFOloadarmy ||           // not a T looking for As
        ua->m_own != m_num ||                                   // if we don't own it
        !ua->m_loc)                                             // if T doesn't exist
        return true;
    if (m_globalVar->m_typ[m_globalVar->m_map[u->m_loc]] == T)              // if aboard a T
        return true;
    if (([m_empire Ranq] & 8) && [self Armtar:u])
        return true;
    ua->m_ila = u->m_loc;                           // set ila of T
    return false;
}

//Directional, kamikaze (Fs only)
//u.ila = direction
-(BOOL)ifo2:(Unit*)u
{
    if (![m_empire Ranq] & 15)              // change direction 1 / 16 times
        u->m_ila = (u->m_ila + u->m_dir) & 7;
    return false;
}

//Directional u.ila = direction
-(BOOL)ifo3:(Unit*)u
{
    if (u->m_typ == F && u->m_hit == 10)            // if fighter at half range
        return true;                // pick a new ifo
    if (![m_empire Ranq] & 15)              // change direction 1 / 16 times
        u->m_ila = (u->m_ila + u->m_dir) & 7;
    return false;
}

//Go to carrier # (Fs only)
//u.lia = carrier #
-(BOOL)ifo6:(Unit*)u
{
    int dloc;
    Unit * ua = m_globalVar->m_unit[u->m_ila];
    dloc = ua->m_loc;                       // locationm of carrier
    if (!dloc) return true;                 // if carrier dones't exist
    if (ua->m_own != m_num) return true;    // if we don't own it
    if (u->m_loc == dloc)   return true;        // we've arrived
    if (ua->m_typ != C)         return true;    
    return [m_mapManager dist:u->m_loc location:dloc] > u->m_hit;  // true if out of range
    return true;
}

//go to target location (Fs, ships)
// Used for ifo4, ifo5, ifo_city
-(BOOL)ifo_city:(Unit*)u
{
    if (u->m_loc == u->m_ila)               // if we have arrived
        return true;
    
    if (u->m_typ == A)
    {
        if (m_globalVar->m_map[u->m_ila] == MAPsea)
            return true;
        return ![self Patblk:u->m_loc to:u->m_ila];         // true if army can't get there
    }
    
    if (u->m_typ == F)
    {
        int d;
        d = [m_mapManager dist:u->m_loc location:u->m_ila];        // distance to target
        if (d > u->m_hit)                                   // if out of range
            return true;
        if (u->m_ifo == IFOtar && d == 1 && m_globalVar->m_typ[m_globalVar->m_map[u->m_ila]] == X)
            return true;
        return false;
    }
    return ![self Patsea:u->m_loc to:u->m_ila];                 // true if ship can't get there
}

//Go to port (ship is damaged)
//u.ila = loc of city
-(BOOL)ifo8:(Unit*)u
{
    if (u->m_hit == m_globalVar->m_typx[u->m_typ]->m_hittab)    // if ship is repaired
        return true;
    if (m_globalVar->m_own[m_globalVar->m_map[u->m_ila]] != m_num)      // if we don't own the city
        return ![self Port:u];                                      // search for new port
    return false;
}

//Stationed (for carriers)
//u.ila = stationed location
//Return true if no target cities are within fighter range
-(BOOL)ifo9:(Unit*)u
{
    int i;
    for (i = CITMAX; i--;)
    {
        if (!m_target[i])                   // if city is not a target
            continue;
        if ([m_mapManager dist:u->m_ila location:m_globalVar->m_city[i]->m_loc] <= 10)       // if within range
            return false;
    }
    return true;
}

//Heading towards station (carriers)
//u.ila = station
-(BOOL)ifo10:(Unit*)u
{
    char ab;
    if (u->m_loc == u->m_ila)           // if we arrived at station
    {
        u->m_ifo = 9;                   // station the C at u->m_ila
        return false;
    }
    ab = m_globalVar->m_map[u->m_ila];          // see what's at the station
    return ab != MAPunknown && ab != MAPsea;    // true if not blank or sea
}

//City Target (ships)
//u.ila = city loc
-(BOOL)ifo11:(Unit*)u
{
    int r0;
    if (![self Patsea:u->m_loc to:u->m_ila])            // if we don't own city
        return false;
    r0 = [m_mapManager dist:u->m_loc location:u->m_ila];       // r0 = distance to our city
    return (r0 <= 1) || (r0 > 10);                      // if nearby, continue on
}

//Look at unexplored territory (ships)
//u.ila = loc of unexplored territory
-(BOOL)ifo13:(Unit*)u
{
    if (m_globalVar->m_map[u->m_ila])                   // if territory is explored
        return true;                                    // pick a new ifo
    return ![self Patsea:u->m_loc to:u->m_ila];         // pick new ifo if no path
}

//Load up armies (troop transports)
// Ila can be either the loc of an army-producing city or the loc
//of an army which wants to get aboard.
//Ila can be:
//1-loc of an army-producing city.
//2-within a space of an army that wants to get aboard
//3-a direction
-(BOOL)ifo14:(Unit*)u
{
    int i, ab;
    if (m_globalVar->m_typ[m_globalVar->m_map[u->m_ila]] == X)          // if location of city
    {
        if (m_globalVar->m_own[m_globalVar->m_map[u->m_ila]] != m_num || // if we don't own it any more
            [m_sub fndcit:u->m_ila]->m_phs != A)
            return true;
    }
    else if (u->m_ila > 7)                                              // if it's not a direction
    {
        for (i = 8; i-- >= 0;)                                          // thru 9 directions
        {
            ab = m_globalVar->m_map[u->m_ila + [m_globalVar arrow:i]];
            if (m_globalVar->m_typ[ab] == A && m_globalVar->m_own[ab] == m_num)
            {
                return (m_round <= 150)                 // if in early part of gaem
                    ? u->m_abd >= u->m_hit              // don't fill up the T so much
                : u->m_abd >= (u->m_hit << 1);          // fill up T completely
            }
        }
        return true;
    }
    else if (([m_empire Ranq] & 7) == 1)
        return true;
    return (m_round <= 150)                 // if in early part of gaem
    ? u->m_abd >= u->m_hit              // don't fill up the T so much
    : u->m_abd >= (u->m_hit << 1);          // fill up T completely
}

//City Target (armies)
//u.lia = city  location
//Use of patblk() must match up with usage in armtar() in ARMYMV!
-(BOOL)ifo15:(Unit*)u
{
    if (m_globalVar->m_own[m_globalVar->m_map[u->m_ila]] == m_num)      // if we own the city
        return true;
    return ![self Patblk:u->m_loc to:u->m_ila];
    return true;
}

//Select a new ifo and u.ila for the unit.
//Input: local variables Output: u.ifo, u.ila, uniifo, uniila
-(void)NewIfo:(Unit*)u
{
    switch (u->m_typ) {
        case A:
        {
            [self ARMYif:u];
            break;
        }
        case F:
        {
            [self FIGHif:u];
            break;
        }
        case T:
        {
            [self TROOif:u];
            break;
        }
        case C:
        {
            [self CARRif:u];
            break;
        }
        case D:
        case S:
        case R:
        case B:
        {
            [self SHIPif:u];
            break;
        }
        default:
            break;
    }
}

//Select a move given ifo and u.ila.
//Input: local variables Returns:move
-(int)Movsel:(Unit*)u
{
    dir_t r;
    
    switch (u->m_ifo)
    {   case IFOgotoT:
	    case IFOgotoC:
	    case IFOescort:
        {
		    r = [self Seluni:u];
		    break;
        }
	    case IFOdirkam:
	    case IFOdir:
        {
		    r = [self Seldir:u];
		    break;
        }
	    case IFOtarkam:
	    case IFOtar:
	    case IFOcity:
	    case IFOdamaged:
	    case IFOstation:
	    case IFOgstation:
	    case IFOcitytar:
	    case IFOshipexplor:
	    case IFOloadarmy:
	    case IFOacitytar:
        {
		    r = [self Selloc:u];
		    break;
        }
	    case IFOfolshore:
        {
		    r = [self Selfol:u];
		    break;
        }
	    case IFOonboard:
        {
		    r = -1;		// don't move
		    break;
        }
	    default:
        {
            [m_display->m_text cmes:[m_display->m_text DS:2] type:@"ifo:"];
            [m_display->m_text decprt:u->m_ifo]; 
        }
    }
    return r;
}

//Directional, but follow the shore.
//Input: u.ila = direction
-(int)Selfol:(Unit*)u
{
    dir_t r2;
    assert(u->m_ila >= 0 && u->m_ila < 8);
    r2 = (u->m_ila - u->m_dir * 3) & 7;	// go back 3 & normalize
    if ([self OkMove:u direction:r2])			// if move is ok
	    r2 = u->m_ila;			// don't go back 3
    if ([self Around:u direction:&r2])			// if found a good move
	    u->m_ila = r2;			// set new direction
    return r2;
}

//Directional Input: u.ila = direction (0..7, not -1!)
-(int)Seldir:(Unit*)u
{
    int r2;
    assert(!(u->m_ila & ~7));
    r2 = u->m_ila;
    if ([self Around:u direction:&r2])  // if found a good move
        u->m_ila = r2;                  // set new direction
    return r2;
}

//Move towards a unit number.
//u.ila = unit number
-(int)Seluni:(Unit*)u
{
    assert(u->m_ila < m_globalVar->m_unitop);
    assert([m_mapManager chkloc:m_globalVar->m_unit[u->m_ila]->m_loc]);
    return [self Locs:u location:m_globalVar->m_unit[u->m_ila]->m_loc];
}

//Move towards a location
//u.ila = number
-(int)Selloc:(Unit*)u
{
    if (u->m_ila <= 7)          // if it's a direction
        return [self Seldir:u];         //directional
    return [self Locs:u location:u->m_ila];             // get move
}

//Move from u.loc to toloc.
//Return move
-(int)Locs:(Unit*)u location:(int)toloc
{
    int r2, flag;
    static Byte lp[PLYMAX][MAPMAX];             // move on land for armies
    static Byte ap[PLYMAX][MAPMAX];             // move on sea for fighters
    static Byte sp[PLYMAX][MAPMAX];             // move on sea for ships
    static int inited;
    
    if (u->m_loc == toloc)              // if at destination
        return -1;                      // no move
    if (!inited)
    {
        // initialize arrays
        uint p, m;
        inited++;
        for (p = 0; p < PLYMAX; p++)
        {
            sp[p][0] = 1; ap[p][0] = 1; lp[p][0] = 1;       // ' '
            sp[p][1] = 0; ap[p][1] = 0; lp[p][1] = 1;       // *
            sp[p][2] = 1; ap[p][2] = 1; lp[p][2] = 0;       // .
            sp[p][3] = 0; ap[p][3] = 1; lp[p][3] = 1;       // +
            
            for (m = 4; m < MAPMAX; m++)
            {
                sp[p][m] = m_globalVar->m_sea[m];
                if (((m - 4) / 10) == p)
                {
                    // it's our city or unit
                    ap[p][m] = (m_globalVar->m_typ[m] == X || m_globalVar->m_typ[m] == C); 
                    lp[p][m] = m_globalVar->m_land[m];
                }
                else {
                    // it's an enemy city or unit
                    ap[p][m] = m_globalVar->m_typ[m] != X;
                    lp[p][m] = (m_globalVar->m_typ[m] == X || m_globalVar->m_land[m]);
                }
            }
        }
    }
    
    switch (u->m_typ) {
        case A:
        {
            flag = [self Patho:u->m_loc to:toloc direction:u->m_dir state:lp[m_num - 1] sndDirection:&r2];
            break;
        }   
        case F:
        {
            flag = [self Patho:u->m_loc to:toloc direction:u->m_dir state:ap[m_num - 1] sndDirection:&r2];
            break;
        }
        default:
        {
            flag = [self Patho:u->m_loc to:toloc direction:u->m_dir state:sp[m_num - 1] sndDirection:&r2];
            break;
        }
    }
    
    if( !flag && u->m_typ == T && m_watch && u->m_ifo == IFOcitytar )
    {
        [m_display->m_text TTcurs:0x410];
        [m_display->m_text TTin];
    }
    
    if (!flag)                                          // if didn't find a move
        r2 = [m_mapManager movdir:u->m_loc location:toloc];    // default move
    return r2;
}

//Given a move, r2, correct it.
-(void)Movcor:(Unit*)u direction:(int*)pr2
{
    switch (u->m_typ)
    {   case A:	
        {
            [self ARMYco:u direction:pr2];
             break;
        }	   
        case F:
        {
            [self FIGHco:u direction:pr2];
		    break;
        }
	    case D:
	    case T:
	    case S:
	    case R:
	    case C:
	    case B:	
        {
            [self SHIPco:u direction:pr2];
		    break;
        }
	    default:
		    assert(0);
    }
}

//Given a unit number and direction, look around
//For territory to explore, giving priority to
//moving diagonally.
//Input: *r2 where to put direction (watch out for -1!)
//Returns true if *r2 = direction to go or false if *r2 preserved.
-(int)Explor:(Unit*)u direction:(int*)pr2
{
    int r, ab, i;
    loc_t loc, loc2;
    dir_t r2 = -1;
    Player* p = self;
    loc = u->m_loc;
    r = *pr2 | 1;               // diagonal
    for(i = 8; i--;)            // loop thru 8 dirs
    {
        r &= 7;                 // normalize
        if ([p OkMove:u direction:r])   // if good move
        {
            loc2 = loc + [m_globalVar arrow:r] * 2;         // move twice in r direction
            ab = m_globalVar->m_map[loc2];
            if (ab == MAPunknown)               // if unexplored
            {
                *pr2 = r;                       // set direction
                return true;
            }
            
            // look another step in r direction
            if ((NEW && ([m_mapManager border:loc] == 0) &&
                ((u->m_typ == A) && (ab == MAPland))) ||
                 ((u->m_typ >= D) && (ab == MAPsea)) || (u->m_typ == F)) 
            {
                loc2 += [m_globalVar arrow:r];
                
                if ( loc2 >= MAPSIZE ) {
                    loc2 = MAPSIZE-1;
                }
                
                if ( loc2 < 0 ) {
                    loc2  = 0;
                }
                ab = m_globalVar->m_map[loc2];
                if (ab == MAPunknown)
                    r2 = r;
            }
        }
        r += 2;                 // next direction
        if (i == 4)             // if halfway thru
            r++;                // leave diagonals
    }
    
    if (r2 != -1)
    {
        *pr2 = r2;
        return true;
    }
    return false;           // nothing to explore
}

//Look for unexplored territory.
//Return 0 if no unexplored territory found else loc of unexplored territory
-(int)Expshp
{
    int i;
    loc_t loc;
    unsigned char* map;
    map = m_map;
    for (i = 20; i--;)			// do 10 tries
    {   loc = (Mcolmx+2) + [m_empire Random:((Mrowmx-1)*(Mcolmx+1) - 2)];	// pick loc from 101..5898
	    if (map[loc] == MAPunknown &&	// if location is blank	and
            ![m_mapManager border:loc])		// it isn't on the border
		    return loc;		// then we got one
    }
    return 0;
}

//Remove targets from loci and troopt if loc loc is on them.
//Input: loc
-(void)Arrloc:(int)loc
{
    uint i;
    uint *p1;
    Player* p = self;
    p1 = &p->m_troopt[0][0];
    for (i = 6 * 5; i--; p1++)
    {
        if (loc == *p1)
            *p1 = 0;
    }
    p1 = &p->m_loci[0];
    for (i = LOCMAX; i--; p1++)
    {
        if (loc == *p1)
            *p1 = 0;
    }
}

//Look around loc to see if there is anything to attack.
//if so, set direction, As will not attack Fs over sea, and ships will not attack Fs over land.
//Return true if r2 was modified
-(BOOL)Eneatt:(Unit*)u direction:(int*)pr2 mask:(int)msk
{
    int i, ab, type;
    loc_t loc;
    loc = u->m_loc;
    type = u->m_typ;
    for (i = 8; i--;)
    {
        ab = m_globalVar->m_map[loc + [m_globalVar arrow:i]];
        if (m_globalVar->m_own[ab] == m_num ||      // if we own it, it's not enemy
            m_globalVar->m_typ[ab] < A ||           // if not a unit
            !(msk & m_globalVar->m_msk[m_globalVar->m_typ[ab]]))   // if type is not in mask
            continue;
        if (m_globalVar->m_typ[ab] == F)                // if attacking a fighter
        {
            if ((type == A && m_globalVar->m_sea[ab]) || (type >= D && m_globalVar->m_land[ab]))
                continue;
        }
        *pr2 = i;                   // set move
        return true;
    }
    return false;
}

//Given a move, look around till one that satisfies okmove()
// us fiybdm abd retyrb ut ub *pr2
//Return true if we found a good move. false if we didn't find one (*pr2 = -1)
-(BOOL)Around:(Unit*)u direction:(int*)pr2
{
    int i;
    dir_t r2;
    Player* p = self;
    assert(u->m_dir == 1 || u->m_dir == -1);
    
    r2 = *pr2 & 7;              // in case *pr2 = -1;
    for (i = 8; i--;)           // 8 directions
    {
        if([p OkMove:u direction:r2])   // if move is ok
        {
            *pr2 = r2;
            return true;
        }
        r2 = 7 & (r2 + u->m_dir);           // new direction
    }
    *pr2 = -1;                  // stay put
    return false;
}

//Select a new ifo and ila for an army
-(void)ARMYif:(Unit*)u
{
    uint loc, ab;
    dir_t r2;
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    ab = m_globalVar->m_map[loc];
    
    if (m_globalVar->m_typ[ab] == T)                // if we're aboard a T
    {
        u->m_ifo = IFOonboard;                      // set to indicate we're aboard
        if ([m_move Sursea:u])        return;       // if surrounded by sea
        if ([self Armtar:u])        return;         // if cities to attack
        r2 = 0;                                     // for explor()
        if ([self Explor:u direction:&r2])  return; // if no territory to explore
        u->m_ifo = IFOfolshore;                     // follow shore
        u->m_ila = [m_move Randir];                 // set direction
    }
    
    if (((u->m_dir >> 1) ^ m_round) & 1)            // get arbitrary but predictable #
    {
        if ([self Armtar:u])                        // don't call armtar() every time
            return;
    }
    
    if ([self Armloc:u])        return;             // if loci to attack
    if ([self Armtt:u])         return;             // if TTs to get aboard
    if (u->m_ifo == IFOfolshore)                    // if already following shore
        return;
    u->m_ifo = IFOfolshore;                     // follow shore
    u->m_ila = [m_move Randir];                 // set direction
}

//Given a trial move r2, correct that move.
//Output: r2 = corrected move
-(void)ARMYco:(Unit*)u direction:(int*)pr2
{
    int at;
    Player* p = self;
    if ([self Citltr:u->m_loc direction:pr2]) return;                   // if unowned cities
    if ([self Explor:u direction:pr2])  return;                         // if territory to explore
    if (m_globalVar->m_typ[m_globalVar->m_map[u->m_loc]] == T)          // if aboard a trnasport
        at = mA | mF;                   // attack only As or Fs
    else if (NEW && u->m_ifo == IFOacitytar)
        at = mA | mT;
    else {
        at = mA | mF | mD | mT | mS;                        // else attack AFDTSs
    }
    
    if ([self Eneatt:u direction:pr2 mask:at])              // if anything to attack
        return;
    if (NEW && u->m_ifo == IFOfolshore)
    {
        // look around for TT to get on
        int i;
        loc_t loc;
        
        for (i = 0; i--;)
        {
            loc = u->m_loc + [m_globalVar arrow:i];
            if (m_globalVar->m_typ[m_globalVar->m_map[loc]] == T && [p OkMove:u direction:i])
            {
                *pr2 = i;
                return;
            }
        }
    }
    
    if (*pr2 == -1) return;         // if stay put
    [self Around:u direction:pr2];
}

//Search for a target city for the army to attack. If found, set ifo and ila and return true.
-(BOOL)Armtar:(Unit*)u
{
    int loc = 0, loccit = 0;
    int i, end;
    Player* p = self;
    int distance;
    if (NEW)
        distance = 20;
    else {
        distance = 12;
    }
    
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    
    i = end = [m_empire Random:CITMAX];     // select random city number
    do {
        if (p->m_target[i])                 // if the city is on our hit list
        {
            loccit = m_globalVar->m_city[i]->m_loc;     // get city location
            if (loccit &&                   // if city exists
                [m_mapManager dist:loc location:loccit] <= distance &&          // near to city
                [self Patblk:loc to:loccit])                                // push to city
            {
                u->m_ifo = IFOacitytar;            // attack city
                u->m_ila = loccit;                  // location of city to attack
                return true;
            }
        }
        i++;
        if (i >= CITMAX) i = 0;
    } while (i != end);
    return false;
}

//Find a target in loci[]. If found, set ifo and ila and return true.
-(BOOL)Armloc:(Unit*)u
{
    uint loc;
    uint* p1;
    uint i;
    Player* p = self;
    
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    
    p1 = &p->m_loci[0];             // get pointer to loci
    for (i = 0; i < LOCMAX; i++, p1++)          // loop thru loci
    {
        if (!*p1) continue;                     // if unit doesn't exist
        assert([m_mapManager chkloc:*p1]);             
        
        if ([m_mapManager dist:loc location:*p1] > 12) continue;       // if loci is too far away
        if ([self Patblk:loc to:*p1])                           // if it's reachable
        {
            u->m_ifo = IFOtar;
            u->m_ila = *p1;             // target location
            return true;
        }
    }
    return false;
}

//Search for a T for the army to get on.
//If found: set ifo, ila of army.
//Set ila of T such that the T will head towards the army.
//Return true Else return false.
-(BOOL)Armtt:(Unit*)u
{
    uint i, end;
    loc_t loc;
    Unit* ui;
    
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    
    i = end = [m_empire Random:m_globalVar->m_unitop];              // end at random unit #
    
    do {
        ui = m_globalVar->m_unit[i];
        if (ui->m_ifo == IFOloadarmy &&                 // must be looking for armies
            ui->m_typ == T &&                           // look for a transports
            ui->m_loc &&                                // if unit exists
            ui->m_own == m_num &&                       // if we own the unit
            [m_mapManager dist:loc location:ui->m_loc] <= 10)  // if T is near
        {
            u->m_ila = loc;                             // set ila of T to unit loc
            u->m_ifo = IFOgotoT;
            u->m_ila = i;                               // set ila to transport #
            return true;
        }
        i++;
        if(i >=  m_globalVar->m_unitop) i = 0;          // wrap around
    } while (i != end);
    return false;
}

//Select an ifo and ila for a fighter
-(void)FIGHif:(Unit*)u
{
    Player* p = self;
    
    u->m_fuel = u->m_hit;               // get amount of fual left
    if (u->m_fuel < m_globalVar->m_typx[F]->m_hittab)           // if F is airborne
    {
        if ([self Gocit:u]) return ;                    // look for city
        if ([self Gocar:u]) return;                     //then a carrier
    }
    else {
        u->m_fuel >>= 1;                // only let him go half way out
    }
    
    //look for enemy troop transports, then submarines.
    
    if ([m_move Fndtar:u location:&p->m_troopt[T - 2][0] entryNum:10])
        return;                     // look for Ts, then Ts
    
    if ([self Figtar:u])                // attack enemy city
        return;
    
    switch ([m_empire Random:3]) {
        case 0:
        {
            // move towards an enemy army location within range.
            if ([m_move Fndtar:u location:&p->m_loci[0] entryNum:LOCMAX])
                return;                                 // if found a loci[]        target
            if ([self Gocit:u]) return;                 // look for city
            if ([self Gocar:u]) return;                 // tehn carrier
            break;
        }  
        case 1: // to city or carrier
        {
            if ([self Gocar:u]) return;                 // then a carrier
            if ([self Gocit:u]) return;                 // look for city
            if ([m_move Fndtar:u location:&p->m_loci[0] entryNum:LOCMAX])
                return;                                 // if found a loci[]        target
        }
        default:
            break;
    }
    
    u->m_ila = [m_move Randir];
    u->m_ifo = IFOdir;
}

//Look for a city in range. If found, set ifo, ila, and return true;
-(BOOL)Gocit:(Unit*)u
{
    loc_t   loc = u->m_loc;
    int i, end, inc;
    City*   cmax;
    Player* p = self;
    
    assert([m_mapManager chkloc:loc]);
    
    i = end = [m_empire Random:CITMAX];         // set random end
    
    inc = ([m_empire Ranq] & 1) ? 1 : -1;           // pick 1 or -1
    cmax = nil;
    do {
        City * c = m_globalVar->m_city[i];
        
        if (c->m_own == p->m_num &&             // if owned
            c->m_loc &&                         // city exists
            c->m_loc != loc &&                  // not already there
            [m_mapManager dist:loc location:c->m_loc] <= u->m_fuel)            // within range
        {
            if (!cmax || c->m_round > cmax->m_round)
                cmax = c;               // newer city
        }
        
        i += inc;
        if (i >= CITMAX)    i = 0;
        if (i < 0)          i = CITMAX - 1;
    } while (i != end);
    
    if (cmax)
    {
        u->m_ifo = IFOcity;
        u->m_ila = cmax->m_loc;
        
        if (cmax->m_round)
            cmax->m_round--;            // age it
        return true;
    }
    return false;
}

//Same as gcit(), but finda carrier.
-(BOOL)Gocar:(Unit*)u
{
    uint end, i;
    loc_t loc, cloc;
    Unit*   uc;
    
    loc = u->m_loc;
    
    assert([m_mapManager chkloc:loc]);
    
    i = end = [m_empire Random:m_globalVar->m_unitop];
    
    do {
        if (i > m_globalVar->m_unitop) i = 0;       // wrap around
        uc = m_globalVar->m_unit[i];
        if (uc->m_typ == C &&               // if a carrier
            uc->m_loc &&
            uc->m_own == m_num &&           // if we own it
            (u->m_fuel == u->m_hit ||           // if looking for place to land
             uc->m_ifo == IFOstation) &&        // or C is stationed
            (cloc = uc->m_loc) != 0 &&          // C exists
            [m_mapManager dist:loc location:cloc] <= u->m_fuel)        // if near enough
        {
            u->m_ifo = IFOtar;
            u->m_ila = cloc;
            return true;
        }
        i++;
        if (i >= m_globalVar->m_unitop) i = 0;
    } while (i != end);
    return false;
}

//Search for a terget city for the army to attack, IF found, set ifo and ila and return true
-(BOOL)Figtar:(Unit*)u
{
    uint loc, loccit;
    int i, end;
    Player* p = self;
    loc = u->m_loc;
    
    assert([m_mapManager chkloc:loc]);
    
    i = end = [m_empire Random:CITMAX];         // select random city number
    do {
        if (p->m_target[i] &&                   // if the city is on our hit list
            m_globalVar->m_city[i]->m_own)      // and it's an enemy city
        {
            loccit = m_globalVar->m_city[i]->m_loc;         // get city location
            if (loccit &&               // if city exists
                [m_mapManager dist:loccit location:loccit] <= u->m_fuel)   // near to city
            {
                u->m_ifo = IFOtar;                                  // attack city
                u->m_ila = loccit;                                  // location of city to attack
                return true;
            }
        }
        i++;
        if (i >= CITMAX)        i = 0;
    } while (i != end);
    
    return false;                // failed;
}

//Correct the move that pr2 points to.
-(void)FIGHco:(Unit*)u direction:(int*)pr2
{
    if ([self Eneatt:u direction:pr2 mask:mA | mF | mD | mT | mS | mR | mC | mB])          // attack anything
        return;
    if (u->m_ifo == IFOdirkam ||                // if kamikaze
        u->m_hit > 10)                          // and plenty of fual
    {
        if ([self Explor:u direction:pr2])      // and territory to explore
            return;
    }
    if (*pr2 == -1) return;                     // if stay put
    [self Around:u direction:pr2];
}

//Find new ifo and ila for a T.
-(void)TROOif:(Unit*)u
{
    uint abd;
    loc_t z6;
    int flag;
    abd = [m_mapManager aboard:u];             // see how many are aboard
    assert(abd <= 8);
    
    if (!abd)                           // if none aboard
    {
        if ([self Armcit:u])            // look for army producting city
            return;
        u->m_ifo = IFOloadarmy;
        u->m_ila = [m_move Randir];     // select random direction
        return;
    }
    
    flag = [m_empire Ranq];
    if (flag & 1)           // 50%  chance
    {
        if ([self Trotar:u lookAll:flag & 2])           // if target city found
            return;
        z6 = [self Expshp];                             // places to explore
        if (z6)
        {
            u->m_ifo = IFOshipexplor;
            u->m_ila = z6;
            return;
        }
    }
    else {
        z6 = [self Expshp];
        if (z6)                     // if places to explore
        {
            u->m_ifo
            = IFOshipexplor;
            u->m_ila = z6;
            return;
        }
        if ([self Trotar:u lookAll:flag & 6])           // if target city found
            return;
    }
    
    if (u->m_ifo == IFOdirkam)  return;                 // if random direction already
    u->m_ifo = IFOdir;
    u->m_ila = [m_move Randir];                         // set random direction
}

//Select ifo, ila for D,S,R,B.
-(void)SHIPif:(Unit*)u
{
    loc_t z6;
    if ([self Shiptr:u]) return;        // look for enemy ships to attack
    if ([m_empire Ranq] & 1)            // 50% chance
    {
        if ([self Shipta:u])    return;             // look for target city
    }
    else {
        if ([self Shiptt:u])    return;             // look for TT to escort
    }
    z6 = [self Expshp];
    
    if (z6)                 // if places to explore
    {
        u->m_ifo = IFOshipexplor;
        u->m_ila = z6;
        return;
    }
    
    if (u->m_ifo == IFOdir)     return;             // if it's already 3
    u->m_ifo = IFOdir;
    u->m_ila = [m_move Randir];
}

//Select ifo and ila for carriers.
-(void)CARRif:(Unit*)u
{
    loc_t z6;
    
    if ([self Shiptr:u])                // look for enemy ships
    {
        u->m_ifo = IFOgstation;             // station at enemy ship loc
        return;
    }
    
    if ([self Shipta:u]) return;            // look for target city
    z6  = [self Expshp];
    if (z6)                                 // if places to explore
    {
        u->m_ifo = IFOshipexplor;
        u->m_ila = z6;
        return;
    }
    
    if (u->m_ifo == IFOdir)
    {
        return;                     // if it's already 3
    }
    
    u->m_ifo = IFOdir;
    u->m_ila = [m_move Randir];    
}

//Correct the move that pr2 points to.
-(void)SHIPco:(Unit*)u direction:(dir_t*)pr2
{
    int msknum;
    static int attmsk[6] =
    {	mF|mD|mT|mS,			// D:.FDT S...
     0,				// T:.... ....
     mD|mT|mS|mR|mC|mB,		// S:..DT SRCB
     mF|mD|mT|mS|mR|mC|mB,		// R:.FDT SRCB
     mD|mT|mC,			// C:..DT ..C.
     mF|mD|mT|mS|mR|mC|mB		// B:.FDT SRCB
    };
    static int escmsk[6] =
    {	mA|mR|mC|mB,			// D:A... .RCB
     mA|mF|mD|mS|mR|mC|mB,		// T:AFD. SRCB
     mA|mF,				// S:AF.. ....
     0,				// R:.... ....
     mA|mS|mR|mB,			// C:A... SR.B
     0				// B:.... ....
    };
    int m;
    
    if ([self Lodarm:u direction:pr2]) return;      // loading armiesl, stay put
    if (u->m_ifo != IFOloadarmy)                    // if not looking for armies
    {
        if (*pr2 == -1) return;                     // if stay put, then they put
        if (u->m_ifo != 8 &&                // if ship isn't damaged and
            [self Explor:u direction:pr2])  // territory to explore
            return;
    }
    msknum = u->m_typ - D;                  // get index into masks
    m = attmsk[msknum];
    if (m_globalVar->m_overpop && u->m_typ != T)
        m = mA|mF|mD|mT|mS|mR|mC|mB;	// attack anything
    if ([self Eneatt:u direction:pr2 mask:escmsk[msknum]])      // if anything to escape from
        *pr2 = (*pr2 + 3 + [m_empire Random:3]) & 7;    // move in opposite direction
    [self Around:u direction:pr2];
}

//Look for port to go to.
-(bool)Port:(Unit*)u
{
    loc_t loc, cloc;
    uint min, dtry, i;
    Player* p = self;
    loc = u->m_loc;
    
    assert([m_mapManager chkloc:loc]);
    
    min = 10000;                    // arbitrary # larger than any dist
    for (i = CITMAX; i--;)
    {
        if (m_globalVar->m_city[i]->m_own == p->m_num &&        // if own the city and
            (cloc = m_globalVar->m_city[i]->m_loc) != 0 &&       // city exists
             (dtry = [m_mapManager dist:loc location:cloc]) < min &&
             [m_mapManager edger:cloc] &&                              // it's a port city
             [self Patsea:loc to:cloc])                         // a path by sea
            {
                u->m_ifo = IFOdamaged;
                u->m_ila = cloc;
                min = dtry;                     // set new minimum
            }
    }
            
    return min != 10000;
}

//Looking for an army producing city.
//Return true if one is found
-(BOOL)Armcit:(Unit*)u
{
    uint loc, cloc, min, dtry, i;
    Player* p = self;
    loc = u->m_loc;
    
    assert([m_mapManager chkloc:loc]);
    min = 10000;                        // arbitrary # large than any dist
    
    for (i = CITMAX; i--;)
    {
       if (m_globalVar->m_city[i]->m_own != p->m_num)
           continue;                                    // don't own it
        if (m_globalVar->m_city[i]->m_phs != A)     continue;                   // if not army producing city
        cloc = m_globalVar->m_city[i]->m_loc;                                   // loc of city
        if (!cloc)      continue;                                   // city doesn't exist
        assert([m_mapManager chkloc:cloc]);
        
        dtry = [m_mapManager dist:loc location:cloc];              // distance to city
        if (dtry >= min)        continue;                   // not minimun
        if (![m_mapManager edger:cloc]) continue;                  // if not a port city
        if ([self Patsea:loc to:cloc])                      // if a path by sea
        {
            u->m_ifo = IFOloadarmy;
            u->m_ila = cloc;
            min = dtry;                                     // set new minimum
        }
    }
    
    return min != 10000;
}

//Look for a city target for a troop transport.
//Return true if one is found
-(BOOL)Trotar:(Unit*)u lookAll:(BOOL)flag
{
    loc_t loc, cloc;
    uint min, dtry, i;
    Player* p = self;
    
    if(!NEW)
        flag = 0;
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    min = 10000;                        // arbitrary # larger than any dist
L1:
    for (i = CITMAX; i--;)              // loop thru cities
    {
        if (!p->m_target[i])                    // if city is not a target
            continue;
        cloc = m_globalVar->m_city[i]->m_loc;       // loc of city
        if (!cloc)      continue;                   // city doesn't exist
        assert([m_mapManager chkloc:cloc]);
        if (flag && m_globalVar->m_own[m_globalVar->m_map[cloc]])           // if an owned city
            continue;
        dtry = [m_mapManager dist:loc location:cloc];                  // distance to city
        if (dtry >= min)    continue;                       // not minimum
        if (![m_mapManager edger:cloc])    continue;               // if not a port city
        if ([self Patsea:loc to:cloc])                      // if a path by sea
        {
            u->m_ifo = IFOcitytar;
            u->m_ila = cloc;
            min = dtry;                         // set new minimum
        }
    }
    
    if (flag && min == 10000)
    {
        flag = 0;
        goto L1;
    }
    return min != 10000;                    // true if we found one
}

//Look for city target for a ship
//Return true if one is found
-(BOOL)Shipta:(Unit*)u
{
    loc_t loc, cloc;
    uint min, dtry, i;
    Player* p = self;
    
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    min = 10000;                // arbitrary # larger than any dist
    for (i = CITMAX; i--;)              // loop thru cities
    {
        if (!p->m_target[i])                    // if city is not a target
            continue;
        if (m_globalVar->m_city[i]->m_own)  continue;       // it's not an enemy city
        cloc = m_globalVar->m_city[i]->m_loc;       // loc of city
        if (!cloc)      continue;                   // city doesn't exist
        assert([m_mapManager chkloc:cloc]);
        
        dtry = [m_mapManager dist:loc location:cloc];                  // distance to city
        if (dtry >= min)    continue;                       // not minimum
        if (![m_mapManager edger:cloc])    continue;               // if not a port city
        if (![self Patsea:loc to:cloc])                      // if not a path by sea
        {
            u->m_ifo = IFOcitytar;
            u->m_ila = cloc;
            min = dtry;                         // set new minimum
        }
    }

    return min != 10000;                    // true if we found sone
}

//Search for a TT to escort. If one is found, set info and ila accordingly and return
-(BOOL)Shiptt:(Unit*)u
{
    loc_t loc,uloc;
    uint end,i;
    Player *p = self;
    
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    i = end = [m_empire Random:m_globalVar->m_unitop];
    do {
        if (m_globalVar->m_unit[i]->m_typ == T &&               // looking for troop transports
            (uloc = m_globalVar->m_unit[i]->m_loc) != 0 &&      // it exists
            m_globalVar->m_unit[i]->m_own == p->m_num &&        // we own it
            [self Patsea:loc to:uloc])                          // path by sea
        {
            u->m_ifo = IFOescort;
            u->m_ila = i;               // ila = TT number
            return true;                // found one
        }
        i++;
        if (i > m_globalVar->m_unitop) i = 0;
    } while (i != end);
    return false;
}

//For ships, look thru troopt[] for the closest one to attack.
//If one is found, set ifo, ila and return true.
-(BOOL)Shiptr:(Unit*)u
{
    uint loc,tloc,min,dt,i,j,mask;
	Player *p = self;
	static uint nshprf[6] =		// which rows to look at
	{   mD|mT|mS,			// D: DT S...
     mT,				// T: .T ....
     mD|mT|mS,			// S: DT S...
     mD|mT|mS|mR|mC,		// R: DT SRC.
     mD|mT|mS|mC,		// C: DT S.C.
     mD|mT|mS|mR|mC|mB		// B: DT SRCB
    };
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    min = 10000;                        // # larger than max distance
    mask = nshprf[u->m_typ - 2];        // select mask from nshprf
    for (i = D; i <= B; i++)            // // loop thru 6 rows
    {
        if (!(mask & m_globalVar->m_msk[i]))            // if bit is not set in nshprf[]
            continue;
        for (j = 5; j--;)                               // loop thru columns
        {
            tloc = p->m_troopt[i - 2][j];               // location of enemy ship
            if (!tloc)      continue;
            assert([m_mapManager chkloc:tloc]);
            dt = [m_mapManager dist:loc location:tloc];        // distance to ship
            if(dt < min &&                  // select closest one
               [self Patsea:loc to:tloc])   // that we can get to
            {
                min = dt;           // new minimum
                u->m_ifo = IFOtar;
                u->m_ila = tloc;
            }
        }
    }
    return min != 10000;
}

//If ship is a T with ifo = IFOloadarmy (loading armies), and there is an army in LTR,
//stay put so the army can get aboard.
//Return false if *pr2 preserved or true if *pr2 = -1.
-(BOOL)Lodarm:(Unit*)u direction:(int*)pr2
{
    uint loc, uloc, ab, i;
    Player* p = self;
    if (u->m_ifo != IFOloadarmy) return false;  // only Ts can have this
    loc = u->m_loc;
    assert([m_mapManager chkloc:loc]);
    if (m_globalVar->m_typ[m_globalVar->m_map[loc]] == X)   return false;   // if in city, don't stay put
    for (i = 8; i--;)                   // loop thru 8 directions
    {
        uloc = loc + [m_globalVar arrow:i];         // location
        ab = m_globalVar->m_map[uloc];              // what's there
        if (m_globalVar->m_typ[ab] == A &&          // if an army and
            m_globalVar->m_own[ab] == p->m_num &&   // own it and
            [m_move fnduni:uloc]->m_ifo == IFOgotoT)// if army is trying to board
        {
            *pr2 = -1;                  // stay out
            return true;                // found one
        }
    }
    return false;
}

//Watch computer strategy.
-(void)Cwatch
{
    Display* d = m_display;
    
    if (!m_watch)
        return;
    
    if (!m_curloc)
    {
        // Use first owned city
        for (int i = 0; 1; i++)
        {
            if (i == CITMAX)
                return;
            if (m_globalVar->m_city[i]->m_own == m_num)
            {
                m_curloc = m_globalVar->m_city[i]->m_loc;
                break;
            }
        }
    }
    
    while (1) {
        int cmd;
        dir_t r2;
        Unit* u;
        City* c;
        
        u = nil;
        if (m_globalVar->m_typ[m_globalVar->m_map[m_curloc]] >= 0)
        {
            u = [m_move fnduni:m_curloc];
            if (u->m_own != m_num)
                u = nil;
        }
        
        c = nil;
        
        if(m_globalVar->m_typ[m_globalVar->m_map[m_curloc]] == X)
        {
            c = [m_sub fndcit:m_curloc];
            if (c->m_own == m_num)
                c = nil;
        }
        
//        if (![d insect:m_curloc location:2])
//            [self Center:m_curloc];
        if (u)
            [d headng:u];
        else if (c)
            [m_display typcit:self city:c];
        [d pcur:m_curloc];
//        cmd = t.TTin();
        switch (cmd) {
            case 3:
            case ESC:
                return;
            case ' ':
            {
                if (!c && u)
                {
                    [self Mmove:u];
                    if (u->m_loc)
                    {
                        m_curloc = u->m_loc;
                    }
                }
                break;
            }
            default:
            {
                if ([self Cmdcur:&m_curloc command:cmd direction:&r2])
                    break;
//                t.bell();
                break;
            }
        }
    }
}

//Update numown, numtar, numphs for computer strategy.
-(void)Cityct
{
    int i;
    Player* p = self;
    for (i = TYPMAX; i--;)          // clear arrays
        p->m_numuni[i] = p->m_numphs[i] = 0;
    p->m_numown = p->m_numtar = 0;
    
    for (i = m_globalVar->m_unitop; i--;)           // loop thru units
    {
        Unit* u = m_globalVar->m_unit[i];
        if (!u->m_loc)      continue;               // unit doesn't exist
        if (u->m_own != p->m_num)
            continue;                               // it isn't ours
        p->m_numuni[u->m_typ]++;
    }
    
    for (i = CITMAX; i--;)                          // loop thru cities
    {
        if (p->m_target[i])         // if city is a target
            p->m_numtar++;              // number of owned
            
         if (m_globalVar->m_city[i]->m_own == p->m_num)
         {
             p->m_numown++;
             if (!(m_globalVar->m_city[i]->m_phs & ~7))               // if valid phase
                 p->m_numphs[m_globalVar->m_city[i]->m_phs]++;       // # of cities w each phase
         }
    }
}

//Select initial phase for computer.
-(void)CPhasin:(City*)c
{
    c->m_phs = F;               // produce fighters
    c->m_fnd = m_globalVar->m_typx[F]->m_phstart;           // set completion date
}

//Select city phase for enemy.
-(void)Cityph
{
    City* c;
    int iniphs;             // initial city phase
    int crowd;              // true if unit is crowed
    int i;                  // city number
    loc_t loc;
    int edge;               // # of seas around city
    
    Player* p = self;       
    
    [p Cityct];                 // bring city vars up to date
    for (i = CITMAX; i--;)          // loop thru cities
    {
        c = m_globalVar->m_city[i];
        if (p->m_num != c->m_own)
            continue;                   // it's not ours
        loc = c->m_loc;
        edge = [m_mapManager edger:loc];       // # of seas around city
        iniphs = c->m_phs;          // remember initial phase
        crowd = [m_move Ecrowd:loc];            // evaluate crowding conditions
        
        if (iniphs & ~7)                // if illegal phase
            goto nophs;
        
        if (c->m_fnd != p->m_round + m_globalVar->m_typx[iniphs]->m_prodtime - 1)
            continue;                   // if not just produced something
        
        // Evaluate phase and select a new one if necessary
        
        if (edge == 8)              // if island city
        {
            [self Island:c];            // evaluate phase for island city
            goto L401;
        }
        
        if (c->m_phs == F)              // if making fighters
        {
            if (p->m_numuni[F] && p->m_numown == 1)
                goto nophs;
        }
        
        if (c->m_phs)   continue;           // if not making armies
        if ([self Nearct:loc] <= 5) continue;   // if not many As nearby
        if (crowd)  goto nophs;                 // the armies are crowded
        if (p->m_numphs[A] <= 1)                // if only 1 city making armies
            continue;
    nophs:
        c->m_phs = A;                           // default to making armies
        if (edge == 8)                          // if island
            [self Island:c];
        else {
            if (![self Ckloci:c] &&             // if no enemy armies nearby
                ![self Makfs:c location:crowd edge:edge]) // if we don't make As or Fs
                [self Selshp:c];                    // select a ship
            if (edge &&         // if not land-locked
                !p->m_numphs[T] &&      // and we're not making Ts
                p->m_numown > 1)        // and we've got more than 1 city
                c->m_phs = T;           // then make Ts
        }
    L401:
        if (c->m_phs == iniphs)             // if phase didn't change
            continue;
        c->m_fnd = p->m_round + m_globalVar->m_typx[c->m_phs]->m_phstart;
        [p Cityct];             // update variables
    }
}

//Count up & return teh number of our armies within 6 spaces of loc
// and on the same continent.
//Input: loc of city
-(int)Nearct:(int)loc
{
    int n, j, uloc;
    n = 0;              // count
    for (j = m_globalVar->m_unitop; j--;)               // loop thru units
    {
        if (m_globalVar->m_unit[j]->m_typ)  continue;   // if not an army
        if (m_globalVar->m_unit[j]->m_own != m_num) continue;   // we don't own it
        if ((uloc = m_globalVar->m_unit[j]->m_loc) == 0) continue;      // unit doesn't exist
        if ([m_mapManager dist:loc location:uloc] > 6) continue;           // too far away
        if (m_globalVar->m_typ[m_globalVar->m_map[uloc]] == T) continue;        // if A is on a T
        if([self Patlnd:uloc to:loc])           // if on same continent
            n++;                        // count
    }
    return n;
}

//Evaluate city phase for an island city.
//Input: i = city number
-(void)Island:(City*)c
{
    Player* p = self;
    if (p->m_numown > 1)                // if own more than 1 city
    {
        if (!c->m_phs)              // if making armies
            [self Selshp:c];        // select a ship
    }
    else if (!p->m_numuni[T])           // if we don't have any Ts
        c->m_phs = T;                   // then make some
    else 
        c->m_phs = A;                   // make armies
}

//Select a ship to be produced, giving priority to 2 T and 1 C
//PRoducing cities.
-(void)Selshp:(City*)c
{
    Player* p = self;
    int j;
    c->m_phs = B;               // try battleships
    j = B - 1;
    while (j >= D) {
        if (p->m_numphs[j] <= p->m_numphs[j + 1])
            c->m_phs = j;           // priority to cheaper ships
        j--;
    }
    if (!p->m_numphs[C])        // if nobody making Cs
        c->m_phs = C;
    if (p->m_numphs[T] < 2)         // if not 2 making Ts
        c->m_phs = T;
}

//If any enemy armies on the continent, make As and return true
-(BOOL)Ckloci:(City*)c
{
    Player* p = self;
    int j;
    uint *p1;
    p1 = p->m_loci;              // p1. start of loci array
    for (j = LOCMAX; j--; p1++)
    {
        if (!*p1)   continue;       // no loci
        if ([self Patlnd:c->m_loc to:*p1])      // if on same continent
        {
            c->m_phs = A;                       // make armies
            return true;
        }
    }
    return false;
}

//Determine whether As or Fs should be made. If so.
//Set citphs[] and return true.
-(BOOL)Makfs:(City*)c location:(int)crowd edge:(int)edg
{
    Player* p = self;
    if (!edg)               // if land-locked city
    {
        if (p->m_numuni[A] <= 3 * p->m_numuni[F] && !crowd)
            c->m_phs = A;
        else {
            c->m_phs = F;
        }
        return true;
    }
    if ([self Nearct:c->m_loc] <= 2 && !crowd)          // if few armies nearby
    {
        c->m_phs = A;
        return true;
    }
    c->m_phs = F;
    return p->m_numuni[F] < p->m_numown / 2;
}

//Update computer strategy variables.
-(void)Updcmp:(int)loc
{
    ushort ab;
    Player* p = self;
    ab = m_globalVar->m_map[loc];               // get map value
    if (m_globalVar->m_own[ab] == p->m_num)
        return;                             // return if we own it
    
    if (m_globalVar->m_typ[ab] == X)            // if unowned or enemy city
    {
        //hb change
        City * city = [m_sub fndcit:loc];
        if( city )
        {
            p->m_target[city->m_num] = 1;     // indicated target
            return;
        }
    }
    
    if (m_globalVar->m_own[ab]) return;             // if not enemy unit
    if (m_globalVar->m_typ[ab] == A)                // if enemy army
    {
        [self Threat:loc];                          // check for threatened cities
        [self Updloc:loc];                          // update LOCI array
        return;
    }
    
    if (m_globalVar->m_typ[ab] >= D)        // if enemy ship
        [self Updtro:loc type:m_globalVar->m_typ[ab]];      // update trropt array
}

//If any cities on the same continent as loc are threatened
-(void)Threat:(int)loc
{
    int i;
    Player* p = self;
    for (i = CITMAX; i--;)
    {
        if (m_globalVar->m_city[i]->m_own == p->m_num &&    // if we own the city
            m_globalVar->m_city[i]->m_phs != A &&           // if not already producing As
            m_globalVar->m_city[i]->m_phs != -1 &&          // if not unsassigned
            m_globalVar->m_city[i]->m_loc &&                // if city exists
            m_globalVar->m_city[i]->m_fnd >= p->m_round + m_globalVar->m_typx[m_globalVar->m_city[i]->m_phs]->m_prodtime - 5 &&    
            [p Patlnd:m_globalVar->m_city[i]->m_loc to:loc])            // route to enemy army
        {
            m_globalVar->m_city[i]->m_phs = -1;             // select new phase
        }
    }
}

//Update loci array with enemy army discovered at loc.
-(void)Updloc:(int)loc
{
    uint i;
    uint * p1;
    Player* p = self;
    p1 = &p->m_loci[0];
    for (i = LOCMAX; i--;)
    {
        if (p1[i] == loc)
            return;
    }
    
    for (i = LOCMAX; i--;)
    {
        if (!p1[i])                     // if slot available
        {
            p1[i] = loc;
            return;
        }
    }
    
    for (i = LOCMAX - 1; i--;)
    {
        p1[i + 1] = p1[i];  // ripple down data
    }
    
    p1[0] = loc;
}

//Update troopt array with the loc of the enemy
//Ship that was discovered.
//Input: location of enemy ship, ty = type of enemy ship
-(void)Updtro:(int)loc type:(uint)ty
{
    uint * p1;
    uint i;
    Player* p = self;
    p1 = p->m_troopt[ty - D];               // point to row
    for (i = 5; i--; ) {
        if( p1[i] == loc ) return;
    }
    for ( i = 5; i--;)
    {
        if (!p1[i])             // if slot available
        {
            p1[i] = loc;
            return;
        }
    }
    
    for (i = 5 - 1; i--;)
        p1[i + 1] = p1[i];              // ripple down data
    p1[0] = loc;                        // insert new data
}

-(BOOL)Patblk:(loc_t)beg to:(loc_t)end
{
    int dummy;
    return [self Pathn:beg to:end direction:1 state:okblk sndDirection:&dummy];
}

-(BOOL)Patcnt:(loc_t)beg to:(loc_t)end
{
    int dummy;
    return [self Pathn:beg to:end direction:1 state:okcnt sndDirection:&dummy];
}

-(BOOL)Patlnd:(loc_t)beg to:(loc_t)end
{
    int dummy;
    return [self Pathn:beg to:end direction:1 state:oklnd sndDirection:&dummy];
}

-(BOOL)Patsea:(loc_t)beg to:(loc_t)end
{
    int dummy;
    return [self Pathn:beg to:end direction:1 state:oksea sndDirection:&dummy];
}

-(BOOL)Patho:(loc_t)beg to:(loc_t)end direction:(int)dir state:(Byte*)ok sndDirection:(dir_t*)pr2
{
    return [path path:self locationStart:beg locationEnd:end direction:dir mapValueAry:ok initMoveDir:pr2 optimize:true];
}

-(BOOL)Pathn:(loc_t)beg to:(loc_t)end direction:(int)dir state:(Byte*)ok sndDirection:(dir_t*)pr2
{
    return [path path:self locationStart:beg locationEnd:end direction:dir mapValueAry:ok initMoveDir:pr2 optimize:false];
}
//Notify playe rthat things have happened
-(void)Notify_destory:(Unit*)u
{
    
}

//Notify current player that player p is now on round r.
-(void)Notify_round:(Player*)p round:(int)r
{
    int i;
    int co40;
    NSString* s = nil;
    text* t = m_display->m_text;
    if (!m_watch)
        return;
    if (t->m_narrow == 2)
        return;
    
    co40 = t->m_narrow;
    
    i = p->m_num;
    if (i >= 6)
        return;
    
    if (p->m_defeat)
        s = @"lost";
    else {
        s = [NSString stringWithFormat:@"%d", r];
    }
    
    if (r <= 1 || co40 )
    {
        if (co40)
            [t curs:(0x400 + i * 10) ];
        else {
            [t curs:((i-1)<< 8) ];
        }
        
        if( p == self )
        {
            if( co40 )
            {
                [t vsmes:[NSString stringWithFormat:@"Yr: %@", s]];
            }
            else
            {
                [t vsmes:[NSString stringWithFormat:@"Your  : %@",s]];
            }
	    }
	    else
	    {  
            if (co40)
                [t vsmes:[NSString stringWithFormat:@"P%d: %@",i,s]];
            else
                [t vsmes:[NSString stringWithFormat:@"Plyr %d: %@",i,s]];
	    }
        
    }
    else {
        
        [ t curs:(((i-1) << 8) + 8) ];
        [t vsmes:s];
    }
}

//Notify that p has been defeated. p might be you.
-(void)Notify_defeated:(Player*)p
{
    if( p == self )
        [m_display lost];
    else {
        [m_display plyrcrushed:p];
    }
}

//Your city has been captured by the enemy.
//Update strategy variables.
-(void)Notify_city_lost:(City*)c
{
    int nIdx = 0;
    for (int i = 0; i < CITMAX; i++ ) {
        City * city = m_globalVar->m_city[i];
        if( city->m_loc == c->m_loc )
        {
            nIdx = i;
            break;
        }
    }
    if(m_playerType == Computer)
        m_target[nIdx] = 1;
}

//You have conquered a new city.
//Update strategy variables.
-(void)Notify_city_won:(City*)c
{
    switch (m_playerType) {
        case Human:
        {
            [m_display delay:1];
            [self Sensor:c->m_loc];
            c->m_fipath = 0;
            [self Phasin:c];
            m_glbMembers->m_nSelectedCityIdx = c->m_num;
            
            if ( self->m_num == m_glbMembers->m_playerNum) {
                [(GameView*)m_glbMembers->m_GameView showSelectDlg];
            }
            break;
        }   
        case NetUser:
        case Computer:
        {
            c->m_round = 50;
            int nIdx = 0;
            for (int i = 0; i < m_globalVar->m_unitop; i++ ) {
                City * city = m_globalVar->m_city[i];
                if( city->m_loc == c->m_loc )
                {
                    nIdx = i;
                    break;
                }
            }
            m_target[nIdx] = 0; 
            break;
        }
        default:
            break;
    }
}

//We've been attacked, but repelled the invasion.
-(void)Notify_city_repelled:(City*)c
{
    if(m_playerType == Computer)
        c->m_round = 50;
}

//-----------------------------------------------Private-------------------------------------------//
//For Ts and Cs, drag along any As and Fs that are aboard, and destory
-(void)Drag:(Unit*)u
{
    int type = u->m_typ;            // T or C
    int typabd = F,                // assume F (type == C)
    numabd = 0,                     // number aboard
    numdes = 0,                     // number destroyed
    nummax = u->m_hit;               // max # allowed
    
    int i;
    Player* p = self;
    Display* d = p->m_display;
    if (type == T)              // if troop transport
    {
        typabd = A;             // looking for armies
        nummax *= 2;            // allow 6 on board
    }
    
    for ( i = m_globalVar->m_unitop; i--;)  // loop thru all units
    {
        Unit* ua = m_globalVar->m_unit[i];
        if (ua->m_loc != st_locold ||               // if not on old location
            ua->m_typ != typabd)            // wrong type
            continue;
        numabd++;                   // it's an A or F aboard
        ua->m_loc = u->m_loc;       // drag unit to new location
        if (numabd > nummax)                // too many aboard
        {
            [p Notify_destory:ua]; 
            [ua destroy];               // destroy the unit
            numdes++;                   // remember how many trashed
        }
    }
    
    if (numdes)                 // if we trashed anything
        [d overloaded:u->m_loc type:typabd number:numdes];
}

// end of move processing
-(void)Eomove:(int)loc
{
    assert(loc < MAPSIZE);
    
    [self Sensor:loc];                                  // do sensor probe for new loc
    if (st_snsflg)                                      // if do sensor for enemy
        [[Player Get:st_snsflg] Sensor:loc];            // do sensor for enemy
    if (m_watch && (m_playerType == Computer))
        [m_display pcur:loc];                          
}

//Input: type = unit type, loc = location ac = sea or land
//Output: change ref map to correct map value
-(void)Change:(uint)type location:(loc_t)loc areaOrland:(uint)ac
{
    assert(loc < MAPSIZE && (ac == MAPsea || ac == MAPland) && type <= B);
    type += 5 + 10 * (m_num - 1);                   // offset to army
    if (ac == MAPsea)                               // if moving onto sea
        type++;                                     // offset for two Fs
    m_globalVar->m_map[loc] = type;                 // update reference map
    [m_glbMembers SendMoveUnt:m_num unitType:type unitLocation:loc mapValue:ac];
}

-(void)Killit:(Unit*)u
{
    [self Eomove:u->m_loc];             // do any sensor probes
    u->m_loc = st_locold;               // put back in old loc
    [m_move kill:u];                    // messages, etc.
    
    //hb
//    [m_glbMembers SendKillUnit:m_num unitNumber:u->m_num];
}

//Perform a battle between attacker and defender.
//Input: attnum = unit # or attacker, loc = loc of defender
//Output: unihit[] = updated for winner, uniloc[] = set to 0 for loser, loc for winner.
-(BOOL)Fight:(Unit*)u location:(int)loc
{
    int Hatt, Satt, Hdef, Sdef;             // hits & strike capability
    int Hwin;
    Unit* udef;                             // defending unit
    Unit *uwin;                             // winning  unit
    Unit* ulos;                             // losing unit
    
    Player* pdef, *pwin, *plos;
    
    Hatt = Satt = Hdef = Sdef = 1;                  // all to 1 initially
    
    if (u->m_typ >= D)                      // if ship
        Hatt = u->m_hit;                    // set hits of attacker
    if (u->m_typ == S)                      // if submarine
        Satt = 3;                           // for torpedos
    
    u->m_loc = ~0u;                         // so fnduni won't find attacker
    udef = [m_move fnduni:loc];             // get defender
    u->m_loc = loc;                         // restore
    
    if( udef == nil )
        return true;
    
    pdef = [Player Get:udef->m_own];    
    
    if (udef->m_typ >= D)
        Hdef = udef->m_hit;
    if (udef->m_typ == S)
        Sdef = 3;                           // do same for defender
    
    // hit attacker and defender until one is destroyed
    
    while (true) {
        if ([m_empire Ranq] & 1)            // hit attacker
        {
            if ((Hatt -= Sdef) <= 0)        // if attacker is destroyed
            {
                uwin = udef;
                ulos = u;
                Hwin = Hdef;
                
                pwin = pdef;
                plos = self;
                break;
            }
        }
        else {                              // hit defender
            if ((Hdef -= Satt) <= 0)        // if defender is destroyed
            {
                // attacker wins
                uwin = u;
                ulos = udef;
                Hwin = Hatt;
                
                pwin = self;
                plos = pdef;
                break;
            }
        }
    }
    
    if (uwin->m_typ >= D)
        uwin->m_hit = Hwin;
    
    [pdef->m_display underattack:udef];
    
    if (![pwin isEqual:plos])
        [pwin->m_display battle:pwin winner:uwin loser:ulos];
    [plos->m_display battle:plos winner:uwin loser:ulos];
    
    if([ulos isEqual:udef])
        [m_move kill:ulos];                 // kill the loser's unit
    return ![uwin isEqual:u];               // true if attacker loses
}

//Given a location and a command, find out if the command is a direction command.
//If it is, try to move the cursor in that direction.
//If that fails, change sectors so you can.
//If that fails, return with location and cursor unchanged.
//Input: ploc = location of cursor and so on
//Return true if valid direction command
-(BOOL)Cmdcur:(int*)ploc command:(uint)cmd direction:(int*)pr2
{
    loc_t newloc;
    int i;
    
    switch (cmd) {
        case LeftTop:
        case Top:
        case RightTop:
        case Left:
        case Right:
        case LeftBottom:
        case RightBottom:
        case Bottom:
            break;         
        default:
            return false;

    }
    i = cmd;
    newloc = *ploc + [m_globalVar arrow:i]; // try new location
    if (m_globalVar->m_mapgen)              // if in map editor
    {
        if(newloc < 0 || newloc >= MAPSIZE)
            return false;
        if ([m_mapManager border:*ploc] && [m_mapManager border:newloc] && [empire COL:*ploc] != [empire COL:newloc])
            return false;
    }
    else {                                                  // else in game
//        assert(newloc < MAPSIZE);
        if([m_mapManager border:newloc])   return false;           // can't move on border
    }
    *pr2 = i;
    *ploc = newloc;                 // set return parameters
//    if (![d insect:newloc location:2])              // if not in current sector
//        [p Sector:[d adjust:(d->m_secbas + [m_globalVar arrow:i])]];                // print new sector
    return true;
}

//Find next coputer player.
-(Player*)nextp
{
    int i;
    for ( i = m_num + 1; 1; i++)
    {
        if ( i > m_globalVar->m_numply)
            i = 1;
        break;
    }
    return [Player Get:i];
}

//Exchange display with that of another player
-(void)Exchange_display:(Player*)p
{
    Display* d;
    int w;
    if (![self isEqual:p])
    {
        d = m_display;
        m_display = p->m_display;
        p->m_display = d;
        
        w = m_watch;
        m_watch = p->m_watch;
        p->m_watch = w;
        
        w = m_secflg;
        m_secflg = p->m_secflg;
        p->m_secflg = w;
        
        [self Repaint];
        [p Repaint];
    }
}

- (void) EnterNewCity
{
    Player * p = self;
    
    if( p->m_mode != mdSURV )
        goto err;
    if( ![p Cittst] )
        goto err;
    [p SetMode:mdPHAS];
    City * c = [ m_sub fndcit:p->m_curloc]; 
    [p Phasin: c ];
    
    m_glbMembers->m_nSelectedCityIdx = c->m_num;
    [(GameView*)m_glbMembers->m_GameView showSelectDlg];
    
    [p SetMode:mdSURV];
    return;
    
err:
    [self CmdError];
}

//REpaint display
-(void)Repaint
{
    if (m_watch)
    {
        Display* d = m_display;
        d->m_secbas = -1;
       [d->m_text clear];
        if (m_defeat || m_globalVar->m_numleft == 1)
            [self Sector:0];
    }
}
@end
