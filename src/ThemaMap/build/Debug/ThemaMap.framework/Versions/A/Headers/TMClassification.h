//
//  TMClassification.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMClassification : NSObject <NSCoding>
{
	NSString * _name;
	NSString * _description;
	
	BOOL _hasNoDataValue;
	NSNumber * _noDataValue;
	NSColor * _noDataColor;
}


-(NSString*)name;
-(void)setName:(NSString*)name;

-(NSString*)description;
-(void)setDescription:(NSString*)description;

-(BOOL)hasNoDataValue;
-(void)setHasNoDataValue:(BOOL)flag;

-(NSNumber*)noDataValue;
-(void)setNoDataValue:(NSNumber*)value;

-(NSColor*)noDataColor;
-(void)setNoDataColor:(NSColor*)color;


-(NSColor*)colorForValue:(id)value;

-(BOOL)isEqualTo:(id)otherClassification;


@end
