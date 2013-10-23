//
//  TMBezierPathView.m
//  ThemaVis
//
//  Created by Christian on 07.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMBezierPathView.h"
#import "TMUtilities.h"


@implementation TMBezierPathView



-(id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self)
	{
		NSRect bezierRect = NSMakeRect(0.0f, 0.0f, 20.0f, 20.0f);
        _path = [NSBezierPath bezierPathWithRect:bezierRect];
    }
    return self;
}




-(void)drawRect:(NSRect)rect
{

	
	// Adapt the view's bounds according to the bezier path.
	NSRect pathRect = [_path bounds];
	float hw = pathRect.size.width / 2;
	float hh = pathRect.size.height / 2;
	pathRect.origin.x -= hw;
	pathRect.origin.y -= hh;
	pathRect.size.width *= 2;
	pathRect.size.height *= 2;
	
	pathRect = TMProportionRect1WithRect2(pathRect, [self bounds]);
	[self setBounds:pathRect];
	
	
	// Draw a white background.
	[[NSColor grayColor] set];
	NSRectFill([self bounds]);
	
	[[NSColor whiteColor] set];
	NSRectFill(NSInsetRect([self bounds], 1.0f, 1.0f));
	
	
	// Draw the bezier path.
	[[NSColor grayColor] set];
	[_path fill];
	
	[[NSColor blackColor] set];
	[_path stroke];
}





-(NSBezierPath*)path
{
	return _path;
}



-(void)setPath:(NSBezierPath*)path
{
	_path = path;
}



-(NSString*)pathAsFScriptString:(NSString*)variableName
{
	NSString *var = variableName;
	if (var == NULL) var = @"_bezier";
	
	NSMutableString *cmd = [NSMutableString stringWithCapacity:100];
	[cmd appendFormat:@"%@ := NSBezierPath bezierPath.", var];
		
	NSInteger nElements = [_path elementCount];
	NSInteger i;
	NSPoint points[3];
	for (i = 0; i < nElements; i++)
	{
		NSBezierPathElement pElem = [_path elementAtIndex:i associatedPoints:(NSPointArray)points];
		switch (pElem)
		{
			case NSMoveToBezierPathElement:
				[cmd appendFormat:@"\n%@ moveToPoint:(%f<>%f).", var, points[0].x, points[0].y];
				break;
			case NSLineToBezierPathElement:
				[cmd appendFormat:@"\n%@ lineToPoint:(%f<>%f).", var, points[0].x, points[0].y];
				break;
			case NSCurveToBezierPathElement:
				[cmd appendFormat:@"\n%@ curveToPoint:(%f<>%f) controlPoint1:(%f<>%f) controlPoint2:(%f<>%f).", 
					var, points[2].x, points[2].y, points[0].x, points[0].y, points[1].x, points[1].y];
				break;
			case NSClosePathBezierPathElement:
				[cmd appendFormat:@"\n%@ closePath.", var];
				break;
		}
	}
	
	
	
	return [NSString stringWithString:cmd];
}


@end
