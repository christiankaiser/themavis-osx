//
//  TMColorTable.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMColorTable : NSObject <NSCoding>
{
	NSString * _name;
	NSMutableArray * _colors;
}


-(NSString*)name;
-(void)setName:(NSString*)name;

-(NSMutableArray*)colors;
-(NSUInteger)countOfColors;
-(NSColor*)objectInColorsAtIndex:(NSUInteger)index;
-(void)addObjectToColors:(NSColor*)color;
-(void)insertObject:(NSColor*)color inColorsAtIndex:(NSUInteger)index;
-(void)removeObjectFromColorsAtIndex:(NSUInteger)index;

-(BOOL)isEqualTo:(TMColorTable*)otherColorTable;

@end
