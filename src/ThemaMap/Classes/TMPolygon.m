//
//  TMPolygon.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMPolygon.h"

#import "TMEnvelope.h"


@implementation TMPolygon



-(id)init
{
	if ((self = [super init]))
	{
		_exteriorRing = nil;
		_interiorRings = nil;
	}
	return self;
}






-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_exteriorRing = [decoder decodeObjectForKey:@"TMPolygonExteriorRing"];
	_interiorRings = [decoder decodeObjectForKey:@"TMPolygonInteriorRings"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_exteriorRing forKey:@"TMPolygonExteriorRing"];
	[encoder encodeObject:_interiorRings forKey:@"TMPolygonInteriorRings"];
}









-(id)envelope
{
	if (_exteriorRing == nil) return nil;
	TMEnvelope *envelope = [_exteriorRing envelope];
	
	if (_interiorRings != nil)
	{
		NSUInteger ringcnt;
		for (ringcnt = 0; ringcnt < [_interiorRings count]; ringcnt++)
		{
			TMLinearRing *interiorRing = [_interiorRings objectAtIndex:ringcnt];
			[envelope expandToIncludeEnvelope:[interiorRing envelope]];
		}
	}
	
	return envelope;
}






-(NSBezierPath*)bezierPath
{
	if (_exteriorRing == nil) return nil;
	
	NSBezierPath *bezier = [_exteriorRing bezierPath];
	
	if (_interiorRings != nil)
	{
		NSUInteger ringcnt;
		for (ringcnt = 0; ringcnt < [_interiorRings count]; ringcnt++)
		{
			TMLinearRing *interiorRing = [_interiorRings objectAtIndex:ringcnt];
			[bezier appendBezierPath:[interiorRing bezierPath]];
		}
	}
	
	return bezier;
}






-(id)initWithExteriorRing:(TMLinearRing*)ring
{
	if ((self = [super init]))
	{
		_exteriorRing = ring;
	}
	return self;
}



-(TMLinearRing*)exteriorRing
{
	return _exteriorRing;
}



-(void)setExteriorRing:(TMLinearRing*)ring
{
	_exteriorRing = ring;
}



-(NSMutableArray*)interiorRings
{
	return _interiorRings;
}



-(NSUInteger)countOfInteriorRings
{
	if (_interiorRings == nil) return 0;
	return [_interiorRings count];
}



-(TMLinearRing*)objectInInteriorRingsAtIndex:(NSUInteger)index
{
	if (_interiorRings == nil) return nil;
	TMLinearRing *ring = [_interiorRings objectAtIndex:index];
	return ring;
}



-(void)addObjectToInteriorRings:(TMLinearRing*)ring
{
	if (ring == nil)
		return;

	if (_interiorRings ==  nil)
		_interiorRings = [[NSMutableArray alloc] initWithCapacity:1];
	
	[_interiorRings addObject:ring];
}



-(void)insertObject:(TMLinearRing*)ring 
	inInteriorRingsAtIndex:(NSUInteger)index
{
	if (ring == nil)
		return;
	
	if (_interiorRings ==  nil)
		_interiorRings = [[NSMutableArray alloc] initWithCapacity:1];
		
	[_interiorRings insertObject:ring atIndex:index];
}



-(void)removeObjectFromInteriorRingsAtIndex:(NSUInteger)index
{
	if (_interiorRings == nil)
		return;
	
	[_interiorRings removeObjectAtIndex:index];
}




@end
