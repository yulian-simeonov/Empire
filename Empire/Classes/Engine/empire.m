//
//  empire.m
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "empire.h"

@implementation empire

-(id)init
{
    if (self = [super init])
    {
    
    }
    
    return self;
}

+ (int) ROW: (loc_t) loc
{ 
    return loc / (Mcolmx + 1); 
}

+ (int) COL: (loc_t) loc
{
    return loc % (Mcolmx + 1); 
}

-(void)Setran
{

}

-(uint)Random:(uint)p
{
    return arc4random() % p;
}

-(uint)Ranq
{
    return arc4random();
}
@end
