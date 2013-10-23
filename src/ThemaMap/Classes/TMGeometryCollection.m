//
//  TMGeometryCollection.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMGeometryCollection.h"

#import "TMEnvelope.h"




@implementation TMGeometryCollection


-(id)init
{
    if ((self = [super init]))
	{
		_geometries = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}






-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_geometries = [decoder decodeObjectForKey:@"TMGeometryCollectionGeometries"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_geometries forKey:@"TMGeometryCollectionGeometries"];
}








-(NSBezierPath*)bezierPath
{
	if (_geometries == nil || [_geometries count] < 1)
		return nil;
	
	NSBezierPath *bezier = nil;
	NSUInteger geomcnt;
	for (geomcnt = 0; geomcnt < [_geometries count]; geomcnt++)
	{
		TMGeometry *geom = [_geometries objectAtIndex:geomcnt];
		if (geom != nil)
		{
			NSBezierPath *geomBezier = [geom bezierPath];
			if (bezier == nil)
				bezier = geomBezier;
			else if (geomBezier != nil)
				[bezier appendBezierPath:geomBezier];
		}
	}
	
	return bezier;
}




-(id)envelope
{
	if (_geometries == nil || [_geometries count] < 1)
		return nil;
		
	TMEnvelope *envelope = nil;
	NSUInteger geomcnt;
	for (geomcnt = 0; geomcnt < [_geometries count]; geomcnt++)
	{
		TMGeometry *geom = [_geometries objectAtIndex:geomcnt];
		if (envelope == nil)
			envelope = [geom envelope];
		else
			[envelope expandToIncludeEnvelope:[geom envelope]];
	}
	
	return envelope;
}




-(NSMutableArray*)geometries
{
	return _geometries;
}



-(NSUInteger)countOfGeometries
{
	return [_geometries count];
}



-(TMGeometry*)objectInGeometriesAtIndex:(NSUInteger)index
{
	TMGeometry *geom = [_geometries objectAtIndex:index];
	return geom;
}



-(void)addObjectToGeometries:(TMGeometry*)geom
{
	[_geometries addObject:geom];
}



-(void)insertObject:(TMGeometry*)geom inGeometriesAtIndex:(NSUInteger)index
{
	[_geometries insertObject:geom atIndex:index];
}



-(void)removeObjectFromGeometriesAtIndex:(NSUInteger)index
{
	[_geometries removeObjectAtIndex:index];
}



@end
