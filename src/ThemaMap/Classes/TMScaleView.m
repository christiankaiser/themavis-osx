//
//  TMScaleView.m
//  ThemaMap
//
//  Created by Christian on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TMScaleView.h"


@implementation TMScaleView








-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        _mapView = nil;
		_scaleLength = 1000.0f;
		_scaleUnitFactor = 1.0f;
		_scaleUnit = @"m";
		_numberOfDivisions = 5;
    }
    return self;
}






-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	
	_mapView = [decoder decodeObjectForKey:@"TMScaleViewMapView"];
	_scaleLength = [decoder decodeDoubleForKey:@"TMScaleViewScaleLength"];
	_scaleUnitFactor = [decoder decodeDoubleForKey:@"TMScaleViewScaleUnitFactor"];
	_scaleUnit = [decoder decodeObjectForKey:@"TMScaleViewScaleUnit"];
	_numberOfDivisions = [decoder decodeIntegerForKey:@"TMScaleViewNumberOfDivisions"];
	
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:_mapView forKey:@"TMScaleViewMapView"];
	[encoder encodeDouble:_scaleLength forKey:@"TMScaleViewScaleLength"];
	[encoder encodeDouble:_scaleUnitFactor forKey:@"TMScaleViewScaleUnitFactor"];
	[encoder encodeObject:_scaleUnit forKey:@"TMScaleViewScaleUnit"];
	[encoder encodeInteger:_numberOfDivisions forKey:@"TMScaleViewNumberOfDivisions"];
	
}








-(void)drawRect:(NSRect)rect
{
	
	double marginTop = 10.0f;
	double tickLengthLong = 7.0f;
	double tickLengthShort = 4.0f;
	double textDistanceToTick = 3.0f;
	double fontSize = 12.0f;
	
	[super drawRect:rect];
	
	if (_mapView == nil)
	{
		NSLog(@"[TMScaleView drawRect:] No layer available.");
		return;
	}
	
	
	// Compute the length of the scale (in pixels)
	NSRect mapViewBounds = [_mapView bounds];
	TMEnvelope *mapViewBBox = [_mapView adjustedEnvelope];
	double mvScaleFactor = [mapViewBBox width] / mapViewBounds.size.width;
	double scaleWidthPixels = _scaleLength / mvScaleFactor;
	
	
	// Compute the left and right margins. Scale is centered in the view.
	double marginLeft = ([self bounds].size.width - scaleWidthPixels) / 2.0f;
	if (marginLeft < 0.0f) marginLeft = 0.0f;
	
	
	// Draw the lines for the scale.
	double viewTop = [self bounds].origin.y + [self bounds].size.height;
	NSBezierPath *l = [[NSBezierPath alloc] init];
	
	[l moveToPoint:NSMakePoint(marginLeft, viewTop - marginTop - tickLengthLong)];
	[l lineToPoint:NSMakePoint(marginLeft, viewTop - marginTop)];
	[l lineToPoint:NSMakePoint(marginLeft + scaleWidthPixels, viewTop - marginTop)];
	[l lineToPoint:NSMakePoint(marginLeft + scaleWidthPixels, viewTop - marginTop - tickLengthLong)];
	
	int i;
	for (i = 1; i < _numberOfDivisions; i++)
	{
		[l moveToPoint:NSMakePoint(marginLeft + (double)i * (scaleWidthPixels / (double)_numberOfDivisions), 
								   viewTop - marginTop)];
		[l lineToPoint:NSMakePoint(marginLeft + (double)i * (scaleWidthPixels / (double)_numberOfDivisions), 
								   viewTop - marginTop - tickLengthShort)];
	}
	
	[l setLineWidth:0.4f];
	[[NSColor blackColor] set];
	[l stroke];
	
	
	
	// Write the text.
	
	double textY = viewTop - marginTop - tickLengthLong - textDistanceToTick - fontSize - 7.0f;
	
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@"0"];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
	NSRect textRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
	[layoutManager drawGlyphsForGlyphRange:glyphRange 
								   atPoint:NSMakePoint(marginLeft - (textRect.size.width / 2.0f) - 3.0f, textY)];
	
	
	NSString *ustr = [NSString stringWithFormat:@"%i %@", roundtol(_scaleLength / _scaleUnitFactor), _scaleUnit];
	textStorage = [[NSTextStorage alloc] initWithString:ustr];
	layoutManager = [[NSLayoutManager alloc] init];
	textContainer = [[NSTextContainer alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
	textRect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
	[layoutManager drawGlyphsForGlyphRange:glyphRange 
								   atPoint:NSMakePoint(marginLeft + scaleWidthPixels - (textRect.size.width / 2.0f), 
													   textY)];
	
	
	
	if (_isSelected)
		[super drawSelectionInRect:rect];
	
}







-(TMMapView*)mapView
{
	return _mapView;
}
	
-(void)setMapView:(TMMapView*)mapView
{
	_mapView = mapView;
}


-(double)scaleLength
{
	return _scaleLength;
}

-(void)setScaleLength:(double)length
{
	_scaleLength = length;
}


-(double)scaleUnitFactor
{
	return _scaleUnitFactor;
}

-(void)setScaleUnitFactor:(double)factor
{
	_scaleUnitFactor = factor;
}


-(NSString*)scaleUnit
{
	return _scaleUnit;
}

-(void)setScaleUnit:(NSString*)unit
{
	_scaleUnit = unit;
}


-(NSUInteger)numberOfDivisions
{
	return _numberOfDivisions;
}

-(void)setNumberOfDivisions:(NSUInteger)n
{
	_numberOfDivisions = n;
}



@end
