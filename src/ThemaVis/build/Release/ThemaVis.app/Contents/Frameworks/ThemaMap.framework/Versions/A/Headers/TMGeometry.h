//
//  TMGeometry.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMGeometry : NSObject <NSCoding>
{
}




/**
 * Returns the envelope of the geometry, or nil if the geometry is empty.
 * The envelope is an instance of TMEnvelope.
 */
-(id)envelope;



/**
 * Returns the centroid of the geometry, or nil if there are no points
 * in the geometry. The returned centroid is a instance of TMPoint.
 */
-(id)centroid;



-(NSBezierPath*)bezierPath;

@end
