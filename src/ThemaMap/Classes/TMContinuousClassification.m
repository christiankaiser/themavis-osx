//
//  TMContinuousClassification.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMContinuousClassification.h"


@implementation TMContinuousClassification



-(id)init
{
    if ((self = [super init]))
	{
		_limits = [[NSMutableArray alloc] initWithCapacity:1];
		_labels = [[NSMutableArray alloc] initWithCapacity:1];
		_colorTable = nil;
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_limits = [decoder decodeObjectForKey:@"TMContinuousClassificationLimits"];
	_labels = [decoder decodeObjectForKey:@"TMContinuousClassificationLabels"];
	_colorTable = 
		[decoder decodeObjectForKey:@"TMContinuousClassificationColorTable"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_limits forKey:@"TMContinuousClassificationLimits"];
	[encoder encodeObject:_labels forKey:@"TMContinuousClassificationLabels"];
	[encoder encodeObject:_colorTable 
		forKey:@"TMContinuousClassificationColorTable"];
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

	NSInteger nlimits = [_colorTable countOfColors] - 1;
	NSMutableArray *orderedLimits = [_limits mutableCopy];
	while ([orderedLimits count] > nlimits)
		[orderedLimits removeLastObject];
	
	[orderedLimits sortUsingSelector:@selector(compare:)];
	
	NSInteger colorIndex = 0;
	
	NSEnumerator *limitEnumerator = [orderedLimits reverseObjectEnumerator];
	//NSEnumerator *limitEnumerator = [orderedLimits objectEnumerator];
	id limit;
	BOOL limitFound = NO;
	while ((limit = [limitEnumerator nextObject]) && limitFound == NO)
	{
		double dblLimit = [limit doubleValue];
		if (dblValue >= dblLimit)
			limitFound = YES;
		else
			colorIndex++;
	}
	
	if (limitFound == NO)
		colorIndex = [_colorTable countOfColors] - 1;

	//printf("Value: %f - Color index: %i\n", dblValue, colorIndex);
	
	NSColor *color = [_colorTable objectInColorsAtIndex:colorIndex];
	return color;
}



-(NSMutableArray*)limits
{
	return _limits;
}



-(void)setLimits:(NSMutableArray*)limits
{
	_limits = limits;
}



-(NSUInteger)countOfLimits
{
	return [_limits count];
}




-(NSNumber*)objectInLimitsAtIndex:(NSUInteger)index
{
	if (index >= [_limits count])
	{
		NSLog(@"[TMContinuousClassification objectInLimitsAtIndex:] Index out of bounds");
		return nil;
	}
	
	NSNumber *limit = [_limits objectAtIndex:index];
	return limit;
}



-(void)addObjectToLimits:(NSNumber*)limit
{
	[_limits addObject:limit];
}




-(void)insertObject:(NSNumber*)limit inLimitsAtIndex:(NSUInteger)index
{
	[_limits insertObject:limit atIndex:index];
}



-(void)removeObjectFromLimitsAtIndex:(NSUInteger)index
{
	[_limits removeObjectAtIndex:index];
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
	if (index >= [_labels count])
	{
		NSLog(@"[TMContinuousClassification objectInLabelsAtIndex:] Index out of bounds");
		return @"";
	}
	
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
	CGFloat boxSeparationY = 2.0f;			// Vertical distance between two boxes.
	CGFloat distanceBoxToLabel = 10.0f;		// Distance between the box and the label.
	CGFloat limitMarkLength = 7.0f;
	CGFloat labelFontSize = 10.0f;			// Font size of the label in points.
	
	
	
	// Define an attributes dictionary for drawing the text.
	NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	// Set the font attributes.
	[attrs setObject:[NSFont userFontOfSize:labelFontSize] forKey:NSFontAttributeName];
	[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	
	
	// Draw all the boxes. For each value, there is one box.
	int i;
	int ncolors = [[_colorTable colors] count];
	for (i = 0; i < ncolors; i++)
	{
		
		// Define the rect for the box.
		NSRect boxRect = NSMakeRect(legendRect.origin.x,
									(legendRect.origin.y + legendRect.size.height) - (i * (boxHeight + boxSeparationY)) - boxHeight, 
									boxWidth, boxHeight);
		
		// Get the color.
		NSColor *boxColor = [[_colorTable colors] objectAtIndex:i];
		
		// Draw the box.
		NSBezierPath *boxPath = [NSBezierPath bezierPathWithRect:boxRect];
		[boxColor set];
		[boxPath fill];
		[boxPath setLineWidth:0.3f];
		[[NSColor blackColor] set];
		[boxPath stroke];
		
		
		if (i < (ncolors - 1))
		{
			
			// Make the limit mark 
			NSBezierPath *limitMark = [[NSBezierPath alloc] init];
			[limitMark setLineWidth:0.3f];
			[limitMark moveToPoint:NSMakePoint(boxRect.origin.x + boxRect.size.width, boxRect.origin.y)];
			[limitMark lineToPoint:NSMakePoint(boxRect.origin.x + boxRect.size.width + limitMarkLength, 
											   boxRect.origin.y)];
			[limitMark stroke];
			
			
			// Write the label at the right side of the label.
			NSPoint labelOrigin = NSMakePoint(legendRect.origin.x + boxWidth + distanceBoxToLabel, 
											  boxRect.origin.y - (labelFontSize / 2));
		
			NSString *label = [_labels objectAtIndex:(ncolors - i - 2)];
			if (label != nil)
				[label drawAtPoint:labelOrigin withAttributes:attrs];
		}
		
		
	}

	
}


@end
