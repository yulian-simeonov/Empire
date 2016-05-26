//
//  var.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "var.h"
#import "Player.h"
#import "empire.h"
#import "Global.h"
#import "AppDelegate.h"

@implementation var

- (id) init
{
    if (self = [super init])
    {
        
        m_noflush = 0;
        
        m_typx[0] = [Type alloc];
        m_typx[0]->m_prodtime = 5;
        m_typx[0]->m_phstart = 6;
        m_typx[0]->m_hittab = 0;
        m_typx[0]->m_unichr = 'A';
        
        m_typx[1] = [Type alloc];
        m_typx[1]->m_prodtime = 10;
        m_typx[1]->m_phstart = 12;
        m_typx[1]->m_hittab = 20;
        m_typx[1]->m_unichr = 'F';
        
        m_typx[2] = [Type alloc];
        m_typx[2]->m_prodtime = 20;
        m_typx[2]->m_phstart = 24;
        m_typx[2]->m_hittab = 3;
        m_typx[2]->m_unichr = 'D';
        
        m_typx[3] = [Type alloc];
        m_typx[3]->m_prodtime = 30;
        m_typx[3]->m_phstart = 36;
        m_typx[3]->m_hittab = 3;
        m_typx[3]->m_unichr = 'T';
        
        m_typx[4] = [Type alloc];
        m_typx[4]->m_prodtime = 25;
        m_typx[4]->m_phstart = 30;
        m_typx[4]->m_hittab = 2;
        m_typx[4]->m_unichr = 'S';
        
        m_typx[5] = [Type alloc];
        m_typx[5]->m_prodtime = 50;
        m_typx[5]->m_phstart = 60;
        m_typx[5]->m_hittab = 8;
        m_typx[5]->m_unichr = 'R';
        
        m_typx[6] = [Type alloc];
        m_typx[6]->m_prodtime = 60;
        m_typx[6]->m_phstart = 72;
        m_typx[6]->m_hittab = 8;
        m_typx[6]->m_unichr = 'C';
        
        m_typx[7] = [Type alloc];
        m_typx[7]->m_prodtime = 75;
        m_typx[7]->m_phstart = 90;
        m_typx[7]->m_hittab = 12;
        m_typx[7]->m_unichr = 'B';
        
        
        m_mapgen = false;		/* true if we're running MAPGEN.EXE	*/
        m_savegame = false;		/* set to true if we're to save the game */

        m_overpop = false;		/* true means unit arrays are full	*/
        m_cittop = 0;
        m_unitop = 0;		
        
        m_numply = 0;		/* default number of players playing	*/
        m_plynum = 0;		/* which player is playing, 1..numply	*/
        m_concede = false;	/* set to true if computer concedes game */
        m_numleft = 0;		/* number of players left in the game	*/
        
        // These are fleshed out in init_var()
        //		     ,*,.,+,O,A,F,F,D,T,S,R,C,B
        memset(m_own, 0, sizeof(int)*MAPMAX);
        memset(m_typ, 0, sizeof(int)*MAPMAX);
        memset(m_sea, 0, sizeof(int)*MAPMAX);
        memset(m_land, 0, sizeof(int)*MAPMAX);
        int tmp[MAPMAX] = { 0,0,0,0,1,1,1,1,1,1,1,1,1,1,
            2,2,2,2,2,2,2,2,2,2,
            3,3,3,3,3,3,3,3,3,3,
            4,4,4,4,4,4,4,4,4,4,
            5,5,5,5,5,5,5,5,5,5,
            6,6,6,6,6,6,6,6,6,6};
        
        for (int i = 0; i < MAPMAX; i++)
            m_own[i] = tmp[i];
        
        int tmp1[MAPMAX] = {J,X,J,J,X,A,F,F,D,T,S,R,C,B,
            X,A,F,F,D,T,S,R,C,B,
            X,A,F,F,D,T,S,R,C,B,
            X,A,F,F,D,T,S,R,C,B,
            X,A,F,F,D,T,S,R,C,B,   
            X,A,F,F,D,T,S,R,C,B};
        
        for (int i = 0; i < MAPMAX; i++)
            m_typ[i] = tmp1[i];
        
        int tmp2[MAPMAX] = {0,0,1,0,0,0,0,1,1,1,1,1,1,1,
            0,0,0,1,1,1,1,1,1,1,
            0,0,0,1,1,1,1,1,1,1,
            0,0,0,1,1,1,1,1,1,1,
            0,0,0,1,1,1,1,1,1,1,
            0,0,0,1,1,1,1,1,1,1};
        
        for (int i = 0; i < MAPMAX; i++)
            m_sea[i] = tmp2[i];
        
        int tmp3[MAPMAX] = {0,0,0,1,0,1,1,0,0,0,0,0,0,0,
            0,1,1,0,0,0,0,0,0,0,
            0,1,1,0,0,0,0,0,0,0,
            0,1,1,0,0,0,0,0,0,0,
            0,1,1,0,0,0,0,0,0,0,
            0,1,1,0,0,0,0,0,0,0};
        
        for (int i = 0; i < MAPMAX; i++)
            m_land[i] = tmp3[i];
        
        /* Mask table. Index is type (A..B).	*/
        int tmp4[8] = { mA,mF,mD,mT,mS,mR,mC,mB };
        for ( int i = 0; i <  8; i++)
            m_msk[i] = tmp4[i];
        
    }
    
    return self;
}

-(void)dealloc
{
    for(int i = 0; i < TYPMAX; i++)
        [m_typx[i] release];
    for (int i = 0; i < UNIMAX; i++)
        [m_unit[i] release];
    for (int i = 0; i < CITMAX; i++)
        [m_city[i] release];
    [super dealloc];
}

/* direction table, index is -1..7
 *
 *	qwe	3  2  1
 *	a d	4 -1  0
 *	zxc	5  6  7
 */
//Right,RightBottom, , Bottom, LeftBottom, Left, LeftTop,Top, RightTop 

-(int) arrow:(dir_t) dir
{
    static int arrow[9] =
    {0,1,-Mcolmx,-Mcolmx-1,-Mcolmx-2,-1,Mcolmx,Mcolmx+1,Mcolmx+2};

    return arrow[dir + 1];
}

/*************************************
 * Initialize variables.
 */

-(void) init_var
{
    int i,j;
//    for (i = 0; i < PLYMAX; i++)
//    {
//        if (i && plyr[i]->m_map)
//        {
//            [plyr[i]->m_map release];
//        }
//        
//        if (plyr[i]->m_display)
//        {
//            [plyr[i]->m_display release];
//        }
//    }
    
    for (i = 0; i < CITMAX; i++)
    {
        m_city[i] = [[City alloc] init];
        m_city[i]->m_num = i;
    }
    
    for (i = 0; i < UNIMAX; i++)
    {
        m_unit[i] = [[Unit alloc] init];
        m_unit[i]->m_num = i;
    }
    
    for (i = 0; i <= PLYMAX; i++)
        m_player[i] = [[Player alloc] init];
    
    for (i = 1; i <= PLYMAX; i++)
    {
        for (j = 0; j < 10; j++)
        {   // Fill in the etc. parts
            
            m_own [4 + (i - 1) * 10 + j] = i;
            m_typ [4 + (i - 1) * 10 + j] = m_typ [4 + j];
            m_sea [4 + (i - 1) * 10 + j] = m_sea [4 + j];
            m_land[4 + (i - 1) * 10 + j] = m_land[4 + j];
        }
    }
}

// hb mark

/*********************************
 * Save the game in filename.
 * Returns: 
 *	0	success
 *	!=0	error
 */

-(int)var_savgam:(NSString*)fileName
{
    FILE *fp = NULL;
    Player* p = nil;
    size_t n;
    int i;
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    Global* gbl = delegate->m_globalMembers;
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
	NSString *filePath = [[documentsDirectoryPath stringByAppendingPathComponent:fileName] retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}

    const char* filename = [filePath UTF8String];
    fp = fopen(filename,"wb");
    if (fp == NULL) goto err;

    fwrite(&m_unitop, sizeof(int), 1, fp);
    fwrite(&m_numply, sizeof(int), 1, fp);
    fwrite(&m_plynum, sizeof(int), 1, fp);
    fwrite(&m_numleft, sizeof(int), 1, fp);
    fwrite(&gbl->m_nSelectedCityIdx, sizeof(int), 1, fp);

    for (int i = 0; i < CITMAX; i++)
    {
        [m_city[i] Save:fp];
    }

    for (int i = 0; i < UNIMAX; i++)
    {
        [m_unit[i] Save:fp];
    }

    for (int i = 0; i <= PLYMAX; i++)
    {
        p = (Player*)m_player[i];
        [p Save:fp];
    }

    fwrite(m_map, sizeof(unsigned char), MAPSIZE, fp);
    fwrite(gbl->m_visibleMap, sizeof(BOOL), MAPSIZE, fp);
    fwrite(gbl->m_tempMapData, sizeof(unsigned char), MAPSIZE, fp);
    
    p = (Player*)m_player[0];
    p->m_map = m_map;
    for (i = 1; i <= m_numply; i++)
    {
        n = MAPSIZE;
        p = m_player[i];
        if (fwrite(p->m_map, sizeof(unsigned char), n, fp) != n)
            goto err2;
    }
    if (fclose(fp) == -1) goto err;
    return 0;
    
err2:
    fclose(fp);
err:
    return 1;
}


///******************************
// * Restore game from fp.
// * Returns: 
// *	0	success
// *	!=0	error
// */
//
-(int)resgam:(FILE*)fp
{
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    Global* gbl = delegate->m_globalMembers;
    size_t n;
    Player* p = nil;
    int i;
    if (fp == nil)
        return 1;
//    fpos_t fpPos;
//    fgetpos(fp, &fpPos);
//    NSLog(@"FP:%d", fpPos);
    fread(&m_unitop, sizeof(int), 1, fp);
    fread(&m_numply, sizeof(int), 1, fp);
    fread(&m_plynum, sizeof(int), 1, fp);
    fread(&m_numleft, sizeof(int), 1, fp);
    fread(&gbl->m_nSelectedCityIdx, sizeof(int), 1, fp);
    
    for (int i = 0; i < CITMAX; i++)
    {
        [m_city[i] Load:fp];
    }

    for (int i = 0; i < UNIMAX; i++)
    {
        [m_unit[i] Load:fp];
    }

    for (int i = 0; i <= PLYMAX; i++)
    {
        p = (Player*)m_player[i];
        [p Load:fp];
    }

    m_map = (unsigned char*)malloc(MAPSIZE);
    memset(m_map, 0, MAPSIZE);
    fread(m_map, sizeof(unsigned char), MAPSIZE, fp); 
    fread(gbl->m_visibleMap, sizeof(BOOL), MAPSIZE, fp);
    fread(gbl->m_tempMapData, sizeof(unsigned char), MAPSIZE, fp);

    p = (Player*)m_player[0];
    p->m_map = m_map;
    for (i = 1; i <= m_numply; i++)
    {
        n = MAPSIZE;
        ((Player*)m_player[i])->m_map = (unsigned char*)malloc(MAPSIZE);

        if (fread(((Player*)m_player[i])->m_map, sizeof(unsigned char), n, fp) != n)
            goto err2;
        ((Player*)m_player[i])->m_usv = nil;
    }

    if (fclose(fp) == -1) goto err;
    
    return 0;
    
err2:
    fclose(fp);
err:
    return 1;
}

@end
