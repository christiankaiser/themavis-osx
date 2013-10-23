//
//  TMPage.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum
{
	TMMillimeters = 1,
	TMPixels = 2
	
} TMUnit;



@interface TMPage : NSView <NSCoding>
{
	TMUnit _unit;
	
	/**
	 * Page width and height, always in pixels.
	 */
	NSUInteger _pageWidth;
	NSUInteger _pageHeight;
	
	
	/**
	 * Specifies whether we should draw the page outline or not.
	 */
	BOOL _drawPageOutline;
	
	
	/**
	 * Specifies whether the user can modify interactively the 
	 * content views.
	 */
	BOOL _isInteractive;
	
	
	/**
	 * Specifies whether this page should be redrawn or not.
	 * <code>TMPage</code> does implement a delayed redrawn mechanism
	 * in order to avoid too often redraws which could be very costly.
	 * Instead, <code>TMPage</code> implements a timer which will verify 
	 * whether we should draw the page or not at a specified interval.
	 * The timer will invoke the <code>displayNow</code> method which will
	 * check this value before invoking the super view's 
	 * <code>setNeedsDisplay:</code> method.
	 */
	BOOL _needsDisplay;
	
	/**
	 * The display update interval in seconds.
	 */
	NSTimeInterval _displayUpdateInterval;
	
	/**
	 * The display timer.
	 */
	NSTimer * _displayTimer;
	
}



+(NSInteger)pixelsToMillimeters:(NSInteger)pixels;
+(NSInteger)millimetersToPixels:(NSInteger)millimeters;


-(NSUInteger)pageWidth;
-(void)setPageWidth:(NSUInteger)pageWidth;

-(NSUInteger)pageHeight;
-(void)setPageHeight:(NSUInteger)pageHeight;

-(TMUnit)unit;
-(void)setUnit:(TMUnit)unit;


-(BOOL)isInteractive;
-(void)setIsInteractive:(BOOL)interactive;


-(void)zoomToActualSize;
-(void)zoomToAll;
-(void)zoomToRect:(NSRect)rect;


#pragma mark --- Drawing the page ---

/**
 * Overridden method from NSView. TMPage does implement a delayed
 * display mechanism based on a NSTimer.
 */
-(void)setNeedsDisplay:(BOOL)flag;

/**
 * Sets the super view's needsDisplay flag if the page's display flag is YES.
 */
-(void)displayNow;

/**
 * Returns the display update interval in seconds.
 */
-(NSTimeInterval)displayUpdateInterval;

/**
 * Modifies the display update interval.
 */
-(void)setDisplayUpdateInterval:(NSTimeInterval)seconds;



#pragma mark --- Event Handling ---

/**
 * Overwritten NSResponder method for handling mouse down events.
 * If this view gets a mouse down event, none of the subviews is 
 * concerned. Therefore, we have to deselect all of the subviews
 * (only if this is an interactive view).
 */
-(void)mouseDown:(NSEvent*)theEvent;




/**
 * Returns an array containing the currently selected subviews.
 */
-(NSArray*)selectedViews;



/**
 * Writes the page to a PDF document.
 * @param path the path to the PDF document to create. An existing document
 * this path location is overridden.
 */
-(void)exportToPDF:(NSString*)path;


@end
