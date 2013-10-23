//
//  TMLegendView.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMLegendView.h"


@implementation TMLegendView



-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        _lyr = nil;
		
		_showLayerName = YES;
		_layerNameFont = [NSFont userFontOfSize:12.0];
		_layerNameColor = [NSColor blackColor];
		
		_showVariableName = YES;
		_variableNameFont = [NSFont userFontOfSize:10.0];
		_variableNameColor = [NSColor blackColor];

		_showValues = YES;
		_valueFont = [NSFont userFontOfSize:10.0];
		_valueColor = [NSColor blackColor];
		
		_valuesToDisplay = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}






-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	
	_lyr = [decoder decodeObjectForKey:@"TMLegendViewLayer"];
	
	_showLayerName = [decoder decodeBoolForKey:@"TMLegendViewShowLayerName"];
	_layerNameFont = [decoder decodeObjectForKey:@"TMLegendViewLayerNameFont"];
	_layerNameColor = [decoder decodeObjectForKey:@"TMLegendViewLayerNameColor"];
	
	_showVariableName = [decoder decodeBoolForKey:@"TMLegendViewShowVariableName"];
	_variableNameFont = [decoder decodeObjectForKey:@"TMLegendViewVariableNameFont"];
	_variableNameColor = [decoder decodeObjectForKey:@"TMLegendViewVariableNameColor"];

	_showValues = [decoder decodeBoolForKey:@"TMLegendViewShowValues"];
	_valueFont = [decoder decodeObjectForKey:@"TMLegendViewValueFont"];
	_valueColor = [decoder decodeObjectForKey:@"TMLegendViewValueColor"];
	
	_valuesToDisplay = [decoder decodeObjectForKey:@"TMLegendViewValuesToDisplay"];
	
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeObject:_lyr forKey:@"TMLegendViewLayer"];
	
	[encoder encodeBool:_showLayerName forKey:@"TMLegendViewShowLayerName"];
	[encoder encodeObject:_layerNameFont forKey:@"TMLegendViewLayerNameFont"];
	[encoder encodeObject:_layerNameColor forKey:@"TMLegendViewLayerNameColor"];
	
	[encoder encodeBool:_showVariableName forKey:@"TMLegendViewShowVariableName"];
	[encoder encodeObject:_variableNameFont forKey:@"TMLegendViewVariableNameFont"];
	[encoder encodeObject:_variableNameColor forKey:@"TMLegendViewVariableNameColor"];
	
	[encoder encodeBool:_showValues forKey:@"TMLegendViewShowValues"];
	[encoder encodeObject:_valueFont forKey:@"TMLegendViewValueFont"];
	[encoder encodeObject:_valueColor forKey:@"TMLegendViewValueColor"];
	
	[encoder encodeObject:_valuesToDisplay forKey:@"TMLegendViewValuesToDisplay"];
}








-(void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (_lyr == nil) {
		NSLog(@"[TMLegendView drawRect:] No layer available.");
		return;
	}
	[[_lyr style] drawLegendForLayer:_lyr inView:self];
	
	
	if (_isSelected) [super drawSelectionInRect:rect];
}





-(TMLayer*)layer {
	return _lyr;
}



-(void)setLayer:(TMLayer*)layer {
	_lyr = layer;
}






-(BOOL)showLayerName
{
	return _showLayerName;
}

-(void)setShowLayerName:(BOOL)showLayerName
{
	_showLayerName = showLayerName;
}

-(NSFont*)layerNameFont
{
	return _layerNameFont;
}

-(void)setLayerNameFont:(NSFont*)font
{
	_layerNameFont = font;
}

-(NSColor*)layerNameColor
{
	return _layerNameColor;
}

-(void)setLayerNameColor:(NSColor*)clr
{
	_layerNameColor = clr;
}

-(BOOL)showVariableName
{
	return _showVariableName;
}

-(void)setShowVariableName:(BOOL)showVariableName
{
	_showVariableName = showVariableName;
}

-(NSFont*)variableNameFont
{
	return _variableNameFont;
}

-(void)setVariableNameFont:(NSFont*)font
{
	_variableNameFont = font;
}

-(NSColor*)variableNameColor
{
	return _variableNameColor;
}

-(void)setVariableNameColor:(NSColor*)clr
{
	_variableNameColor = clr;
}


-(BOOL)showValues
{
	return _showValues;
}

-(void)setShowValues:(BOOL)showValues
{
	_showValues = showValues;
}

-(NSFont*)valueFont
{
	return _valueFont;
}

-(void)setValueFont:(NSFont*)font
{
	_valueFont = font;
}

-(NSColor*)valueColor
{
	return _valueColor;
}

-(void)setValueColor:(NSColor*)clr
{
	_valueColor = clr;
}


-(NSMutableArray*)valuesToDisplay
{
	return _valuesToDisplay;
}







@end
