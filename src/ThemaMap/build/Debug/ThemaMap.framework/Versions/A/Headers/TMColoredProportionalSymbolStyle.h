//
//  TMColoredProportionalSymbolStyle.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrées. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMStyle.h"
#import "TMProportionalSymbolStyle.h"
#import "TMChoroplethStyle.h"


@interface TMColoredProportionalSymbolStyle : TMStyle
{
	TMProportionalSymbolStyle * _proportionalSymbolStyle;
	TMChoroplethStyle * _choroplethStyle;
}


-(TMProportionalSymbolStyle*)proportionalSymbolStyle;
-(void)setProportionalSymbolStyle:(TMProportionalSymbolStyle*)style;

-(TMChoroplethStyle*)choroplethStyle;
-(void)setChoroplethStyle:(TMChoroplethStyle*)style;



@end
