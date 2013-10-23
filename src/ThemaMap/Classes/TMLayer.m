//
//  TMLayer.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "common.h"
#import "TMLayer.h"
#import "TMGeometry.h"
#import <stdio.h>
#import <string.h>


@implementation TMLayer


-(id)init
{
	if (DEBUG) NSLog(@"[TMLayer init]");
		
    if ((self = [super init]))
	{
		_name = @"NewLayer";
		_alias = @"New layer";
		_features = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		_name = [decoder decodeObjectForKey:@"TMLayerName"];
		_alias = [decoder decodeObjectForKey:@"TMLayerAlias"];
		_features = [decoder decodeObjectForKey:@"TMLayerFeatures"];
		_style = [decoder decodeObjectForKey:@"TMLayerStyle"];
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_name forKey:@"TMLayerName"];
	[encoder encodeObject:_alias forKey:@"TMLayerAlias"];
	[encoder encodeObject:_features forKey:@"TMLayerFeatures"];
	[encoder encodeObject:_style forKey:@"TMLayerStyle"];
}





-(NSString*)name
{
	return _name;
}


-(void)setName:(NSString*)name
{
	// We don't accept an empty name
	if (name == nil || [name compare:@""] == NSOrderedSame)
		return;

	_name = name;
}



-(NSString*)alias
{
	return _alias;
}



-(void)setAlias:(NSString*)alias
{
	_alias = alias;
}



-(NSMutableArray*)features
{
	return _features;
}



-(NSUInteger)countOfFeatures
{
	return [_features count];
}




-(TMFeature*)objectInFeaturesAtIndex:(NSUInteger)index
{
	TMFeature *feature = [_features objectAtIndex:index];
	return feature;
}



-(void)addObjectToFeatures:(TMFeature*)feature
{
	[_features addObject:feature];
}




-(void)insertObject:(TMFeature*)feature inFeaturesAtIndex:(NSUInteger)index
{
	[_features insertObject:feature atIndex:index];
}



-(void)removeObjectFromFeaturesAtIndex:(NSUInteger)index
{
	[_features removeObjectAtIndex:index];
}



-(TMStyle*)style
{
	return _style;
}



-(void)setStyle:(TMStyle*)style
{
	_style = style;
}





-(TMEnvelope*)envelope
{
	TMEnvelope *envelope = nil;
	
	NSEnumerator *featureEnumerator = [_features objectEnumerator];
	TMFeature *feat;
	
	while ((feat = [featureEnumerator nextObject]))
	{
		TMGeometry *geom = [feat attributeForKey:@"geom"];
		if (geom != nil)
		{
			if (envelope == nil)
				envelope = [geom envelope];
			else
				[envelope expandToIncludeEnvelope:[geom envelope]];
		}
	}
	
	return envelope;
}





-(BOOL)joinCSVFile:(NSString*)path 
		 separator:(char)sep 
  featureAttribute:(NSString*)attr 
		  csvField:(NSString*)fieldName
{
	
	char line[10240];		// For reading the lines.
	
	
	// Read the variable names. They are on the first line of the file.
	FILE *fp = fopen([path fileSystemRepresentation], "r");
	fgets(line, 10240, fp);
	fclose(fp);
	
	NSUInteger nvars = numberOfFieldsInString(line, sep);
	NSMutableArray *varNames = [[NSMutableArray alloc] initWithCapacity:nvars];
	int i;
	for (i = 0; i < nvars; i++)
	{
		NSString *name = elementInStringAsString(line, i, sep);
		[varNames addObject:name];
	}
	
	
	// Check whether we can find the CSV field for joining.
	int csvFieldIndex = -1;
	for (i = 0; i < [varNames count]; i++)
	{
		NSString *s = [varNames objectAtIndex:i];
		if ([s compare:fieldName] == NSOrderedSame)
		{
			csvFieldIndex = i;
			i = [varNames count];
		}
	}
	if (csvFieldIndex < 0)
	{
		NSLog(@"[TMLayer joinCSVFile:separator:featureAttribute:csvField:] CSV field for joining not found.");
		return NO;
	}
	
	
	// Find for every field the type (string, decimal or integer).
	// 1 = string, 2 = decimal, 3 = integer
	int *fieldTypes = calloc(nvars, sizeof(int));
	fp = fopen([path fileSystemRepresentation], "r");
	fgets(line, 10240, fp);
	
	while (fgets(line, 10240, fp) != NULL)
	{
		for (i = 0; i < nvars; i++)
		{
			int ftype = fieldTypeForElementInString(line, i, sep);
			if (ftype > fieldTypes[i]) fieldTypes[i] = ftype;
		}
	}
	
	fclose(fp);
	
	
	
	
	// For every line, read the elements and find the appropriate feature.
	fp = fopen([path fileSystemRepresentation], "r");
	fgets(line, 10240, fp);
	
	NSMutableDictionary *values = [[NSMutableDictionary alloc] initWithCapacity:nvars];
	
	while (fgets(line, 10240, fp) != NULL)
	{
		[values removeAllObjects];
		for (i = 0; i < nvars; i++)
		{
			NSString *val = elementInStringAsString(line, i, sep);
			NSNumber *numVal;
			switch (fieldTypes[i]) {
				case 2:
					numVal = [NSNumber numberWithDouble:[val doubleValue]];
					[values setObject:numVal forKey:[varNames objectAtIndex:i]];
					break;
				case 3:
					numVal = [NSNumber numberWithInt:[val intValue]];
					[values setObject:numVal forKey:[varNames objectAtIndex:i]];
					break;
				default:
					[values setObject:val forKey:[varNames objectAtIndex:i]];
					break;
			}
		}
		
		NSString *joinKey = [varNames objectAtIndex:csvFieldIndex];
		id joinValue = [values objectForKey:joinKey];
		
		// Going through all features for finding corresponding values.
		for (TMFeature *feat in _features)
		{
			id joinFeatureValue = [[feat attributes] objectForKey:attr];
			if (joinFeatureValue != nil)
			{
				if ([joinValue compare:joinFeatureValue] == NSOrderedSame)
				{
					// We have found a corresponding feature.
					// Copying all attributes into it.
					for (NSString *key in [values allKeys])
					{
						[[feat attributes] setObject:[values objectForKey:key] forKey:key];
					}
				}
			}
		}
	}
	
	
	
	// Going through all features to check whether we should insert some default values
	// for missing attributes.
	for (TMFeature *feat in _features)
	{
		i = 0;
		for (NSString *vname in varNames)
		{
			id obj = [[feat attributes] objectForKey:vname];
			if (obj == nil)
			{
				switch (fieldTypes[i])
				{
					case 2:
						[[feat attributes] setObject:[NSNumber numberWithDouble:0.0f] forKey:vname];
						break;
					case 3:
						[[feat attributes] setObject:[NSNumber numberWithInt:0] forKey:vname];
						break;
					default:
						[[feat attributes] setObject:@"" forKey:vname];
						break;
				}
			}
			i++;
		}
	}
	
	
	free(fieldTypes);
	
	return YES;
}







-(void)drawFeaturesToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	// If no style is defined, return directly.
	if (_style == nil) return;
	
	// Draw each feature.
	// Give the style the possibility to order to objects before drawing.
	[_style orderFeaturesBeforeDrawing:_features];
	TMFeature *feat;
	NSEnumerator *featureEnumerator = [_features objectEnumerator];
	while ((feat = [featureEnumerator nextObject]))
	{
		// Draw with the selected style.
		[_style drawFeature:feat inRect:rect withEnvelope:envelope];
	}
	
}



-(void)drawSymbolsToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	// If no style is defined, return directly.
	if (_style == nil) return;
	
	[_style orderFeaturesBeforeDrawingSymbols:_features];
	
	TMFeature *feat;
	NSEnumerator *featureEnumerator = [_features objectEnumerator];
	while ((feat = [featureEnumerator nextObject]))
	{
		// Draw with the selected style.
		[_style drawSymbolForFeature:feat inRect:rect withEnvelope:envelope];
	}
	
}



-(void)drawLabelsToRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	// If no style is defined, return directly.
	if (_style == nil) return;
	
	[_style orderFeaturesBeforeDrawingLabels:_features];
	
	TMFeature *feat;
	for (feat in _features)
	{
		[_style drawLabelForFeature:feat inRect:rect withEnvelope:envelope];
	}
	
}



@end








NSUInteger numberOfFieldsInString(const char *string, char separator)
{
	int nchars = strlen(string);
	int i;
	NSUInteger nseparators = 0;
	for (i = 0; i < nchars; i++)
	{
		if (string[i] == separator)
			nseparators++;
	}
	nseparators++;		// One more field than separator.
	return nseparators;
}





int fieldTypeForElementInString(const char *string, int index, char separator)
{
	NSString *element = elementInStringAsString(string, index, separator);
	char *elementString = (char*)[element cStringUsingEncoding:[NSString defaultCStringEncoding]];
	if (elementString == NULL) return -1;
	
	int nchars = strlen(elementString);
	int type = 3;
	int i;
	for (i = 0; i < nchars; i++)
	{
		if ( elementString[i] != 46 && 
			(elementString[i] < 48 || elementString[i] > 57) &&
			elementString[i] != 0 &&
			elementString[i] != '\n' &&
			elementString[i] != '\r' &&
			elementString[i] != 45)
			return 1;
		
		if (elementString[i] == 46)
			type = 2;
	}
	return type;
}




NSString *elementInStringAsString(const char *string, int index, char separator)
{
	int nchars = strlen(string);
	int i;
	int elementNumber = 0;
	char element[1024];
	char *elementPtr = element;
	for (i = 0; i < nchars; i++)
	{
		if (string[i] == separator)
		{
			elementNumber++;
		}
		else if (elementNumber == index && string[i] != '\n' && string[i] != '\r')
		{
			*elementPtr = string[i];
			elementPtr++;
		}
		else if (elementNumber > index)
		{
			i = nchars;
		}
		
	}
	
	*elementPtr = 0;
	NSString *str = [NSString stringWithCString:element encoding:[NSString defaultCStringEncoding]];
	
	return str;
}








