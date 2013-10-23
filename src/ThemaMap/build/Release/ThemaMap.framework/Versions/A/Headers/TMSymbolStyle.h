/**
 * ThemaMap/TMSymbolStyle
 *
 * @version 1.0, 24.3.2008
 * @author Christian Kaiser
 * @copyright 2008 361degres
 *
 * @description This class draws a defined symbol for each feature. If the
 * feature's geometry is a point, this point is taken as the center.
 * If the feature has a point geometry in the "center" attribute, this point
 * is taken as the center for the symbol. Otherwise, the centroid is computed 
 * in order to draw the symbol as this point.
 */
 
 

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"
#import "TMFillStyle.h"


@interface TMSymbolStyle : TMStyle <NSCoding>
{
	NSBezierPath * _symbol;
	NSUInteger _symbolWidth;
	NSUInteger _symbolHeight;
	TMFillStyle * _symbolStyle;
	TMFillStyle * _featureStyle;
}



-(id)initWithRectOfWidth:(NSUInteger)width andHeight:(NSUInteger)height;
-(id)initWithOvalOfWidth:(NSUInteger)width andHeight:(NSUInteger)height;
-(id)initWithCircleOfSize:(NSUInteger)size;


-(NSBezierPath*)symbol;
-(void)setSymbol:(NSBezierPath*)symbol;

-(NSUInteger)symbolWidth;
-(void)setSymbolWidth:(NSUInteger)width;

-(NSUInteger)symbolHeight;
-(void)setSymbolHeight:(NSUInteger)height;

-(TMFillStyle*)symbolStyle;
-(void)setSymbolStyle:(TMFillStyle*)symbolStyle;

-(TMFillStyle*)featureStyle;
-(void)setFeatureStyle:(TMFillStyle*)featureStyle;



// Returns a scaled copy of the symbol.
-(NSBezierPath*)symbolOfSize:(NSUInteger)size;




@end
