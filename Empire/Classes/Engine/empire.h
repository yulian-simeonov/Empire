//
//  empire.h
//  Scott'sEmpire
//
//  Created by 陈玉亮 on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
#import "Unit.h"
#import "City.h"
#import "Type.h"

#define  ERRTERM    1
#define  TYPMAX     8	// number of types
#define  UNIMAX     500	// max number of units

#define  PLYMAX     6	// number of players
#define  CITMAX     70	// max number of cities
#define  MAPMAX     64	// number of map elements
#define  LOCMAX     10	// size of loci array
#define  VERSION    1	// version number
#define  NEW        1	// new computer strategy

//debug
//{
#define 	PLYMIN	 1	// minimum number of players
//}
//else
//{
//    const int	PLYMIN	= 2;	// minimum number of players
//}
#define     Mrowmx	 59
#define     Mcolmx	 99
#define     MAPSIZE	 ( ( Mrowmx + 1) * ( Mcolmx + 1) )

enum Letter
{
    J = -1, // nono
    X = -2, // city
    A = 0, // army
    F = 1, // fighter
    D = 2, //destroyer
    T = 3, // transport
    S = 4, //submarin
    R = 5, //Cruiser
    C = 6, //Carrier
    B = 7, //BattleShip
};

enum mLetter
{
    mA = 0x80,
    mF = 0x40,
    mD = 0x20,
    mT = 0x10,
    mS = 0x08,
    mR = 0x04,
    mC = 0x02,
    mB = 0x01,
};

/* Some ascii characters						*/
enum AsciiCharacters
{
    BEL	= 7,
    BS	= 8,
    TAB	= 9,
    LF	= 10,
    FF	= 12,
    CR	= 13,
    ESC	= 27,
    SPC	= 32,
    DEL	= 127,
};


// Which maptab to use
enum MapTabType
{
    MTmono	= 0,	// For the monochrome screen.
    MTcgacolor	= 1,	// For the color/graphics adapter with a color monitor.
    MTcgabw	= 2,	// For the color/graphics adapter with a b/w monitor.
    MTterm	= 3,	// For terminals.
};

/* Some display attributes (for watch[])
 */
enum DisplayAttribute
{
    DAnone	= 0,	// not watching this guy
    DAdisp	= 1,	// use disp package (IBM compatible displays)
    DAmsdos	= 2,	// talk thru MS-DOS
    DAcom1	= 3,	// talk to com1:
    DAcom2	= 4,	// talk to com2:
    DAconsole	= 5,	// Win32 console
    DAwindows	= 6,	// Win32 GUI app
};

/////////////////////////////////
// Map values

enum MapValues
{
    MAPunknown	= 0,	// ' '
    MAPcity	= 1,	// '*'
    MAPsea	= 2,	// '.'
    MAPland	= 3,	// '+'
};
enum IfoFunctions_1
{
    fnAW	= 0,
    fnSE	= 1,
    fnRA	= 2,
    fnMO	= 3,
    fnDI	= 4,
    fnFI	= 5,
};

enum IfoFunctions_2
{
    IFOnone		= 0,	// no function assigned
    IFOgotoT		= 1,	// A: go to troop transport
    IFOdirkam		= 2,	// F: directional, kamikaze
    IFOdir		= 3,	// directional
    IFOtarkam		= 4,	// F: target, kamikaze
    IFOtar		= 5,	// target location
    IFOgotoC		= 6,	// F: goto carrier number
    IFOcity		= 7,	// F,ships: goto city location
    IFOdamaged		= 8,	// ships: damaged and going to port
    IFOstation		= 9,	// C: stationed
    IFOgstation		= 10,	// C: goto station
    IFOcitytar		= 11,	// ships: goto city target
    IFOescort		= 12,	// ships: escort TT number
    IFOshipexplor	= 13,	// ships: look at unexplored territory
    IFOloadarmy		= 14,	// T: load up armies
    IFOacitytar		= 15,	// A: city target
    IFOfolshore		= 16,	// A: follow shore
    IFOonboard		= 17,	// A: on board a T
};

enum unitType
{
    mdNONE	= 0,
    mdMOVE	= 1,
    mdSURV	= 2,
    mdDIR	= 3,
    mdTO	= 4,
    mdPHAS	= 5,
};


@interface empire : NSObject

{
        /* Definitions for typ[MAPMAX] array (X=city, J=not unit or city)
         */
                /* #define DS(x)	((x)*256+18) */
}

/* map row and column limits (0..Mrowmx,0..Mcolmx)			*/
+ (int) ROW: (loc_t) loc;
+ (int) COL: (loc_t) loc;
//hb mark

-(void)Setran;
-(uint)Random:(uint)p;
-(uint)Ranq;

@end
