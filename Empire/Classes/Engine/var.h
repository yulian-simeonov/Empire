//
//  var.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "empire.h"
#import <stdio.h>

#import "var.h"

@interface var : NSObject
{
@public
    /**************************************
     * Variables not saved across game saves.
     */
    
    int m_noflush;		/* if non-zero then don't flush	*/
    
    Type* m_typx[TYPMAX];
    
    BOOL m_mapgen;	/* true if we're running MAPGEN.EXE	*/
    BOOL m_savegame;		/* set to true if we're to save the game */
    
    /*************************************
     * Variables saved across game saves.
     * All variables must be initialized, so they are in the same segment.
     */
    unsigned char *m_map;	// reference map 

    
    BOOL m_overpop;		/* true means unit arrays are full	*/
    int m_cittop;		/* actual number of cities		*/  
    int m_unitop;		/* unitop >= topmost unit number	*/
    
    /*
     * Player variables.
     */
    int	m_numply;	/* default number of players playing	*/
	int m_plynum;		/* which player is playing, 1..numply	*/
	BOOL m_concede;	/* set to true if computer concedes game */
	int m_numleft;		/* number of players left in the game	*/
    
    id m_player[PLYMAX + 1];
    Unit* m_unit[UNIMAX];
    City* m_city[CITMAX];
    
    // These are fleshed out in init_var()
    //		     ,*,.,+,O,A,F,F,D,T,S,R,C,B
    int m_own[MAPMAX];
    int m_typ[MAPMAX]; 
    int m_sea[MAPMAX]; 
    int m_land[MAPMAX]; 
    
    /* Mask table. Index is type (A..B).	*/
    int m_msk[8]; 
}

- (id) init;
-(int) arrow:(dir_t) dir;
-(void) init_var;
-(int)var_savgam:(NSString*)fileName;
-(int)resgam:(FILE*)p;

@end
