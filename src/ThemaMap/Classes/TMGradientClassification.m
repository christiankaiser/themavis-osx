//
//  TMGradientClassification.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import "TMGradientClassification.h"

#import <stdlib.h>



@implementation TMGradientClassification


-(id)init
{
    if ((self = [super init]))
	{
		_values = [[NSMutableArray alloc] initWithCapacity:1];
		_labels = [[NSMutableArray alloc] initWithCapacity:1];
		_colorTable = nil;
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_values = [decoder decodeObjectForKey:@"TMGradientClassificationValues"];
	_labels = [decoder decodeObjectForKey:@"TMGradientClassificationLabels"];
	_colorTable = 
		[decoder decodeObjectForKey:@"TMGradientClassificationColorTable"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_values forKey:@"TMGradientClassificationValues"];
	[encoder encodeObject:_labels forKey:@"TMGradientClassificationLabels"];
	[encoder encodeObject:_colorTable 
		forKey:@"TMGradientClassificationColorTable"];
}






-(NSColor*)colorForValue:(id)value
{

	double dblValue = [value doubleValue];

	// Check for no data value.
	if (_hasNoDataValue && _noDataValue != nil)
	{
		double dblNoData = [_noDataValue doubleValue];
		if (dblValue == dblNoData) return _noDataColor;
	}
	
	NSInteger ncolors = [_colorTable countOfColors];
	if (ncolors < 1) return nil;
	if (ncolors == 1) return [_colorTable objectInColorsAtIndex:0];

	NSInteger nClassValues = [_colorTable countOfColors];
	NSMutableArray *orderedValues = [_values mutableCopy];
	while ([orderedValues count] > nClassValues)
		[orderedValues removeLastObject];
	
	[orderedValues sortUsingSelector:@selector(compare:)];



	// Locate the upper and lower color indexes for the given value.
	NSUInteger colorIndexUpper = 0;
	NSUInteger colorIndexLower = 0;
	BOOL colorsFound = NO;
	
	
	// Check for the minimum and the maximum value.
	double minValue = [[orderedValues objectAtIndex:0] doubleValue];
	if (dblValue <= minValue)
		return [[_colorTable colors] lastObject];
		
	double maxValue = [[orderedValues lastObject] doubleValue];
	if (dblValue >= maxValue)
		return [[_colorTable colors] objectAtIndex:0];
	
	
	NSUInteger classValuesCount;
	double lowerClassValue, upperClassValue;
	for (classValuesCount = 0; 
		 classValuesCount < (nClassValues - 1);
		 classValuesCount++)
	{
		lowerClassValue = 
			[[orderedValues objectAtIndex:classValuesCount] doubleValue];
		
		upperClassValue =
			[[orderedValues objectAtIndex:(classValuesCount+1)] doubleValue];
		
		if (lowerClassValue == dblValue)
			return [_colorTable objectInColorsAtIndex:classValuesCount];
		
		if (upperClassValue == dblValue)
			return [_colorTable objectInColorsAtIndex:(classValuesCount+1)];
		
		if (dblValue > lowerClassValue && dblValue < upperClassValue)
		{
			// We have found the upper and lower values, assign
			// the indexes.
			colorIndexLower = classValuesCount;
			colorIndexUpper = classValuesCount + 1;
			
			// End the loop
			classValuesCount = nClassValues;
			colorsFound = YES;
		}
	}
	
	
	// If we have not found the class indexes, we simply return nil.
	if (colorsFound == NO)
		return nil;
		
	
	// Get the upper and lower color and their values.
	NSColor *upperColor = 
		[_colorTable objectInColorsAtIndex:(ncolors-colorIndexUpper-1)];
		
	NSColor *lowerColor = 
		[_colorTable objectInColorsAtIndex:(ncolors-colorIndexLower-1)];
	
	
	// Compute the new color.
	NSColor *color = [TMGradientClassification 
		gradientColorForValue:dblValue
		withLowerColor:lowerColor
		upperColor:upperColor
		lowerValue:lowerClassValue
		upperValue:upperClassValue];
	
	
	
	return color;
}





-(NSMutableArray*)values
{
	return _values;
}



-(void)setValues:(NSMutableArray*)values
{
	_values = values;
}



-(NSUInteger)countOfValues
{
	return [_values count];
}




-(NSNumber*)objectInValuesAtIndex:(NSUInteger)index
{
	NSNumber *value = [_values objectAtIndex:index];
	return value;
}



-(void)addObjectToValues:(NSNumber*)value
{
	[_values addObject:value];
}




-(void)insertObject:(NSNumber*)value inValuesAtIndex:(NSUInteger)index
{
	[_values insertObject:value atIndex:index];
}



-(void)removeObjectFromValuesAtIndex:(NSUInteger)index
{
	[_values removeObjectAtIndex:index];
}





-(NSMutableArray*)labels
{
	return _labels;
}



-(void)setLabels:(NSMutableArray*)labels
{
	_labels = labels;
}



-(NSUInteger)countOfLabels
{
	return [_labels count];
}




-(NSString*)objectInLabelsAtIndex:(NSUInteger)index
{
	NSString *label = [_labels objectAtIndex:index];
	return label;
}



-(void)addObjectToLabels:(NSString*)label
{
	[_labels addObject:label];
}




-(void)insertObject:(NSString*)label inLabelsAtIndex:(NSUInteger)index
{
	[_labels insertObject:label atIndex:index];
}



-(void)removeObjectFromLabelsAtIndex:(NSUInteger)index
{
	[_labels removeObjectAtIndex:index];
}





-(TMColorTable*)colorTable
{
	return _colorTable;
}



-(void)setColorTable:(TMColorTable*)colorTable
{
	_colorTable = colorTable;
}






+(NSColor*)gradientColorForValue:(double)value
				withLowerColor:(NSColor*)lowerColor
				upperColor:(NSColor*)upperColor
				lowerValue:(double)lowerClassValue
				upperValue:(double)upperClassValue
{

	NSInteger nComponents = [lowerColor numberOfComponents];
	NSColorSpace *colorSpace = [lowerColor colorSpace];
	
	// Make sure that the two color spaces are the same.
	NSColor *correctedUpperColor = [upperColor colorUsingColorSpace:colorSpace];


	// Get the color components.
	CGFloat lowerComponents[nComponents];
	[lowerColor getComponents:lowerComponents];
	CGFloat upperComponents[nComponents];
	[correctedUpperColor getComponents:upperComponents];
	
	
	// Compute the multiplication factor for the value. This factor has
	// a value between 0 and 1.
	double valueMultFactor = 
		(value - lowerClassValue) / (upperClassValue - lowerClassValue);
	
	
	// Compute the new components.
	int i;
	for (i = 0; i < nComponents; i++)
	{
		lowerComponents[i] = 
			(valueMultFactor * (upperComponents[i] - lowerComponents[i])) +
				lowerComponents[i];
	}


	// Create the new color with the computed components.
	NSColor *newColor = [NSColor colorWithColorSpace:colorSpace 
		components:lowerComponents count:nComponents];

	
	return newColor;

}









-(void)drawLegendToRect:(NSRect)legendRect
{
	
	
	// Define some parameters (which are constants for the moment).
	CGFloat gradientBoxHeight = 120.0f;
	CGFloat boxWidth = 24.0f;
	CGFloat distanceBoxToLabel = 10.0f;		// Distance between the box and the label.
	CGFloat limitMarkLength = 7.0f;
	CGFloat labelFontSize = 10.0f;			// Font size of the label in points.
	
	
	
	// Make some place at the top of the rectangle for the font.
	legendRect.origin.y -= labelFontSize / 2.0f;
	
	
	
	// Define an attributes dictionary for drawing the text.
	NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// Set the font attributes.
	[attrs setObject:[NSFont userFontOfSize:labelFontSize] forKey:NSFontAttributeName];
	[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	
	
	
	// Get the minimum and maximum values.
	double minValue = [[_values objectAtIndex:0] doubleValue];
	double maxValue = [[_values lastObject] doubleValue];
	
	
	// Create the arrays for the color gradient.
	CGFloat *locations = malloc([_values count] * sizeof(CGFloat));
	int i = 0;
	for (NSNumber *v in _values)
	{
		double currentValue = [v doubleValue];
		locations[i] = (currentValue - minValue) / (maxValue - minValue);
		i++;
	}
	
	NSGradient *gradient = [[NSGradient alloc] initWithColors:[_colorTable colors] 
												  atLocations:locations 
												   colorSpace:[NSColorSpace genericCMYKColorSpace]];
	
		
	// Define the rect for the box.
	NSRect boxRect = NSMakeRect(legendRect.origin.x,
								legendRect.origin.y + legendRect.size.height - gradientBoxHeight, 
								boxWidth, gradientBoxHeight);
	
	// Draw the gradient.
	[gradient drawInRect:boxRect angle:270.0f];
		
	// Draw the box.
	NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:boxRect];
	[boxPath setLineWidth:0.3f];
	[[NSColor blackColor] set];
	[boxPath stroke];
		

	for (i = 0; i < [_colorTable countOfColors]; i++)
	{
			
		// Make the limit mark 
		NSBezierPath *limitMark = [[NSBezierPath alloc] init];
		[limitMark setLineWidth:0.3f];
		
		CGFloat limitY = boxRect.origin.y + ((1-locations[i]) * gradientBoxHeight);
		
		[limitMark moveToPoint:NSMakePoint(boxRect.origin.x + boxRect.size.width, limitY)];
		[limitMark lineToPoint:NSMakePoint(boxRect.origin.x + boxRect.size.width + limitMarkLength, limitY)];
		[limitMark stroke];
			
			
		// Write the label at the right side of the label.
		NSPoint labelOrigin = NSMakePoint(legendRect.origin.x + boxWidth + distanceBoxToLabel, 
										  limitY - (labelFontSize / 2));

		NSString *label = [_labels objectAtIndex:i];
		if (label != nil)
			[label drawAtPoint:labelOrigin withAttributes:attrs];
		
	}
	
	
}







@end
