//
//  TMLinearRing.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMLinearRing.h"


@implementation TMLinearRing



-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
}






-(NSBezierPath*)bezierPath
{
	NSBezierPath *bezier = [super bezierPath];
	if (bezier != nil)
	{
		[bezier closePath];
	}
	
	return bezier;
}



@end
