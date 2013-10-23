//
//  TMStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMStyle.h"


@implementation TMStyle


-(id)init
{
	if ((self = [super init]))
	{
		_drawLabels = NO;
		_labelAttribute = nil;
		
		// Define the label text style.
		_labelStyle = [[NSMutableDictionary alloc] initWithCapacity:3];
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setAlignment:NSCenterTextAlignment];
		[_labelStyle setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
		[_labelStyle setObject:[NSFont userFontOfSize:10] forKey:NSFontAttributeName];
		[_labelStyle setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	}
	return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		_drawLabels = [decoder decodeBoolForKey:@"TMStyleDrawLabels"];
		_labelAttribute = [decoder decodeObjectForKey:@"TMStyleLabelAttribute"];
		_labelStyle = [decoder decodeObjectForKey:@"TMStyleLabelStyle"];
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeBool:_drawLabels forKey:@"TMStyleDrawLabels"];
	[encoder encodeObject:_labelAttribute forKey:@"TMStyleLabelAttribute"];
	[encoder encodeObject:_labelStyle forKey:@"TMStyleLabelStyle"];
}








-(BOOL)drawLabels
{
	return _drawLabels;
}


-(void)setDrawLabels:(BOOL)drawLabels
{
	_drawLabels = drawLabels;
}



-(NSString*)labelAttribute
{
	return _labelAttribute;
}


-(void)setLabelAttribute:(NSString*)labelAttr
{
	_labelAttribute = labelAttr;
}







-(void)orderFeaturesBeforeDrawing:(NSMutableArray*)features
{
	// Subclasses can implement this method.
}


-(void)orderFeaturesBeforeDrawingSymbols:(NSMutableArray*)features
{
	// Subclasses can implement this method.
}


-(void)orderFeaturesBeforeDrawingLabels:(NSMutableArray*)features
{
	// Subclasses can implement this method.
}





-(void)drawFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	// Subclasses should implement this method.
}
	

-(void)drawSymbolForFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	// Subclasses should implement this method.
}




-(void)drawLabelForFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope
{
	
	if (_drawLabels == NO || _labelAttribute == nil) return;
	
	
	// Get the value to draw.
	id attrValue = [feat attributeForKey:_labelAttribute];
	if (attrValue == nil) return;
	NSString *labelValue;
	if ([attrValue isKindOfClass:[NSString class]])
		labelValue = attrValue;
	else if ([attrValue respondsToSelector:@selector(stringValue)])
		labelValue = [attrValue performSelector:@selector(stringValue)];
	else
		return;
	
	
	// Get the geometry from the feature.
	TMGeometry *geom = [feat attributeForKey:@"geom"];
	if (geom == nil) return;
	
	// Get the point where we should draw the label.
	TMPoint *pt = [geom centroid];
	
	// Find the location in the view for the point.
	CGFloat scaleFactor = rect.size.width / [envelope width];
	CGFloat ox = ([pt x] - [envelope west]) * scaleFactor;
	CGFloat oy = ([pt y] - [envelope south]) * scaleFactor;
	NSPoint o = NSMakePoint(ox, oy);
	
	
	// Compute the width of the label. This is needed to shift the label
	// straight over the label origin.
	NSRect txtBBox = [labelValue boundingRectWithSize:NSMakeSize(10000.0, 10000.0) options:0 attributes:_labelStyle];
	o.x -= txtBBox.size.width / 2;
	o.y -= txtBBox.size.height / 2;
	
	
	// Draw the label
	[labelValue drawAtPoint:o  withAttributes:_labelStyle];
	
}






-(void)drawLegendForLayer:(TMLayer*)lyr inView:(TMLegendView*)legend
{
	// Subclasses should implement this method.
}

	
@end
