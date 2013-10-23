//
//  TMChoroplethStyle.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"
#import "TMClassification.h"


@interface TMChoroplethStyle : TMStyle <NSCoding>
{
	TMClassification * _classification;
	NSString * _attributeName;
	BOOL _drawBorder;
	double _borderWidth;
	NSColor * _borderColor;
	double _transparency;
}



-(TMClassification*)classification;
-(void)setClassification:(TMClassification*)classification;

-(NSString*)attributeName;
-(void)setAttributeName:(NSString*)attributeName;

-(BOOL)drawBorder;
-(void)setDrawBorder:(BOOL)drawBorder;

-(double)borderWidth;
-(void)setBorderWidth:(double)borderWidth;

-(NSColor*)borderColor;
-(void)setBorderColor:(NSColor*)borderColor;

-(double)transparency;
-(void)setTransparency:(double)transparency;


@end
