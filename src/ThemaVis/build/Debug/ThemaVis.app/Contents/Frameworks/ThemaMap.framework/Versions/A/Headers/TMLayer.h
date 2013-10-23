//
//  TMLayer.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"
#import "TMFeature.h"
#import "TMEnvelope.h"


@interface TMLayer : NSObject <NSCoding>
{
	NSString * _name;
	NSString * _alias;
	NSMutableArray * _features;
	TMStyle * _style;
}


-(NSString*)name;
-(void)setName:(NSString*)name;

-(NSString*)alias;
-(void)setAlias:(NSString*)alias;

-(NSMutableArray*)features;
-(NSUInteger)countOfFeatures;
-(TMFeature*)objectInFeaturesAtIndex:(NSUInteger)index;
-(void)addObjectToFeatures:(TMFeature*)feature;
-(void)insertObject:(TMFeature*)feature inFeaturesAtIndex:(NSUInteger)index;
-(void)removeObjectFromFeaturesAtIndex:(NSUInteger)index;

-(TMStyle*)style;
-(void)setStyle:(TMStyle*)style;


-(TMEnvelope*)envelope;



// Joins a CSV file to the attribute table of this layer.
-(BOOL)joinCSVFile:(NSString*)path 
		 separator:(char)sep 
  featureAttribute:(NSString*)attr 
		  csvField:(NSString*)fieldName;




/**
 * Draws the layer. The rect and the envelope are used for coordinate
 * transformation.
 */
-(void)drawFeaturesToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;
-(void)drawSymbolsToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;
-(void)drawLabelsToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;


@end







// Some functions for handling CSV files.


NSUInteger numberOfFieldsInString(const char *string, char separator);

// Returns the field type for a specified element in the string.
// 1 = string, 2 = decimal, 3 = integer, -1 = unknown/error
int fieldTypeForElementInString(const char *string, int index, char separator);

NSString *elementInStringAsString(const char *string, int index, char separator);




