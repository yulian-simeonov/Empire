//
//  Unit.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Unit.h"

@implementation Unit
loc_t m_loc;                // location
unsigned char m_own;		// owner
unsigned char m_typ;		// type A..B
unsigned char m_ifo;		// IFOxxxx ifo of unit function
unsigned int m_ila;         // ila of unit function
unsigned char m_hit;		// hits left, fuel left for fighter
unsigned char m_mov;		// !=0 if unit has moved this turn
int           m_num;        // unit number

// Human strategy

// Computer strategy
unsigned int m_abd;		// T,C: number of As (Fs) aboard (0 if not T (C))
int m_dir;		// direction (1 or -1)
int m_fuel;		// F:range used for strategy selection
-(void) destroy	// destroy the unit
{ 
    m_loc = 0; 
    m_own = 0; 
    m_typ = 0;
    m_ifo = 0;
    m_ila = 0;
    m_hit = 0;
    m_mov = 0;
    m_abd = 0;
    m_dir = 0;
    m_fuel = 0;
}

-(void)Save:(FILE*)fp
{
    fwrite(&m_loc, sizeof(loc_t), 1, fp);
    fwrite(&m_own, sizeof(unsigned char), 1, fp);
    fwrite(&m_typ, sizeof(unsigned char), 1, fp);
    fwrite(&m_ifo, sizeof(unsigned char), 1, fp);
    fwrite(&m_ila, sizeof(unsigned int), 1, fp);
    fwrite(&m_hit, sizeof(unsigned char), 1, fp);
    fwrite(&m_mov, sizeof(unsigned char), 1, fp);
    fwrite(&m_num, sizeof(int), 1, fp);
    fwrite(&m_abd, sizeof(unsigned int), 1, fp);
    fwrite(&m_dir, sizeof(int), 1, fp);
    fwrite(&m_fuel, sizeof(int), 1, fp);
}

-(void)Load:(FILE*)fp
{
    fread(&m_loc, sizeof(loc_t), 1, fp);
    fread(&m_own, sizeof(unsigned char), 1, fp);
    fread(&m_typ, sizeof(unsigned char), 1, fp);
    fread(&m_ifo, sizeof(unsigned char), 1, fp);
    fread(&m_ila, sizeof(unsigned int), 1, fp);
    fread(&m_hit, sizeof(unsigned char), 1, fp);
    fread(&m_mov, sizeof(unsigned char), 1, fp);
    fread(&m_num, sizeof(int), 1, fp);
    fread(&m_abd, sizeof(unsigned int), 1, fp);
    fread(&m_dir, sizeof(int), 1, fp);
    fread(&m_fuel, sizeof(int), 1, fp);
}
@end
