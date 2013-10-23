//
//  TMEnvelope.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMEnvelope.h"


@implementation TMEnvelope



-(id)init
{
    if ((self = [super init]))
	{
		_east = 0.0;
		_west = 0.0;
		_north = 0.0;
		_south = 0.0;
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_east = [decoder decodeDoubleForKey:@"TMEnvelopeEast"];
	_west = [decoder decodeDoubleForKey:@"TMEnvelopeWest"];
	_north = [decoder decodeDoubleForKey:@"TMEnvelopeNorth"];
	_south = [decoder decodeDoubleForKey:@"TMEnvelopeSouth"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeDouble:_east forKey:@"TMEnvelopeEast"];
	[encoder encodeDouble:_west forKey:@"TMEnvelopeWest"];
	[encoder encodeDouble:_north forKey:@"TMEnvelopeNorth"];
	[encoder encodeDouble:_south forKey:@"TMEnvelopeSouth"];
}





-(id)initWithEnvelope:(id)envelope
{
	if ((self = [super init]))
	{
		TMEnvelope *env = envelope;
		_west = [env west];
		_east = [env east];
		_south = [env south];
		_north = [env north];
	}
	return self;
}


-(NSBezierPath*)bezierPath
{
	NSRect rect;
	rect.origin.x = _west;
	rect.origin.y = _south;
	rect.size.width = _east - _west;
	rect.size.height = _north - _south;
	NSBezierPath *bezier = [NSBezierPath bezierPathWithRect:rect];
	return bezier;
}




-(id)envelope
{
	return self;
}



-(id)centroid
{
	TMPoint *centroid = [[TMPoint alloc] init];
	[centroid setX:(_west + (0.5 * [self width]))];
	[centroid setY:(_south + (0.5 * [self height]))];
	return centroid;
}



-(double)east
{
	return _east;
}


-(void)setEast:(double)east
{
	_east = east;
}


-(double)west
{
	return _west;
}



-(void)setWest:(double)west
{
	_west = west;
}


-(double)north
{
	return _north;
}


-(void)setNorth:(double)north
{
	_north = north;
}



-(double)south
{
	return _south;
}



-(void)setSouth:(double)south
{
	_south = south;
}



-(double)width
{
	if (_east > _west)
		return (_east - _west);
	else
		return (_west - _east);
}



-(double)height
{
	if (_north > _south)
		return (_north - _south);
	else
		return (_south - _north);
}




-(void)expandToIncludePoint:(TMPoint*)point
{
	if (point == nil) return;
	[self expandToIncludeX:[point x] andY:[point y]];
}



-(void)expandToIncludeX:(double)x andY:(double)y
{
	if (x < _west) _west = x;
	if (x > _east) _east = x;
	if (y > _north) _north = y;
	if (y < _south) _south = y;
}



-(void)expandToIncludeEnvelope:(TMEnvelope*)envelope
{
	if (envelope == nil) return;
	if ([envelope west] < _west) _west = [envelope west];
	if ([envelope east] > _east) _east = [envelope east];
	if ([envelope north] > _north) _north = [envelope north];
	if ([envelope south] < _south) _south = [envelope south];
}



@end
