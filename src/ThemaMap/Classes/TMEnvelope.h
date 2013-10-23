//
//  TMEnvelope.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMGeometry.h"
#import "TMPoint.h"



@interface TMEnvelope : TMGeometry <NSCoding>
{
	double _east;
	double _west;
	double _north;
	double _south;
}



-(id)initWithEnvelope:(id)envelope;

-(double)east;
-(void)setEast:(double)east;

-(double)west;
-(void)setWest:(double)west;

-(double)north;
-(void)setNorth:(double)north;

-(double)south;
-(void)setSouth:(double)south;

-(double)width;
-(double)height;


-(void)expandToIncludePoint:(TMPoint*)point;
-(void)expandToIncludeX:(double)x andY:(double)y;
-(void)expandToIncludeEnvelope:(TMEnvelope*)envelope;



@end
