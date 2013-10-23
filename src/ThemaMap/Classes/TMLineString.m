//
//  TMLineString.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMLineString.h"

#import "TMEnvelope.h"

@implementation TMLineString



-(id)init
{
    if ((self = [super init]))
	{
		_points = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_points = [decoder decodeObjectForKey:@"TMLineStringPoints"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_points forKey:@"TMLineStringPoints"];
}







-(NSBezierPath*)bezierPath
{
	if (_points == nil || [_points count] == 0) return nil;
	
	NSBezierPath *bezier = [NSBezierPath bezierPath];
	NSPoint bezierPoint;
	
	TMPoint *pt = [_points objectAtIndex:0];
	bezierPoint.x = [pt x];
	bezierPoint.y = [pt y];
	[bezier moveToPoint:bezierPoint];
	
	NSUInteger ptcnt;
	for (ptcnt = 1; ptcnt < [_points count]; ptcnt++)
	{
		pt = [_points objectAtIndex:ptcnt];
		bezierPoint.x = [pt x];
		bezierPoint.y = [pt y];
		[bezier lineToPoint:bezierPoint];
	}
	
	return bezier;
}





-(id)envelope
{
	if (_points == nil || [_points count] == 0) return nil;
	
	TMPoint *pt = [_points objectAtIndex:0];
	double minX = [pt x];
	double maxX = minX;
	double minY = [pt y];
	double maxY = minY;
	
	NSUInteger ptcnt;
	for (ptcnt = 1; ptcnt < [_points count]; ptcnt++)
	{
		pt = [_points objectAtIndex:ptcnt];
		if ([pt x] < minX) minX = [pt x];
		if ([pt x] > maxX) maxX = [pt x];
		if ([pt y] < minY) minY = [pt y];
		if ([pt y] > maxY) maxY = [pt y];
	}
	
	TMEnvelope *env = [[TMEnvelope alloc] init];
	[env setEast:maxX];
	[env setWest:minX];
	[env setNorth:maxY];
	[env setSouth:minY];
	
	return env;
	
}






-(NSMutableArray*)points
{
	return _points;
}



-(NSUInteger)countOfPoints
{
	return [_points count];
}




-(TMPoint*)objectInPointsAtIndex:(NSUInteger)index
{
	TMPoint *pt = [_points objectAtIndex:index];
	return pt;
}



-(void)addObjectToPoints:(TMPoint*)point
{
	[_points addObject:point];
}




-(void)insertObject:(TMPoint*)point inPointsAtIndex:(NSUInteger)index
{
	[_points insertObject:point atIndex:index];
}



-(void)removeObjectFromPointsAtIndex:(NSUInteger)index
{
	[_points removeObjectAtIndex:index];
}


@end
