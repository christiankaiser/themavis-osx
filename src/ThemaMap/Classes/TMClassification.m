//
//  TMClassification.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMClassification.h"


@implementation TMClassification



-(id)init
{
	if ((self = [super init]))
	{
		_name = @"Untitled classification";
		_description = @"";
		_hasNoDataValue = NO;
		_noDataValue = nil;
		_noDataColor = [NSColor whiteColor];
	}
	return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		_name = [decoder decodeObjectForKey:@"TMClassificationName"];
		
		_description = 
			[decoder decodeObjectForKey:@"TMClassificationDescription"];

		if ([decoder containsValueForKey:@"TMClassificationHasNoDataValue"])
		{
			_hasNoDataValue = [decoder 
				decodeBoolForKey:@"TMClassificationHasNoDataValue"];
		}
		else
		{
			_hasNoDataValue = NO;
		}
		
		if ([decoder containsValueForKey:@"TMClassificationNoDataValue"])
		{
			_noDataValue = [decoder 
				decodeObjectForKey:@"TMClassificationNoDataValue"];
		}
		else
		{
			_noDataValue = nil;
		}
		
		if ([decoder containsValueForKey:@"TMClassificationNoDataColor"])
		{
			_noDataColor = [decoder
				decodeObjectForKey:@"TMClassificationNoDataColor"];
		}
		else
		{
			_noDataColor = [NSColor whiteColor];
		}
		
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_name forKey:@"TMClassificationName"];
	[encoder encodeObject:_description forKey:@"TMClassificationDescription"];
	[encoder encodeBool:_hasNoDataValue forKey:@"TMClassificationHasNoDataValue"];
	[encoder encodeObject:_noDataValue forKey:@"TMClassificationNoDataValue"];
	[encoder encodeObject:_noDataColor forKey:@"TMClassificationNoDataColor"];
}





-(NSString*)name
{
	return _name;
}


-(void)setName:(NSString*)name
{
	_name = name;
}



-(NSString*)description
{
	return _description;
}


-(void)setDescription:(NSString*)description
{
	_description = description;
}





-(BOOL)hasNoDataValue
{
	return _hasNoDataValue;
}


-(void)setHasNoDataValue:(BOOL)flag
{
	_hasNoDataValue = flag;
}


-(NSNumber*)noDataValue
{
	return _noDataValue;
}


-(void)setNoDataValue:(NSNumber*)value
{
	_noDataValue = value;
}


-(NSColor*)noDataColor
{
	return _noDataColor;
}


-(void)setNoDataColor:(NSColor*)color
{
	_noDataColor = color;
}





-(NSColor*)colorForValue:(id)value
{
	// Subclasses should implement this method.
	return nil;
}




-(BOOL)isEqualTo:(id)otherClassification
{
	NSData *thisCf = [NSKeyedArchiver archivedDataWithRootObject:self];
	NSData *otherCf = 
		[NSKeyedArchiver archivedDataWithRootObject:otherClassification];
	
	return [thisCf isEqualToData:otherCf];
}





-(void)drawLegendToRect:(NSRect)legendRect
{
	// Subclasses should implement this method.
}




@end
