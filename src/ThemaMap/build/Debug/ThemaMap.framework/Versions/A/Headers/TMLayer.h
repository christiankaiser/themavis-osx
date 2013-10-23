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


@interface TMLayer : NSObject
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



/**
 * Draws the layer. The rect and the envelope are used for coordinate
 * transformation.
 */
-(void)drawToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;



@end
