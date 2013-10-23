//
//  TMScaleView.h
//  ThemaMap
//
//  Created by Christian on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMView.h"
#import "TMMapView.h"


@interface TMScaleView : TMView <NSCoding>
{
	TMMapView *		_mapView;
	double			_scaleLength;
	double			_scaleUnitFactor;		// displayed unit = map unit / scale unit factor
	NSString *		_scaleUnit;
	NSUInteger		_numberOfDivisions;
}


-(TMMapView*)mapView;
-(void)setMapView:(TMMapView*)mapView;

-(double)scaleLength;
-(void)setScaleLength:(double)length;

-(double)scaleUnitFactor;
-(void)setScaleUnitFactor:(double)factor;

-(NSString*)scaleUnit;
-(void)setScaleUnit:(NSString*)unit;

-(NSUInteger)numberOfDivisions;
-(void)setNumberOfDivisions:(NSUInteger)n;


@end
