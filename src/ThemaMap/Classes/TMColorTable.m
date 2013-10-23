//
//  TMColorTable.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMColorTable.h"


@implementation TMColorTable



-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		_name = [decoder decodeObjectForKey:@"TMColorTableName"];
		_colors = [decoder decodeObjectForKey:@"TMColorTableColors"];
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_name forKey:@"TMColorTableName"];
	[encoder encodeObject:_colors forKey:@"TMColorTableColors"];
}




-(id)init
{
    if ((self = [super init]))
	{
		_name = @"Untitled color table";
		_colors = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}




-(NSString*)name
{
	return _name;
}




-(void)setName:(NSString*)name
{
	_name = name;
}



-(NSMutableArray*)colors
{
	return _colors;
}



-(NSUInteger)countOfColors
{
	return [_colors count];
}



-(NSColor*)objectInColorsAtIndex:(NSUInteger)index
{
	if (index >= [_colors count])
	{
		NSLog(@"[TMColorTable objectInColorsAtIndex:] Index out of bounds");
		return nil;
	}
	NSColor *color = [_colors objectAtIndex:index];
	return color;
}



-(void)addObjectToColors:(NSColor*)color
{
	[_colors addObject:color];
}



-(void)insertObject:(NSColor*)color inColorsAtIndex:(NSUInteger)index
{
	[_colors insertObject:color atIndex:index];
}



-(void)removeObjectFromColorsAtIndex:(NSUInteger)index
{
	[_colors removeObjectAtIndex:index];
}



-(BOOL)isEqualTo:(TMColorTable*)otherColorTable
{
	NSData *thisCT = [NSKeyedArchiver archivedDataWithRootObject:self];
	NSData *otherCT = 
		[NSKeyedArchiver archivedDataWithRootObject:otherColorTable];
	
	return [thisCT isEqualToData:otherCT];
}


@end
