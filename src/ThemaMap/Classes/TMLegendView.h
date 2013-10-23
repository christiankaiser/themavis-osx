//
//  TMLegendView.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMView.h"
#import "TMStyle.h"
#import "TMLayer.h"


@interface TMLegendView : TMView <NSCoding>
{
	TMLayer * _lyr;
	
	// Layer name style
	BOOL _showLayerName;
	NSFont * _layerNameFont;
	NSColor * _layerNameColor;
	
	// Variable name style (the name of the variable if there is one)
	BOOL _showVariableName;
	NSFont * _variableNameFont;
	NSColor * _variableNameColor;
	
	// Value style (the style of the values if there are values)
	BOOL _showValues;
	NSFont * _valueFont;
	NSColor * _valueColor;
	
	// List of the values to display
	// If this list is empty, values are determined automatically
	NSMutableArray * _valuesToDisplay;
}


-(TMLayer*)layer;
-(void)setLayer:(TMLayer*)layer;


-(BOOL)showLayerName;
-(void)setShowLayerName:(BOOL)showLayerName;
-(NSFont*)layerNameFont;
-(void)setLayerNameFont:(NSFont*)font;
-(NSColor*)layerNameColor;
-(void)setLayerNameColor:(NSColor*)clr;

-(BOOL)showVariableName;
-(void)setShowVariableName:(BOOL)showVariableName;
-(NSFont*)variableNameFont;
-(void)setVariableNameFont:(NSFont*)font;
-(NSColor*)variableNameColor;
-(void)setVariableNameColor:(NSColor*)clr;

-(BOOL)showValues;
-(void)setShowValues:(BOOL)showValues;
-(NSFont*)valueFont;
-(void)setValueFont:(NSFont*)font;
-(NSColor*)valueColor;
-(void)setValueColor:(NSColor*)clr;

-(NSMutableArray*)valuesToDisplay;



@end
