//
//  TMShapefile.h
//  ThemaMap
//
//  Created by Christian Kaiser on 13.03.08.
//  Copyright 2008 361degrées. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMLayer.h"
#import "TMGeometry.h"
#import "TMLineString.h"
#import "TMPolygon.h"
#import "TMMultiPolygon.h"

#import "shapefil.h"



@interface TMShapefile : NSObject
{
	NSString * _path;
}



+(void)writeLayer:(TMLayer*)lyr toPath:(NSString*)path;


-(id)initWithPath:(NSString*)path;

-(NSString*)path;
-(void)setPath:(NSString*)path;

-(TMLayer*)read;


+(id)geometryFromShapeObject:(SHPObject*)shapeObject;

@end



void shapeObjectToLineString (SHPObject *shapeObject, TMLineString *lineString);
void shapeObjectToPolygon (SHPObject *shapeObject, TMPolygon *polygon);

void shapeObjectToMultiPolygon (
	SHPObject *shapeObject, TMMultiPolygon *multiPolygon);




