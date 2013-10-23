//
//  TMPoint.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMPoint.h"

#import "TMEnvelope.h"


@implementation TMPoint





+(id)pointWithX:(double)x andY:(double)y
{
	TMPoint *pt = [[TMPoint alloc] initWithX:x andY:y];
	return pt;
}






-(id)init
{
    if ((self = [super init]))
	{
		_x = 0.0;
		_y = 0.0;
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];

	_x = [decoder decodeDoubleForKey:@"TMPointX"];
	_y = [decoder decodeDoubleForKey:@"TMPointY"];
	
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeDouble:_x forKey:@"TMPointX"];
	[encoder encodeDouble:_y forKey:@"TMPointY"];	
	
}









-(id)envelope
{
	TMEnvelope *envelope = [[TMEnvelope alloc] init];
	[envelope setEast:_x];
	[envelope setWest:_x];
	[envelope setNorth:_y];
	[envelope setSouth:_y];
	return envelope;
}



-(id)centroid
{
	return self;
}




-(id)initWithX:(double)x andY:(double)y
{
	if ((self = [super init]))
	{
		_x = x;
		_y = y;
	}
	return self;
}




-(double)x
{
	return _x;
}



-(void)setX:(double)x
{
	_x = x;
}



-(double)y
{
	return _y;
}



-(void)setY:(double)y
{
	_y = y;
}





@end
