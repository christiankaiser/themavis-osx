//
//  TMTextField.m
//  ThemaMap
//
//  Created by Christian Kaiser on 16.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMTextField.h"
#import "TMTextView.h"

@implementation TMTextField




-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
}






-(void)drawRect:(NSRect)rect
{	
	[super drawRect:rect];
	
	TMTextView *superView = (TMTextView*)[self superview];
	if ([superView isSelected])
		[superView drawSelectionInRect:rect];
}




-(void)mouseDown:(NSEvent*)event
{
	if ([self isEditable])
	{
		[super mouseDown:event];
	}
	else
	{
		TMTextView *superView = (TMTextView*)[self superview];
		[superView mouseDown:event];
	}
}



@end
