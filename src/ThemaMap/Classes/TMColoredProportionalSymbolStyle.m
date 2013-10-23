//
//  TMColoredProportionalSymbolStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMColoredProportionalSymbolStyle.h"


@implementation TMColoredProportionalSymbolStyle




-(id)init
{
    if ((self = [super init]))
	{
		_proportionalSymbolStyle = [[TMProportionalSymbolStyle alloc] init];
		_choroplethStyle = [[TMChoroplethStyle alloc] init];
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_proportionalSymbolStyle = [decoder decodeObjectForKey:@"TMColoredProportionalSymbolStyleProportionalSymbolStyle"];
	_choroplethStyle = [decoder decodeObjectForKey:@"TMColoredProportionalSymbolStyleChoroplethStyle"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_proportionalSymbolStyle forKey:@"TMColoredProportionalSymbolStyleProportionalSymbolStyle"];
	[encoder encodeObject:_choroplethStyle forKey:@"TMColoredProportionalSymbolStyleChoroplethStyle"];
}






-(void)orderFeaturesBeforeDrawingSymbols:(NSMutableArray*)features
{
	[_proportionalSymbolStyle orderFeaturesBeforeDrawingSymbols:features];
}




-(void)drawFeature:(TMFeature*)feat 
	inRect:(NSRect)rect 
	withEnvelope:(TMEnvelope*)envelope
{
	[_proportionalSymbolStyle drawFeature:feat 
		inRect:rect withEnvelope:envelope];
}




-(void)drawSymbolForFeature:(TMFeature*)feat
	inRect:(NSRect)rect
	withEnvelope:(TMEnvelope*)envelope
{

	// Set the color of the proportional symbol style using
	// the choropleth style and draw the proportional symbol.
	
	if ([_choroplethStyle classification] != nil && 
		[_choroplethStyle attributeName] != nil)
	{
		id attributeValue = 
			[feat attributeForKey:[_choroplethStyle attributeName]];
			
		NSColor *fillColor = 
			[[_choroplethStyle classification] colorForValue:attributeValue];
			
		[[_proportionalSymbolStyle symbolStyle] setFillColor:fillColor];
	}
	else
	{
		[[_proportionalSymbolStyle symbolStyle] setFillColor:nil];
	}
	
	
	[_proportionalSymbolStyle drawSymbolForFeature:feat
		inRect:rect withEnvelope:envelope];
		
}




-(TMProportionalSymbolStyle*)proportionalSymbolStyle
{
	return _proportionalSymbolStyle;
}



-(void)setProportionalSymbolStyle:(TMProportionalSymbolStyle*)style
{
	_proportionalSymbolStyle = style;
}



-(TMChoroplethStyle*)choroplethStyle
{
	return _choroplethStyle;
}




-(void)setChoroplethStyle:(TMChoroplethStyle*)style
{
	_choroplethStyle = style;
}





-(void)drawLegendForLayer:(TMLayer*)lyr inView:(TMLegendView*)legend
{
	[_proportionalSymbolStyle drawLegendForLayer:lyr inView:legend];
	
	NSRect choroplethLegend = [legend bounds];
	choroplethLegend.origin.x += 10;
	choroplethLegend.size.height = 150;
	[[_choroplethStyle classification] drawLegendToRect:choroplethLegend];
	
}


@end
