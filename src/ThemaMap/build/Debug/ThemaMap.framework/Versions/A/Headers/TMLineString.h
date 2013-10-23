//
//  TMLineString.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrées. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMGeometry.h"
#import "TMPoint.h"


@interface TMLineString : TMGeometry
{

	/**
	 * An array of TMPoints defining the line string.
	 */
	NSMutableArray * _points;
}



/**
 * Returns the array containing all the TMPoints defining this line string.
 * @return a mutable array containing all TMPoints.
 */
-(NSMutableArray*)points;


/**
 * Returns the number of points.
 */
-(NSUInteger)countOfPoints;

-(TMPoint*)objectInPointsAtIndex:(NSUInteger)index;

-(void)addObjectToPoints:(TMPoint*)point;

-(void)insertObject:(TMPoint*)point inPointsAtIndex:(NSUInteger)index;

-(void)removeObjectFromPointsAtIndex:(NSUInteger)index;


@end
