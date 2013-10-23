//
//  TMContinuousClassification.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//


/**
 * This class represents a continuous classification where the limits
 * between two classes are defined. The limit itself is associated with
 * the higher value class.
 */
 


#import <Cocoa/Cocoa.h>

#import "TMClassification.h"
#import "TMColorTable.h"


@interface TMContinuousClassification : TMClassification <NSCoding>
{
	NSMutableArray * _limits;
	NSMutableArray * _labels;
	TMColorTable * _colorTable;
}


-(NSMutableArray*)limits;
-(void)setLimits:(NSMutableArray*)limits;
-(NSUInteger)countOfLimits;
-(NSNumber*)objectInLimitsAtIndex:(NSUInteger)index;
-(void)addObjectToLimits:(NSNumber*)limit;
-(void)insertObject:(NSNumber*)limit inLimitsAtIndex:(NSUInteger)index;
-(void)removeObjectFromLimitsAtIndex:(NSUInteger)index;

-(NSMutableArray*)labels;
-(void)setLabels:(NSMutableArray*)labels;
-(NSUInteger)countOfLabels;
-(NSString*)objectInLabelsAtIndex:(NSUInteger)index;
-(void)addObjectToLabels:(NSString*)label;
-(void)insertObject:(NSString*)label inLabelsAtIndex:(NSUInteger)index;
-(void)removeObjectFromLabelsAtIndex:(NSUInteger)index;

-(TMColorTable*)colorTable;
-(void)setColorTable:(TMColorTable*)colorTable;


@end
