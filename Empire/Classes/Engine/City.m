//
//  City.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "City.h"

@implementation City

-(void)Save:(FILE*)fp
{
    fwrite(&m_own, sizeof(int), 1, fp);
    fwrite(&m_phs, sizeof(int), 1, fp);
    fwrite(&m_loc, sizeof(loc_t), 1, fp);
    fwrite(&m_fnd, sizeof(int), 1, fp);
    fwrite(&m_num, sizeof(int), 1, fp);
    fwrite(&m_fipath, sizeof(loc_t), 1, fp);
    fwrite(&m_round, sizeof(int), 1, fp);
}

-(void)Load:(FILE*)fp
{
    fread(&m_own, sizeof(int), 1, fp);
    fread(&m_phs, sizeof(int), 1, fp);
    fread(&m_loc, sizeof(loc_t), 1, fp);
    fread(&m_fnd, sizeof(int), 1, fp);
    fread(&m_num, sizeof(int), 1, fp);
    fread(&m_fipath, sizeof(loc_t), 1, fp);
    fread(&m_round, sizeof(int), 1, fp);
}
@end
