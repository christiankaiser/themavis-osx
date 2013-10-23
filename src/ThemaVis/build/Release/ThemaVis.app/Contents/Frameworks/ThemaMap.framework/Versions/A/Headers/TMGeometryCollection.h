//
//  TMGeometryCollection.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMGeometry.h"


@interface TMGeometryCollection : TMGeometry <NSCoding>
{
	NSMutableArray * _geometries;
}


-(NSMutableArray*)geometries;
-(NSUInteger)countOfGeometries;
-(TMGeometry*)objectInGeometriesAtIndex:(NSUInteger)index;
-(void)addObjectToGeometries:(TMGeometry*)geom;
-(void)insertObject:(TMGeometry*)geom inGeometriesAtIndex:(NSUInteger)index;
-(void)removeObjectFromGeometriesAtIndex:(NSUInteger)index;


@end
