//
//  TMColorCell.m
//  ThemaVis
//
//  Created by Christian on 31.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMColorCell.h"


@implementation TMColorCell


-(id)init
{
	if ((self = [super init]))
	{
		[self setEditable:YES];
	}
	return self;
}




-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	NSRect colorRect = NSInsetRect(cellFrame, 0.5, 0.5);
   
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:colorRect];

	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:colorRect];

	[(NSColor*)[self objectValue] set];
	[NSBezierPath fillRect:NSInsetRect(colorRect, 2.0, 2.0)];
   
}





@end
