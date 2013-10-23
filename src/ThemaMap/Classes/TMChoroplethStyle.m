//
//  TMChoroplethStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMChoroplethStyle.h"

#import "TMLegendView.h"




@implementation TMChoroplethStyle


-(id)init
{
    if ((self = [super init]))
	{
		_classification = nil;
		_attributeName = nil;
		_drawBorder = YES;
		_borderWidth = 0.4;
		_borderColor = [NSColor whiteColor];
		_transparency = 0.0;
    }
    return self;
}



-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_classification = [decoder decodeObjectForKey:@"TMChoroplethStyleClassification"];
	_attributeName = [decoder decodeObjectForKey:@"TMChoroplethStyleAttributeName"];
	_drawBorder = [decoder decodeBoolForKey:@"TMChoroplethStyleDrawBorder"];
	_borderWidth = [decoder decodeDoubleForKey:@"TMChoroplethStyleBorderWidth"];
	_borderColor = [decoder decodeObjectForKey:@"TMChoroplethStyleBorderColor"];
	_transparency = [decoder decodeDoubleForKey:@"TMChoroplethStyleTransparency"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_classification forKey:@"TMChoroplethStyleClassification"];
	[encoder encodeObject:_attributeName forKey:@"TMChoroplethStyleAttributeName"];
	[encoder encodeBool:_drawBorder forKey:@"TMChoroplethStyleDrawBorder"];
	[encoder encodeDouble:_borderWidth forKey:@"TMChoroplethStyleBorderWidth"];
	[encoder encodeObject:_borderColor forKey:@"TMChoroplethStyleBorderColor"];
	[encoder encodeDouble:_transparency forKey:@"TMChoroplethStyleTransparency"];
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
	
	
	// Draw the background according to the classification.
	if (_classification != nil && _attributeName != nil)
	{
		id attributeValue = [feat attributeForKey:_attributeName];
		NSColor *fillColor = [_classification colorForValue:attributeValue];
		if (fillColor != nil)
		{
			[fillColor set];
			[geomPath fill];
		}
	}
	
	// Draw the border.
	if (_drawBorder && _borderColor != nil && _borderWidth > 0.0)
	{
		[_borderColor set];
		[geomPath setLineWidth:_borderWidth];
		[geomPath stroke];
	}

}




-(TMClassification*)classification
{
	return _classification;
}



-(void)setClassification:(TMClassification*)classification
{
	_classification = classification;
}




-(NSString*)attributeName
{
	return _attributeName;
}



-(void)setAttributeName:(NSString*)attributeName
{
	_attributeName = attributeName;
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



-(double)transparency
{
	return _transparency;
}



-(void)setTransparency:(double)transparency
{
	_transparency = transparency;
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
	
	
	
	// Start drawing the name of the layer, if necessary.
	if ([legend showLayerName])
	{
		currentTop -= [[legend layerNameFont] pointSize];
		
		// Define the layer name (use the alias if possible)
		NSString *layerName = [lyr name];
		if ([lyr alias] != nil && [[lyr alias] compare:@""] != NSOrderedSame)
			layerName = [lyr alias];
		
		// Set the font attributes.
		if ([legend layerNameFont] != nil)
			[attrs setObject:[legend layerNameFont] forKey:NSFontAttributeName];
		else
			[attrs setObject:[NSFont userFontOfSize:10] forKey:NSFontAttributeName];
		
		if ([legend layerNameColor] != nil)
			[attrs setObject:[legend layerNameColor] forKey:NSForegroundColorAttributeName];
		else
			[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
		
		// Write the layer name.
		[layerName drawAtPoint:NSMakePoint(left, currentTop)  withAttributes:attrs];
		
		currentTop -= 10.0f;
	}
	
	
	
	// Ask the classification to draw its legend inside a rectangle.
	// The height of the rectangle is equal to currentTop - 10 pixels of margin.
	double legendHeight = currentTop - 10.0f;
	if (legendHeight < 100.0f) legendHeight = 100.0f;		// Minimum height for legend is 100 pixels.
	double legendWidth = [legend bounds].size.width - 20.0f;
	if (legendWidth < 80.0f) legendWidth = 80.0f;			// Minimum width for legend is 80 pixels.
	NSRect legendRect = NSMakeRect(left, 10.0f, legendWidth, legendHeight);
	[_classification drawLegendToRect:legendRect];
	
	
}







@end
