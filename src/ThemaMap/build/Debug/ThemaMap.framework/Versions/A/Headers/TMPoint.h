//
//  TMPoint.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrées. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMGeometry.h"


@interface TMPoint : TMGeometry
{
	double _x;
	double _y;
}


+(id)pointWithX:(double)x andY:(double)y;

-(id)initWithX:(double)x andY:(double)y;

-(double)x;
-(void)setX:(double)x;

-(double)y;
-(void)setY:(double)y;



@end
