//
//  TMScrollView.h
//  ThemaVis
//
//  Created by Christian on 02.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>


@interface TMScrollView : NSScrollView
{
	/**
	 * Every instance of this class creates a popup button with zoom factors 
	 * in it and places it next to the horizontal scroll bar.
	 */
    NSPopUpButton * _factorPopUpButton;

    /**
	 * The current zoom factor.
	 */
	CGFloat _factor;
}



-(IBAction)setFactorAction:(id)sender;


-(CGFloat)factor;
-(void)setFactor:(CGFloat)factor;

-(void)validateFactorPopUpButton;


@end
