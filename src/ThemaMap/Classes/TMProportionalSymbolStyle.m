//
//  TMProportionalSymbolStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//


#import <math.h>

#import "TMProportionalSymbolStyle.h"

#import "TMLegendView.h"


@implementation TMProportionalSymbolStyle


-(id)init
{
    if ((self = [super init]))
	{
		_attributeName = nil;
		_calibrationValue = nil;
		_calibrationSize = 10;
		_bias = nil;
    }
    return self;
}

	



-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_attributeName = [decoder decodeObjectForKey:@"TMProportionalSymbolStyleAttributeName"];
	_calibrationValue = [decoder decodeObjectForKey:@"TMProportionalSymbolStyleCalibrationValue"];
	_calibrationSize = [decoder decodeIntegerForKey:@"TMProportionalSymbolStyleCalibrationSize"];
	_bias = [decoder decodeObjectForKey:@"TMProportionalSymbolStyleBias"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_attributeName forKey:@"TMProportionalSymbolStyleAttributeName"];
	[encoder encodeObject:_calibrationValue forKey:@"TMProportionalSymbolStyleCalibrationValue"];
	[encoder encodeInteger:_calibrationSize forKey:@"TMProportionalSymbolStyleCalibrationSize"];
	[encoder encodeObject:_bias forKey:@"TMProportionalSymbolStyleBias"];
}








-(void)orderFeaturesBeforeDrawingSymbols:(NSMutableArray*)features
{
	
	// Order features according to the attribute value.
	//NSLog(@"Order features according to the attribute value.");
	[features sortUsingFunction:compareFeatures context:_attributeName];
	//NSLog(@"Order features terminated.");
	
}



-(void)drawSymbolForFeature:(TMFeature*)feat 
	inRect:(NSRect)rect 
	withEnvelope:(TMEnvelope*)envelope
{
	
	if (_calibrationValue == nil) return;
	
	NSNumber *attributeValue = [feat attributeForKey:_attributeName];
	if (attributeValue == nil) return;
	
	// Adjust the symbol width and height to correspond
	// to the attribute value.
	double attrValue = [attributeValue doubleValue];
	if (attrValue <= 0.0f) return;
	
	//NSLog([NSString stringWithFormat:@"Drawing symbol for value %f", attrValue]);
	
	double bias = 0.0;
	if (_bias != nil) bias = [_bias doubleValue];
	if (bias > 0) attrValue += bias;
	
	//NSLog(@"Bias corrected.");
	
	// Get the calibration value. Check for too small values.
	double calValue = [_calibrationValue doubleValue];
	if (calValue <= 0.0000001f) calValue = 0.0000001f;

	double calSizeArea = _calibrationSize * _calibrationSize;
	double attrSizeArea = (attrValue / calValue) * calSizeArea;
	double attrSize = sqrt(attrSizeArea);
	
	//NSLog([NSString stringWithFormat:@"Symbol size computed: %f", attrSize]);
	
	double widthHeightRatio = _symbolWidth / _symbolHeight;
	_symbolWidth = MAX((NSUInteger)roundtol(attrSize), 1);
	_symbolHeight = MAX((NSUInteger)roundtol(attrSize * widthHeightRatio), 1);

	//NSLog([NSString stringWithFormat:@"Symbol size in pixels: %i x %i",
	//	_symbolWidth, _symbolHeight]);

	if (_symbolWidth > 0 && _symbolHeight > 0)
	{
		//NSLog(@"Draw symbol for feature.");
		[super drawSymbolForFeature:feat inRect:rect withEnvelope:envelope];
	}
	
}



-(NSString*)attributeName
{
	return _attributeName;
}



-(void)setAttributeName:(NSString*)attributeName
{
	_attributeName = attributeName;
}



-(NSNumber*)calibrationValue
{
	return _calibrationValue;
}



-(void)setCalibrationValue:(NSNumber*)calibrationValue
{
	_calibrationValue = calibrationValue;
}



-(NSUInteger)calibrationSize
{
	return _calibrationSize;
}



-(void)setCalibrationSize:(NSUInteger)calibrationSize
{
	_calibrationSize = calibrationSize;
}



-(NSNumber*)bias
{
	return _bias;
}



-(void)setBias:(NSNumber*)bias
{
	_bias = bias;
}







-(double)symbolSizeForValue:(double)value
{
	
	double attrValue = value;
	
	
	// Correct the bias.
	double bias = 0.0;
	if (_bias != nil) bias = [_bias doubleValue];
	if (bias > 0) attrValue += bias;
	
	
	// Get the calibration value. Check for too small values.
	double calValue = [_calibrationValue doubleValue];
	if (calValue <= 0.0000001f) calValue = 0.0000001f;
	
	double calSizeArea = _calibrationSize * _calibrationSize;
	double attrSizeArea = (attrValue / calValue) * calSizeArea;
	
	
	return sqrt(attrSizeArea);
	
}






-(double)valueForSymbolSize:(double)symbolSize
{
	double attrSizeArea = symbolSize * symbolSize;
	
	double calSizeArea = _calibrationSize * _calibrationSize;
	if (calSizeArea == 0) return 0;
	
	double calValue = [_calibrationValue doubleValue];
	if (calValue <= 0.0000001f) calValue = 0.0000001f;
	
	double attrValue = (attrSizeArea / calSizeArea) * calValue;
	
	double bias = 0.0f;
	if (_bias != nil) bias = [_bias doubleValue];
	if (bias > 0) attrValue -= bias;
	
	return attrValue;
}






-(NSBezierPath*)symbolForValue:(double)value
{
	
	// Compute the symbol size.
	NSUInteger symbolSize = (NSUInteger)roundtol([self symbolSizeForValue:value]);
	if (symbolSize < 1) return nil;
	
	return [super symbolOfSize:symbolSize];
	
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
	
	
	
	
	// Define the size of the symbols, if necessary.
	NSMutableArray *svalues;
	if ([[legend valuesToDisplay] count] > 0)
	{
		svalues = [legend valuesToDisplay];
	}
	else
	{
		svalues = [[NSMutableArray alloc] initWithCapacity:3];
		
		// Find the maximum value in the layer to draw.
		double maxValue = 0.0f;
		for (TMFeature *feat in [lyr features])
		{
			double fval = [[feat attributeForKey:_attributeName] doubleValue];
			if (fval > maxValue) maxValue = fval;
		}
		
		// Compute the maximum space available for the symbols, and the associated value to the max space.
		double maxSpace = MIN((currentTop - 40.0f), ([legend bounds].size.width - left - 10.0f - 50.0f));
		if (maxSpace < 50.0f) maxSpace = 50.0f;
		double maxSpaceValue = [self valueForSymbolSize:maxSpace];
		
		// Define the biggest value for the symbols.
		double biggestSymbolValue = MIN(maxValue, maxSpaceValue);
		[svalues addObject:[NSNumber numberWithDouble:biggestSymbolValue]];
		
		
		// Try to determine a reasonable step for the symbol sizes.
		double ndigits = floor(log10(biggestSymbolValue));
		double secondValue = pow(10.0f, ndigits);
		if ( (biggestSymbolValue / secondValue) < 1.1f ) secondValue /= 2.0f;
		while ( (biggestSymbolValue / secondValue) > 4.0f ) secondValue *= 2.0f;
		
		[svalues addObject:[NSNumber numberWithDouble:secondValue]];
		[svalues addObject:[NSNumber numberWithDouble:(secondValue / 2.0f)]];
	}
	
	
	// Order the symbol sizes in the array.
	[svalues sortUsingSelector:@selector(compare:)];
	
	
	
	// Set the text attributes for writing the values at the right side of the symbols.
	double valueFontSize = 10.0f;
	if ([legend valueFont] != nil)
	{
		[attrs setObject:[legend valueFont] forKey:NSFontAttributeName];
		valueFontSize = [[legend valueFont] pointSize];
	}
	else
	{
		[attrs setObject:[NSFont userFontOfSize:10] forKey:NSFontAttributeName];
	}
	
	if ([legend valueColor] != nil) [attrs setObject:[legend valueColor] forKey:NSForegroundColorAttributeName];
	else [attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	
	currentTop -= (valueFontSize / 2.0f);
	
	
	// Get the height of the zone where we draw the symbols.
	double symbolZoneHeight = [self symbolSizeForValue:[[svalues lastObject] doubleValue]];
	double symbolBottom = currentTop - symbolZoneHeight;
	
	
	
	// Draw the symbols (the biggest first).
	NSEnumerator *senum = [svalues reverseObjectEnumerator];
	NSNumber *v;
	while ((v = [senum nextObject]))
	{
		double ssize = [self symbolSizeForValue:[v doubleValue]];
		NSBezierPath *symb = [super symbolOfSize:ssize];
		
		// Compute the origin of the symbol to draw.
		double sx = left + ((symbolZoneHeight - ssize) / 2.0f);
		
		
		//NSLog([NSString stringWithFormat:@"Symbol zone height: %f  -- Left: %f", symbolZoneHeight, left]);
		
		
		// Translate the symbol to the place to draw.
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform translateXBy:(sx - [symb bounds].origin.x) yBy:(symbolBottom - [symb bounds].origin.y)];
		[symb transformUsingAffineTransform:transform];
		
		// Draw the symbol.
		if ([_symbolStyle fillFeature] && [_symbolStyle fillColor] != nil)
		{
			[[_symbolStyle fillColor] set];
			[symb fill];
		}
		
		if ([_symbolStyle drawBorder] && 
			[_symbolStyle borderColor] != nil && [_symbolStyle borderWidth] > 0.0)
		{
			[[_symbolStyle borderColor] set];
			[symb setLineWidth:[_symbolStyle borderWidth]];
			[symb stroke];
		}
		
		
		
		// Write the value for the symbol.
		sx = left + symbolZoneHeight + 10;
		double sy = symbolBottom + ssize - (valueFontSize / 2.0f) - 4.0f;
		[[v stringValue] drawAtPoint:NSMakePoint(sx, sy) withAttributes:attrs];
		
		
	}
	
	
}















@end





int compareFeatures (id feature1, id feature2, void *attrName)
{
	TMFeature *f1 = feature1;
	TMFeature *f2 = feature2;
	NSString *attr = attrName;
	
	NSNumber *val1 = [f1 attributeForKey:attr];
	if (val1 == nil) return NSOrderedAscending;
	
	NSNumber *val2 = [f2 attributeForKey:attr];
	if (val2 == nil) return NSOrderedDescending;

	return [val2 compare:val1];
}


