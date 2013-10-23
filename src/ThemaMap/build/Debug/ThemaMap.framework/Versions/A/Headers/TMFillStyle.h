//
//  TMFillStyle.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"



@interface TMFillStyle : TMStyle
{
	BOOL _drawBorder;
	double _borderWidth;
	NSColor * _borderColor;
	BOOL _fillFeature;
	NSColor * _fillColor;
}


-(BOOL)drawBorder;
-(void)setDrawBorder:(BOOL)drawBorder;

-(double)borderWidth;
-(void)setBorderWidth:(double)borderWidth;

-(NSColor*)borderColor;
-(void)setBorderColor:(NSColor*)borderColor;

-(BOOL)fillFeature;
-(void)setFillFeature:(BOOL)fillFeature;

-(NSColor*)fillColor;
-(void)setFillColor:(NSColor*)fillColor;

@end
