//
//  TMGeometry.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMGeometry.h"
#import "TMEnvelope.h"
#import "TMPoint.h"


@implementation TMGeometry





-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
}





-(id)envelope
{
	// Subclasses should implement this method.
	return nil;
}



-(id)centroid
{
	TMEnvelope *envelope = [self envelope];
	if (envelope == nil) return nil;
	
	TMPoint *centroid = [envelope centroid];
	return centroid;
}



-(NSBezierPath*)bezierPath
{
	// Subclasses should implement this method.
	return nil;
}



@end
