//
//  TMMapView.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMView.h"
#import "TMEnvelope.h"
#import "TMLayer.h"


@interface TMMapView : TMView
{
	NSMutableArray * _layers;
	TMEnvelope * _envelope;
	
	/**
	 * Specifies whether this view should be redrawn or not.
	 * <code>TMMapView</code> does implement a delayed redrawn mechanism
	 * in order to avoid too often redraws which could be very costly.
	 * Instead, <code>TMMapView</code> implements a timer which will verify 
	 * whether we should draw the page or not at a specified interval.
	 * The timer will invoke the <code>displayNow</code> method which will
	 * check this value before invoking the super view's 
	 * <code>setNeedsDisplay:</code> method.
	 */
	BOOL _needsDisplay;
	
	/**
	 * The display update interval in seconds.
	 */
	NSTimeInterval _displayUpdateInterval;
	
	/**
	 * The display timer.
	 */
	NSTimer * _displayTimer;
	
}


-(NSMutableArray*)layers;
-(NSUInteger)countOfLayers;
-(TMLayer*)objectInLayersAtIndex:(NSUInteger)index;
-(void)addObjectToLayers:(TMLayer*)layer;
-(void)insertObject:(TMLayer*)layer inLayersAtIndex:(NSUInteger)index;
-(void)removeObjectFromLayersAtIndex:(NSUInteger)index;

-(TMEnvelope*)envelope;
-(void)setEnvelope:(TMEnvelope*)envelope;



/**
 * Returns an adjusted envelope which is proportional to the view's bounds.
 */
-(TMEnvelope*)adjustedEnvelope;



-(void)zoomToFullExtent;



#pragma mark --- Drawing the page ---

/**
 * Marks this view as to be drawn soon.
 */
-(void)displaySoon;

/**
 * Sets the super view's needsDisplay flag if the page's display flag is YES.
 */
-(void)displayNow;

/**
 * Returns the display update interval in seconds.
 */
-(NSTimeInterval)displayUpdateInterval;

/**
 * Modifies the display update interval.
 */
-(void)setDisplayUpdateInterval:(NSTimeInterval)seconds;




@end
