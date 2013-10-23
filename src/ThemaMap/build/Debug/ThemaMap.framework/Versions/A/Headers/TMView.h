//
//  TMView.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMFillStyle.h"






@interface TMView : NSView
{
	TMFillStyle * _fillStyle;		// Background style for the view.
	BOOL _isSelected;				// Is this view currently selected ?
	NSString * _name;				// The name of the view.
}


-(TMFillStyle*)fillStyle;
-(void)setFillStyle:(TMFillStyle*)fillStyle;

-(BOOL)isSelected;
-(void)setIsSelected:(BOOL)selected;
-(void)select;
-(void)deselect;


-(NSString*)name;
-(void)setName:(NSString*)aString;


-(void)drawSelectionInRect:(NSRect)rect;
-(void)drawHandleAtPoint:(NSPoint)pt;


/**
 * Overwritten NSResponder method for handling mouse down events.
 * If this view gets a mouse down event, and we are in an interactive
 * context (superview returns YES to a isInteractive message), we
 * select this view.
 */
-(void)mouseDown:(NSEvent*)event;



/**
 * If the point is in one of the handles of the receiver return its number, 
 * TMViewNoHandle otherwise. The default implementation of this method 
 * invokes -isHandleAtPoint:underPoint: for the corners and on the sides of 
 * the rectangle returned by -bounds.
 */
-(NSInteger)handleUnderPoint:(NSPoint)point;



/**
 * Return YES if the handle at a point is under another point. 
 */
-(BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point;



-(void)resizeViewUsingHandle:(NSInteger)handle withEvent:(NSEvent*)event;


/**
 * Given that one of the receiver's handles has been dragged by the user, 
 * resize to match, and return the handle number that should be passed into 
 * subsequent invocations of this same method. The default implementation of 
 * this method assumes that the passed-in handle number was returned by a 
 * previous invocation of +creationSizingHandle or -handleUnderPoint:.
 */
-(NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point;



-(void)moveSelectedViewsWithEvent:(NSEvent*)event;




/**
 * Computes the frame for all views in the provided array.
 */
-(NSRect)frameForViews:(NSArray*)views;




/**
 * Returns YES if the view can be edited after a double-clic.
 * Default is NO.
 */
-(BOOL)viewHasInlineEditMode;

-(void)startEditing;
-(void)endEditing;


@end
