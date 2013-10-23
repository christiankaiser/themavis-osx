//
//  TMShapefile.m
//  ThemaMap
//
//  Created by Christian Kaiser on 13.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMShapefile.h"

#import "TMStyle.h"
#import "TMFillStyle.h"
#import "TMFeature.h"
#import "TMPoint.h"
#import "TMLinearRing.h"
#import "TMGeometryCollection.h"



@implementation TMShapefile


-(id)initWithPath:(NSString*)path
{
	if ((self = [super init]))
	{
        _path = [path stringByExpandingTildeInPath];
    }
    return self;
}




-(NSString*)path
{
	return _path;
}


-(void)setPath:(NSString*)path
{
	_path = [path stringByExpandingTildeInPath];
}



-(TMLayer*)read
{
	
	// Check whether there is a file at the given path location.
	if (_path == nil) return nil;
	NSFileManager * fman = [NSFileManager defaultManager];
	if ([fman fileExistsAtPath:_path] == NO) return nil;
	
	// Create a new layer.
	TMLayer *layer = [[TMLayer alloc] init];
	
	// Get the name of the Shapefile. We will use it for
	// the layer name.
	NSArray *pathComponents = [_path pathComponents];
	NSString *layerName = [pathComponents lastObject];
	
	// If there is a .shp extension (or .SHP), strip it.
	NSString *extension = [layerName substringFromIndex:([layerName length]-4)];
	if ([[extension lowercaseString] compare:@".shp"] == NSOrderedSame)
		layerName = [layerName substringToIndex:([layerName length]-4)];
	
	[layer setName:layerName];
	
	
	// We set the alias with the same name.
	[layer setAlias:layerName];
	
	
	// Create a default fill style.
	[layer setStyle:[[TMFillStyle alloc] init]];
	
	
	// Open the Shapefile.
	SHPHandle shp = SHPOpen([_path fileSystemRepresentation], "r");
	if (shp == NULL) return nil;
	
	// Get the number of features.
	int nfeat;
	SHPGetInfo(shp, &nfeat, NULL, NULL, NULL);
	
	// Read in every Feature.
	int featcnt;
	for (featcnt = 0; featcnt < nfeat; featcnt++)
	{
		// Create a new Feature.
		TMFeature *feat = [[TMFeature alloc] init];
		
		// Read the shape object and convert it into a geometry.
		SHPObject *obj = SHPReadObject(shp, featcnt);
		id geom = [TMShapefile geometryFromShapeObject:obj];
		SHPDestroyObject(obj);
		
		// Store the geometry in the "geom" attribute.
		[feat setAttribute:geom forKey:@"geom"];
		
		[layer addObjectToFeatures:feat];
		
	}
	
	// Close the Shapefile.
	SHPClose(shp);
	
	
	
	// Open the DBF file.
	DBFHandle dbf = DBFOpen([_path fileSystemRepresentation], "r");
	
	// Get the number of attributes.
	int nattrs = DBFGetFieldCount(dbf);
	
	// Read every attribute for every feature.
	int attrcnt;
	for (attrcnt = 0; attrcnt < nattrs; attrcnt++)
	{
		// Get the field info for this attribute.
		char fieldName[12];
		int fieldWidth;
		DBFFieldType type = 
			DBFGetFieldInfo(dbf, attrcnt, fieldName, &fieldWidth, NULL);
	
		NSString *attrName = [NSString stringWithCString:fieldName
			encoding:NSISOLatin1StringEncoding];
			
		// Make sure that we do not overwrite the "geom" attribute.
		if ([attrName compare:@"geom"] == NSOrderedSame)
			attrName = @"geom2";
	
		for (featcnt = 0; featcnt < nfeat; featcnt++)
		{
		
			TMFeature *feat = [layer objectInFeaturesAtIndex:featcnt];
			
			if (type == FTString)
			{
				const char * contentPtr = 
					DBFReadStringAttribute(dbf, featcnt, attrcnt);
					
				NSString *content =[NSString stringWithCString:contentPtr
					encoding:NSISOLatin1StringEncoding];
				
				[feat setAttribute:content forKey:attrName];
			}
			else if (type == FTInteger)
			{
				int i = DBFReadIntegerAttribute(dbf, featcnt, attrcnt);
				NSNumber *number = [NSNumber numberWithInt:i];
				[feat setAttribute:number forKey:attrName];
			}
			else if (type == FTDouble)
			{
				double d = DBFReadDoubleAttribute(dbf, featcnt, attrcnt);
				NSNumber *number = [NSNumber numberWithDouble:d];
				[feat setAttribute:number forKey:attrName];
			}
			
		}
		
	}
	
	return layer;
	
}







+(id)geometryFromShapeObject:(SHPObject*)shapeObject
{

	TMPoint *point;
	TMLineString *line;
	TMMultiPolygon *multiPolygon;
	TMPolygon *polygon;
	
	
	// Create the new geometry.
	switch (shapeObject->nSHPType)
	{
		case SHPT_POINT:
		case SHPT_POINTM:
		case SHPT_POINTZ:
			point = [[TMPoint alloc] initWithX:shapeObject->padfX[0] 
				andY:shapeObject->padfY[0]];
			return point;
			break;
		
		case SHPT_ARC:
		case SHPT_ARCM:
		case SHPT_ARCZ:
			line = [[TMLineString alloc] init];
			shapeObjectToLineString(shapeObject, line);
			return line;
			break;
		
		case SHPT_POLYGON:
		case SHPT_POLYGONM:
		case SHPT_POLYGONZ:
			if (shapeObject->nParts > 1)
			{
				multiPolygon = [[TMMultiPolygon alloc] init];
				shapeObjectToMultiPolygon(shapeObject, multiPolygon);
				return multiPolygon;
			}
			else
			{
				polygon = [[TMPolygon alloc] init];
				shapeObjectToPolygon(shapeObject, polygon);
				return polygon;
			}
			break;
			
	}

	return nil;
}







+(void)writeLayer:(TMLayer*)lyr toPath:(NSString*)path
{

	if (path == nil) return;

	
	// Define the Shapefile type.
	int shpType = SHPT_NULL;
	id geom = [[lyr objectInFeaturesAtIndex:0] attributeForKey:@"geom"];
	if ([geom class] == [TMPoint class]) 
	{
		shpType = SHPT_POINT;
	}
	else if ([geom class] == [TMLineString class] || 
			 [geom class] == [TMLinearRing class])
	{
		shpType = SHPT_ARC;
	}
	else if ([geom class] == [TMEnvelope class] ||
			 [geom class] == [TMMultiPolygon class] ||
			 [geom class] == [TMPolygon class])
	{
		shpType = SHPT_POLYGON;
	}
	
	if (shpType == SHPT_NULL) return;
	
	
	// Create a new Shapefile.
	SHPHandle shp = SHPCreate([path fileSystemRepresentation], shpType);
	if (shp == NULL) return;
	

	
	// Write every Feature.
	int nfeat = [lyr countOfFeatures];
	int featcnt;
	TMFeature *feat;
	for (featcnt = 0; featcnt < nfeat; featcnt++)
	{
		// Get the feature from the layer.
		feat = [lyr objectInFeaturesAtIndex:featcnt];
		
		// Convert the feature geometry into a shape object.
		geom = [feat attributeForKey:@"geom"];
		if (geom != nil)
		{
			SHPObject *obj = [TMShapefile shapeObjectFromGeometry:geom];
			if (obj != nil)
			{
				SHPWriteObject(shp, -1, obj);
				SHPDestroyObject(obj);
			}
		}
		
	}
	
	// Close the Shapefile.
	SHPClose(shp);
	
	
	
	// Create the DBF file.
	DBFHandle dbf = DBFCreate([path fileSystemRepresentation]);
	
	// Get the attributes keys.
	feat = [lyr objectInFeaturesAtIndex:0];
	NSArray *attrKeys = [[feat attributes] allKeys];
	
	// Add a field for each attribute in the feature.
	int i;
	for (i = 0; i < [attrKeys count]; i++)
	{
		NSString *attrName = [attrKeys objectAtIndex:i];
		
		// Find the attribute type for the DBF field.
		
		
		// Find the field length.
		
		
		
	}
	

	
	
	
	
	
	
}





@end










void shapeObjectToLineString (SHPObject *shapeObject, TMLineString *lineString)
{
	int ptcnt;
	for (ptcnt = 0; ptcnt < shapeObject->nVertices; ptcnt++)
	{
		TMPoint *point = [[TMPoint alloc] 
			initWithX:shapeObject->padfX[ptcnt] andY:shapeObject->padfY[ptcnt]];
		
		[lineString addObjectToPoints:point];
	}
}





void shapeObjectToPolygon (SHPObject *shapeObject, TMPolygon *polygon)
{

	TMLinearRing *ring = [[TMLinearRing alloc] init];
	
	int ptcnt;
	for (ptcnt = 0; ptcnt < shapeObject->nVertices; ptcnt++)
	{
		TMPoint *point = [[TMPoint alloc] 
			initWithX:shapeObject->padfX[ptcnt] andY:shapeObject->padfY[ptcnt]];
		
		[ring addObjectToPoints:point];
	}
	
	[polygon setExteriorRing:ring];
}




void shapeObjectToMultiPolygon (
	SHPObject *shapeObject, TMMultiPolygon *multiPolygon)
{

	int polycnt;
	int ptcnt = 0;
	for (polycnt = 0; polycnt < shapeObject->nParts; polycnt++)
	{
		TMLinearRing *ring = [[TMLinearRing alloc] init];
		
		BOOL partEnd = NO;
		while (partEnd == NO)
		{
			TMPoint *point = [[TMPoint alloc] 
			initWithX:shapeObject->padfX[ptcnt] andY:shapeObject->padfY[ptcnt]];
		
			[ring addObjectToPoints:point];
			
			ptcnt++;
			if (ptcnt == shapeObject->nVertices)
			{
				partEnd = YES;
			}
			else if (polycnt < (shapeObject->nParts + 1) &&
					 ptcnt == shapeObject->panPartStart[polycnt+1])
			{
				partEnd = YES;
			}
		}
		
		TMPolygon *polygon = [[TMPolygon alloc] init];
		[polygon setExteriorRing:ring];
		[multiPolygon addObjectToGeometries:(TMGeometry*)polygon];
		
	}

}


