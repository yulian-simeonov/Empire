//
//  text.m
//  Empire
//
//  Created by 陈玉亮 on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "text.h"
#import "AppDelegate.h"
#import "OALSimpleAudio.h"


@implementation text

-(id) init
{
    if( self = [super init] )
    {
        VBUFCOLS = 80;
        VBUFROWS = 5;
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        m_glbMember = delegate->m_globalMembers;
        m_watch = true;
        
        [self clear];
    
    }
    
    return self;
}

- (void) deleol		// erase to end of line
{
    if (m_watch)
    {
        int r, c;
        
        r = m_cursor >> 8;
        c = m_cursor & 0xFF;			// get row & column in r,c
        for (; c < VBUFCOLS; c++)
        {  
            if (m_vbuffer[r][c] != ' ')
            {   m_anychanges = 1;
                m_vbuffer[r][c] = ' ';
            }
        }
    }
}


- (void) deleos		// erase to end of screen
{
    if (m_watch)
    {
        int r, c;
        
        r = m_cursor >> 8;
        c = m_cursor & 0xFF;			// get row & column in r,c
        for (; r < VBUFROWS; r++)
        {
            for (; c < VBUFCOLS; c++)
                m_vbuffer[r][c] = ' ';
            c = 0;
        }
        m_anychanges = 1;
    }
}

-(void) block_cursor		// set block cursor
{
}

- (void) clear		// clear screen
{
   if (m_watch)
    {
        int r, c;
        
        for (r = 0; r < VBUFROWS; r++)
        {	for (c = 0; c < VBUFCOLS; c++)
            m_vbuffer[r][c] = ' ';
            m_vbuffer[r][VBUFCOLS] = 0;
        }
        m_anychanges = 1;
    }
}



/*********************************
 * Send char to output device.
 */

-(void) TTout:(char) c
{
    if (m_watch)
    {   int row, col;
        
        row = m_cursor >> 8;
        col = m_cursor & 0xFF;
        if (row < VBUFROWS && col < VBUFCOLS)
        {
            if (m_vbuffer[row][col] != c)
            {   m_anychanges = 1;
                m_vbuffer[row][col] = c;
            }
        }
    }
    
    for (int nRow = 0; nRow < 5; nRow++ ) {
        for (int nCol = 0; nCol < 81; nCol++) {
            m_glbMember->m_vbuffer[nRow][nCol] = m_vbuffer[nRow][nCol];
        }
    }
    
}


/*****************************
 * Get char from device. Wait until one is available.
 */

-(int) TTin
{   int c;
    
    c = [self TTinr];
    return c;
}


/***************************
 * Get char from device and return it. Return -1
 * if no char is available. Convert all chars to uc.
 * Do not echo character.
 */

-(int) TTinr
{
    int c;
    
    if (m_watch == DAnone)
        return -1;
    
    c = m_inbuf;
    m_inbuf = -1;
    
    return c;
}

-(void) TTunget:(int) c		// put character c in input
{
    m_inbuf = c;
}

/**************************************
 * Position cursor at r,c.
 */

-(void) TTcurs:(unsigned int) rc
{
    m_cursor = rc;
}


/******************************
 * Position cursor at r,c. Use cursor[] to minimize chars sent out.
 * Cases considered:
 *	1. Use cursor addressing if we are to move backwards or up.
 *	2. Use cursor addressing if we are to move to 25th line.
 *	3. Use a CRLF if we start a new line.
 *	4. Do nothing if cursor is already there.
 *	5. Else use cursor addressing.
 */

-(void) curs:(int) rc
{
    //PRINTF("Text::curs(%x)\n", rc);
    unsigned int r,c;
    
    if (!m_watch) return;
    
    if (rc == m_cursor) return;		// case 4
    r = rc >> 8;
    c = rc & 0xFF;			// get row & column in r,c
//    if (!(r <= (Tmax >> 8) && c <= (Tmax & 0xFF)))
//        PRINTF("r = %d, c = %d, Tmax = %d,%d\n", r, c, Tmax >> 8, Tmax & 0xFF);
   
    [self TTcurs:(rc)];
}


/*************************************
 * Ring the bell.
 */

-(void) bell
{
    //MessageBeep(0);
}


/**************************
 * Output chars to display. Keep track of cursor
 * position.
 * Cases considered:
 *	1.	CR
 *	2.	LF
 *	3.	0
 *	4.	printable char
 *	5.	BS
 *	6.	1 (do a delete to end of line)
 *	7.	2 (do a delay(2))
 */

-(void) output:(char) chr
{
    int r,c;
    
    if (!m_watch) return;
    r = m_cursor >> 8;
    c = m_cursor & 0xFF;
    
    switch (chr)
    {   case '\r':
            c = 0;
            break;
        case '\n':
            r++;
            r = (r > (m_Tmax >> 8)) ? r - 1 : r;
            break;
        case '\0':
            return;
        case 1:
            [self deleol];
            return;
        case 2:
            //delay(2);
           [self flush];
            return;
        case '\b':
            c = (c) ? c - 1 : c;
            break;
        default:			/* printable char		*/
            c++;
            c = (c > (m_Tmax & 0xFF)) ? c - 1 : c;
            break;
    }
    [self TTout:(chr)];				// and send out the char
    m_cursor = (r << 8) + c;		// save new cursor position
}


/***************************
 * Take number in decimal and send it to output().
 */

-(void) decprt:(int) i
{
    if (m_watch)
    {
        if (i < 0)
        {   [self output:('-')];
            i = -i;				// absolute value
        }
        if (i/10)
            [self decprt:(i/10)];
        [self output:(i % 10 + '0')];
    }
}


/***************************
 * Send string to output.
 */

-(void) imes:(NSString*) p
{
    //printf("imes('%s')\n",p);
    if (m_watch)
    {
        char c;
        for(int i =0 ;i<[p length]; i++) {
            c  = [p characterAtIndex:i];
            [self output: c ];
        }
//       [self flush];
    }
}

/***************************
 * Send string to output.
 */

-(void) smes:(NSString*)p
{
    //printf("smes('%s')\n",p);
    if (m_watch)
    {
        [self imes:(p)];
    }
}


/****************************
 * Formatted print.
 */

- (void) vsmes:(NSString*) str
{
    [self smes:str];
}

/****************************
 * Position cursor and type message.
 */

-(void) cmes:(int) rc type:(NSString *)p
{
    if (!m_watch) return;
    [self TTcurs:(rc)];
    [self imes:(p)];
}


/*************************
 * Initialize operating system
 * to have:
 *	single character input
 *	turn off echo
 */

-(void) TTinit
{
    m_inbuf = -1;		// no character in input
    //nrows = 160 / 10;
    //ncols = 120 / 10;
    m_nrows = VBUFROWS;
    m_ncols = VBUFCOLS;
}


/**************************
 * Restore operating system
 */

-(void) TTdone
{
}

/***************************************
 * Print out location in row,col format
 */

-(void) locprt:(loc_t) loc
{

    int nRow = [empire ROW:loc];
    int nCol = [empire COL:loc];
    [self vsmes:[NSString stringWithFormat:@"%d,%d", nRow,nCol]];
}

-(void) locdot:(loc_t) loc
{
    int nRow = [empire ROW:loc];
    int nCol = [empire COL:loc];
    
    [self vsmes:[NSString stringWithFormat:@"%d,%d", nRow,nCol]];
    [self deleol];
}

-(void) space
{
    [self output:(' ')];
}

-(void) crlf
{
    [self imes:@"\r\n"];
}

-(void) put:(unsigned int) rc val :(unsigned int) value
{
    if (m_watch)
    {
        [self curs:(rc)];
        [self output:(value)];
    }
}

-(void) flush
{
    if (m_watch && m_anychanges)
    {
//       [self win_flush];
        m_anychanges = 0;
    }
}


/***************************************
 * Put messages in different spots for 40 col or 80 col display
 * Returns:
 *	cursor address of start of message
 */

-(int) DS:(int) row
{
    if (m_narrow)			// if 40 column display
        return (row << 8) + 0;
    else
        return (row << 8) + 20;
}


-(void) speaker_click	// click speaker
{
    if (m_watch && m_speaker)
    {
        if( m_speaker )
            [[OALSimpleAudio sharedInstance] playEffect:@"click.wav" loop:false];
    }
}

@end
