//
//  TMFillStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrees. All rights reserved.
//

#import "TMFillStyle.h"

#import "TMGeometry.h"
#import "TMLegendView.h"


@implementation TMFillStyle


-(id)init
{
    if ((self = [super init]))
	{
		_drawBorder = YES;
		_borderWidth = 0.3;
		_borderColor = [NSColor colorWithCalibratedWhite:0.1 alpha:1.0];
		_fillFeature = YES;
		_fillColor = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_drawBorder = [decoder decodeBoolForKey:@"TMFillStyleDrawBorder"];
	_borderWidth = [decoder decodeDoubleForKey:@"TMFillStyleBorderWidth"];
	_borderColor = [decoder decodeObjectForKey:@"TMFillStyleBorderColor"];
	_fillFeature = [decoder decodeBoolForKey:@"TMFillStyleFillFeature"];
	_fillColor = [decoder decodeObjectForKey:@"TMFillStyleFillColor"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeBool:_drawBorder forKey:@"TMFillStyleDrawBorder"];
	[encoder encodeDouble:_borderWidth forKey:@"TMFillStyleBorderWidth"];
	[encoder encodeObject:_borderColor forKey:@"TMFillStyleBorderColor"];
	[encoder encodeBool:_fillFeature forKey:@"TMFillStyleFillFeature"];
	[encoder encodeObject:_fillColor forKey:@"TMFillStyleFillColor"];
}








-(void)drawFeature:(TMFeature*)feat 
	inRect:(NSRect)rect 
	withEnvelope:(TMEnvelope*)envelope
{
	
	// Get the geometry from the feature.
	TMGeometry *geom = [feat attributeForKey:@"geom"];
	if (geom == nil) return;
	
	// Get the Bezier path from the geometry.
	NSBezierPath *geomPath = [geom bezierPath];
	
	// Transformation of the Bezier path.
	NSAffineTransform *transform = [NSAffineTransform transform];
	CGFloat translationX = (CGFloat)([envelope west] * -1.0);
	CGFloat translationY = (CGFloat)([envelope south] * -1.0);
	[transform translateXBy:translationX yBy:translationY];
	[geomPath transformUsingAffineTransform:transform];
	
	transform = [NSAffineTransform transform];
	CGFloat scaleFactor = rect.size.width / [envelope width];
	[transform scaleBy:scaleFactor];
	[geomPath transformUsingAffineTransform:transform];
	
	// Draw the background.
	if (_fillFeature && _fillColor != nil)
	{
		[_fillColor set];
		[geomPath fill];
	}
	
	// Draw the border.
	if (_drawBorder && _borderColor != nil && _borderWidth > 0.0)
	{
		[geomPath setLineWidth:_borderWidth];
		[_borderColor set];
		[geomPath stroke];
	}
	
}




-(BOOL)drawBorder
{
	return _drawBorder;
}


-(void)setDrawBorder:(BOOL)drawBorder
{
	_drawBorder = drawBorder;
}



-(double)borderWidth
{
	return _borderWidth;
}



-(void)setBorderWidth:(double)borderWidth
{
	_borderWidth = borderWidth;
}



-(NSColor*)borderColor
{
	return _borderColor;
}



-(void)setBorderColor:(NSColor*)borderColor
{
	_borderColor = borderColor;
}



-(BOOL)fillFeature
{
	return _fillFeature;
}


-(void)setFillFeature:(BOOL)fillFeature
{
	_fillFeature = fillFeature;
}



-(NSColor*)fillColor
{
	return _fillColor;
}



-(void)setFillColor:(NSColor*)fillColor
{
	_fillColor = fillColor;
}





-(void)drawLegendForLayer:(TMLayer*)lyr inView:(TMLegendView*)legend
{
	
	// Draw from top to bottom all the required elements.
	CGFloat currentTop = [legend bounds].origin.y + [legend bounds].size.height;
	CGFloat left = [legend bounds].origin.x + 10;
	
	// Insert a margin of 10 pixels.
	currentTop -= 10;
	
	// Define an attributes dictionary for drawing the text.
	NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	
	// Define the size of the box, and set the cursor to the top of the drawing region.
	CGFloat fontSize = [[legend layerNameFont] pointSize];
	CGFloat boxHeight = 16.0f;
	CGFloat boxWidth = 24.0f;
	currentTop -= MAX(fontSize, boxHeight) + 4;
	
	
	// Define the layer name (use the alias if possible)
	NSString *layerName = [lyr name];
	if ([lyr alias] != nil && [[lyr alias] compare:@""] != NSOrderedSame)
	{
		layerName = [lyr alias];
	}
	
	
	// Set the font attributes.
	if ([legend layerNameFont] != nil)
		[attrs setObject:[legend layerNameFont] forKey:NSFontAttributeName];
	else
		[attrs setObject:[NSFont userFontOfSize:10] forKey:NSFontAttributeName];
	
	
	if ([legend layerNameColor] != nil)
		 [attrs setObject:[legend layerNameColor] forKey:NSForegroundColorAttributeName];
	else
		 [attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		 
	
		 
	// Draw the box with the fill style.
	CGFloat boxBottom = currentTop;
	if (fontSize > boxHeight) boxBottom += (fontSize - boxHeight) / 2.0f;
	NSRect boxRect = NSMakeRect(left, boxBottom, boxWidth, boxHeight);
	NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:boxRect];
	
	// Draw the background.
	if (_fillFeature && _fillColor != nil)
	{
		[_fillColor set];
		[boxPath fill];
	}
	
	// Draw the border.
	if (_drawBorder && _borderColor != nil && _borderWidth > 0.0)
	{
		[boxPath setLineWidth:_borderWidth];
		[_borderColor set];
		[boxPath stroke];
	}
	
	
	
	// Write the layer name.
	CGFloat textBottom = currentTop;
	if (boxHeight > fontSize) textBottom += (boxHeight - fontSize) / 2.0f - 2.0f;
	
	
	[layerName drawAtPoint:NSMakePoint(left + boxWidth + 10.0f, textBottom)  withAttributes:attrs];
	
}








@end






