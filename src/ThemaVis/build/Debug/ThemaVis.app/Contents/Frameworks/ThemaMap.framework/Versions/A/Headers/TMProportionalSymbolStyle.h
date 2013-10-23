//
//  TMProportionalSymbolStyle.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"
#import "TMSymbolStyle.h"




@interface TMProportionalSymbolStyle : TMSymbolStyle <NSCoding>
{
	NSString * _attributeName;
	NSNumber * _calibrationValue;
	NSUInteger _calibrationSize;
	NSNumber * _bias;
}


-(NSString*)attributeName;
-(void)setAttributeName:(NSString*)attributeName;

-(NSNumber*)calibrationValue;
-(void)setCalibrationValue:(NSNumber*)calibrationValue;

-(NSUInteger)calibrationSize;
-(void)setCalibrationSize:(NSUInteger)calibrationSize;

-(NSNumber*)bias;
-(void)setBias:(NSNumber*)bias;




-(double)symbolSizeForValue:(double)value;				// Returns the symbol size for a given value.
-(double)valueForSymbolSize:(double)symbolSize;			// Returns the value for a given symbol size.


-(NSBezierPath*)symbolForValue:(double)value;			// Returns a scaled symbol for the given value.


@end



/**
 * Compares two features given the attribute name.
 */
int compareFeatures (id feature1, id feature2, void *attrName);


