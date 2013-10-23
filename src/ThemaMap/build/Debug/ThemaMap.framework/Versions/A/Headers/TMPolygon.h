//
//  TMPolygon.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrées. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMGeometry.h"
#import "TMLinearRing.h"


@interface TMPolygon : TMGeometry
{
	TMLinearRing * _exteriorRing;
	NSMutableArray * _interiorRings;
}


-(id)initWithExteriorRing:(TMLinearRing*)ring;

-(TMLinearRing*)exteriorRing;

-(void)setExteriorRing:(TMLinearRing*)ring;


-(NSMutableArray*)interiorRings;

-(NSUInteger)countOfInteriorRings;

-(TMLinearRing*)objectInInteriorRingsAtIndex:(NSUInteger)index;

-(void)addObjectToInteriorRings:(TMLinearRing*)ring;

-(void)insertObject:(TMLinearRing*)ring 
	inInteriorRingsAtIndex:(NSUInteger)index;

-(void)removeObjectFromInteriorRingsAtIndex:(NSUInteger)index;



@end
