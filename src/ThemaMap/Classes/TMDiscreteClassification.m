//
//  TMDiscreteClassification.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMDiscreteClassification.h"


@implementation TMDiscreteClassification


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
	_values = [decoder decodeObjectForKey:@"TMDiscreteClassificationValues"];
	_labels = [decoder decodeObjectForKey:@"TMDiscreteClassificationLabels"];
	_colorTable = 
		[decoder decodeObjectForKey:@"TMDiscreteClassificationColorTable"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_values forKey:@"TMDiscreteClassificationValues"];
	[encoder encodeObject:_labels forKey:@"TMDiscreteClassificationLabels"];
	[encoder encodeObject:_colorTable 
		forKey:@"TMDiscreteClassificationColorTable"];
}





-(NSColor*)colorForValue:(id)value
{	
	
	// Check for no data value.
	double dblValue = [value doubleValue];
	if (_hasNoDataValue && _noDataValue != nil)
	{
		double dblNoData = [_noDataValue doubleValue];
		if (dblValue == dblNoData) return _noDataColor;
	}

	NSUInteger colorIndex = 0;
	
	NSEnumerator *classValueEnumerator = [_values objectEnumerator];
	id classValue;
	BOOL classValueFound = NO;
	while ((classValue = [classValueEnumerator nextObject]) && 
			classValueFound == NO)
	{
		if ([value compare:classValue] == NSOrderedSame)
			classValueFound = YES;
		else
			colorIndex++;
	}
	
	if (classValueFound == NO)
		return nil;
	
	NSColor *color = [_colorTable objectInColorsAtIndex:colorIndex];
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






-(void)drawLegendToRect:(NSRect)legendRect
{
	
	
	// Define some parameters (which are constants for the moment).
	CGFloat boxHeight = 16.0f;
	CGFloat boxWidth = 24.0f;
	CGFloat boxSeparationY = 4.0f;			// Vertical distance between two boxes.
	CGFloat distanceBoxToLabel = 6.0f;		// Distance between the box and the label.
	CGFloat labelFontSize = 10.0f;			// Font size of the label in points.
	
	
	
	// Define an attributes dictionary for drawing the text.
	NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// Set the font attributes.
	[attrs setObject:[NSFont userFontOfSize:labelFontSize] forKey:NSFontAttributeName];
	[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	
	
	// Draw all the boxes. For each value, there is one box.
	int i;
	for (i = 0; i < [_colorTable countOfColors]; i++)
	{
		
		// Define the rect for the box.
		NSRect boxRect = NSMakeRect(legendRect.origin.x,
									(legendRect.origin.y + legendRect.size.height) - (i * (boxHeight + boxSeparationY)) - boxHeight, 
									boxWidth, boxHeight);
		
		// Get the color for the value.
		NSColor *boxColor = [self colorForValue:[_values objectAtIndex:i]];
		
		// Draw the box.
		NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:boxRect];
		[boxColor set];
		[boxPath fill];
		[boxPath setLineWidth:0.3f];
		[[NSColor blackColor] set];
		[boxPath stroke];
		
		// Write the label at the right side of the label.
		NSPoint labelOrigin = NSMakePoint(legendRect.origin.x + boxWidth + distanceBoxToLabel, 
										  boxRect.origin.y + ((boxHeight - labelFontSize) / 2));

		NSString *label = [_labels objectAtIndex:i];
		if (label != nil)
			[label drawAtPoint:labelOrigin withAttributes:attrs];
		
	}
	
	
	
}








@end
