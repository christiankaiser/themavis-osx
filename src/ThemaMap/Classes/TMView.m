//
//  TMView.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMView.h"

#import "TMPage.h"


static CGFloat TMHandleWidth = 6.0f;
static CGFloat TMHandleHalfWidth = 6.0f / 2.0f;

/**
 * Constant for no handle.
 */
const NSInteger TMViewNoHandle = 0;


// The values that might be returned by -[SKTGraphic creationSizingHandle] 
// and -[TMView handleUnderPoint:], and that are understood 
// by -[SKTGraphic resizeByMovingHandle:toPoint:]. We provide specific 
// indexes in this enumeration so make sure none of them are zero 
// (that's SKTGraphicNoHandle) and to make sure the flipping 
// arrays in -[SKTGraphic resizeByMovingHandle:toPoint:] work.
enum {
    TMViewUpperLeftHandle = 1,
    TMViewUpperMiddleHandle = 2,
    TMViewUpperRightHandle = 3,
    TMViewMiddleLeftHandle = 4,
    TMViewMiddleRightHandle = 5,
    TMViewLowerLeftHandle = 6,
    TMViewLowerMiddleHandle = 7,
    TMViewLowerRightHandle = 8,
};




@implementation TMView



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        _fillStyle = [[TMFillStyle alloc] init];
		_name = @"New view";
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_fillStyle = [decoder decodeObjectForKey:@"TMViewFillStyle"];
	_isSelected = [decoder decodeBoolForKey:@"TMViewIsSelected"];
	_name = [decoder decodeObjectForKey:@"TMViewName"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_fillStyle forKey:@"TMViewFillStyle"];
	[encoder encodeBool:_isSelected forKey:@"TMViewIsSelected"];
	[encoder encodeObject:_name forKey:@"TMViewName"];
}






- (void)drawRect:(NSRect)rect
{
    
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
	
	// Fill the background if there is a background color set.
	if ([_fillStyle fillFeature] && [_fillStyle fillColor] != nil)
	{
		[[_fillStyle fillColor] set];
		[path fill];
	}
	
	// Draw the outline if there is a border width and color set.
	if ([_fillStyle drawBorder])
	//if ([_fillStyle borderWidth] > 0.0 && [_fillStyle borderColor] != nil)
	{
		[[_fillStyle borderColor] set];
		[path setLineWidth:[_fillStyle borderWidth]];
		[path stroke];
	}
	
}






-(TMFillStyle*)fillStyle
{
	return _fillStyle;
}




-(void)setFillStyle:(TMFillStyle*)fillStyle
{
	_fillStyle = fillStyle;
}




-(BOOL)isSelected
{
	return _isSelected;
}



-(void)setIsSelected:(BOOL)selected
{
	if (selected != _isSelected)
	{
		_isSelected = selected;
	
		// Post a selection changed notification.
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:@"TMViewSelectionChanged" 
			object:self];
		
		[self setNeedsDisplay:YES];
	}
}




-(void)select
{
	[self setIsSelected:YES];
}


-(void)deselect
{
	[self setIsSelected:NO];
}





-(NSString*)name
{
	return _name;
}


-(void)setName:(NSString*)aString
{
	_name = aString;
}



-(void)drawSelectionInRect:(NSRect)rect
{	
	
	// Only draw selection if we are in interactive mode.
	if ([[self superview] respondsToSelector:@selector(isInteractive)] == NO)
		return;
	
	TMPage *superview = (TMPage*)[self superview];
	if ([superview isInteractive] == NO)
		return;
	
	
	
	NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	[currentContext saveGraphicsState];
	
	NSRect bounds = [self bounds];
	
	NSRect smallBounds = bounds;
	smallBounds.origin.x += 1.0;
	smallBounds.origin.y += 1.0;
	smallBounds.size.width -= 2.0;
	smallBounds.size.height -= 2.0;
	CGFloat origLineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:2.0];
	[[NSColor selectedControlColor] set];
	[NSBezierPath strokeRect:smallBounds];
	[NSBezierPath setDefaultLineWidth:origLineWidth];
	
	[self drawHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		(NSMinY(bounds)+TMHandleHalfWidth))];
	[self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), 
		(NSMinY(bounds)+TMHandleHalfWidth))];
	[self drawHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		(NSMinY(bounds)+TMHandleHalfWidth))];
	[self drawHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		NSMidY(bounds))];
	[self drawHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		NSMidY(bounds))];
	[self drawHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		(NSMaxY(bounds)-TMHandleHalfWidth))];
	[self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), 
		(NSMaxY(bounds)-TMHandleHalfWidth))];
	[self drawHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		(NSMaxY(bounds)-TMHandleHalfWidth))];
		
	[currentContext restoreGraphicsState];
	
}




- (void)drawHandleAtPoint:(NSPoint)pt
{
    NSRect handleBounds;
    handleBounds.origin.x = pt.x - TMHandleHalfWidth;
    handleBounds.origin.y = pt.y - TMHandleHalfWidth;
    handleBounds.size.width = TMHandleWidth;
    handleBounds.size.height = TMHandleWidth;
    handleBounds = [self centerScanRect:handleBounds];
    
    // Draw the shadow of the handle.
    //NSRect handleShadowBounds = NSOffsetRect(handleBounds, 1.0f, 1.0f);
    //[[NSColor controlDarkShadowColor] set];
    //NSRectFill(handleShadowBounds);

    // Draw the handle itself.
    [[NSColor knobColor] set];
    NSRectFill(handleBounds);
}





-(void)mouseDown:(NSEvent*)event
{
	
	// If we are not in interactive mode, do nothing.
	if ([[self superview] respondsToSelector:@selector(isInteractive)] == NO)
		return;
	
	TMPage *superview = (TMPage*)[self superview];
	if ([superview isInteractive] == NO)
		return;
	
	
	if ([event clickCount] > 1)
	{
		// Post a notification for the double click.
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TMViewDoubleClicked" object:self];
		
		if ([self viewHasInlineEditMode])
		{
			[self startEditing];
			return;
		}
	}
	
	
	// Getting the mouse location.
	NSPoint mouseLocation = 
		[self convertPoint:[event locationInWindow] fromView:nil];
	
	
	// Are we changing the existing selection instead of setting a new one ?
	// (using the shift key)
	BOOL modifyingExistingSelection = NO;
	if ([event modifierFlags] & NSShiftKeyMask)
		modifyingExistingSelection = YES;


	// Has the user clicked on a handle ? If so, let resize the view.
	if ([self isSelected])
	{
		NSInteger handle = [self handleUnderPoint:mouseLocation];
		if (handle != TMViewNoHandle)
		{
			// The user clicked on a handle. Let the user drag it around.
			[self resizeViewUsingHandle:handle withEvent:event];
			return;
		}
	}



	// The user clicked on the view's contents.
	// If we are modifiying the existing selection, inverse the selection.
	if (modifyingExistingSelection)
	{
		[self setIsSelected:(![self isSelected])];
		[self setNeedsDisplay:YES];
		return;
	}


	// If the graphic wasn't selected before then it is now, 
	// and none of the rest are.
	if ([self isSelected] == NO)
	{
		NSArray *allViews = [[self superview] subviews];
		for (NSView *subview in allViews)
		{
			if (subview != self)
			{
				if ([subview respondsToSelector:@selector(deselect)])
					[subview performSelector:@selector(deselect)];
			}
		}
		
		[self select];
		[superview displayNow];
	}



	// If the view is selected, we let the user move around all
	// the selected objects.
	if ([self isSelected])
	{
		[self moveSelectedViewsWithEvent:event];
	}


}





-(NSInteger)handleUnderPoint:(NSPoint)point
{
	// Check handles at the corners and on the sides.
    NSRect bounds = [self bounds];
	
    if ([self isHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		(NSMinY(bounds)+TMHandleHalfWidth)) underPoint:point])
	{
		return TMViewUpperLeftHandle;
    }
	else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), 
		(NSMinY(bounds)+TMHandleHalfWidth)) underPoint:point]) 
	{
		return TMViewUpperMiddleHandle;
    }
	else if ([self isHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		(NSMinY(bounds)+TMHandleHalfWidth)) underPoint:point])
	{
		return TMViewUpperRightHandle;
    }
	else if ([self isHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		NSMidY(bounds)) underPoint:point])
	{
		return TMViewMiddleLeftHandle;
    }
	else if ([self isHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		NSMidY(bounds)) underPoint:point])
	{
		return TMViewMiddleRightHandle;
    }
	else if ([self isHandleAtPoint:NSMakePoint((NSMinX(bounds)+TMHandleHalfWidth), 
		(NSMaxY(bounds)-TMHandleHalfWidth)) underPoint:point])
	{
		return TMViewLowerLeftHandle;
    } 
	else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), 
		(NSMaxY(bounds)-TMHandleHalfWidth)) underPoint:point])
	{
		return TMViewLowerMiddleHandle;
    } 
	else if ([self isHandleAtPoint:NSMakePoint((NSMaxX(bounds)-TMHandleHalfWidth), 
		(NSMaxY(bounds)-TMHandleHalfWidth)) underPoint:point])
	{
		return TMViewLowerRightHandle;
    }
	
    return TMViewNoHandle;
	
}





-(BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point
{
    // Check a handle-sized rectangle that's centered on the handle point.
    NSRect handleBounds;
    handleBounds.origin.x = handlePoint.x - TMHandleHalfWidth;
    handleBounds.origin.y = handlePoint.y - TMHandleHalfWidth;
    handleBounds.size.width = TMHandleWidth;
    handleBounds.size.height = TMHandleWidth;
    return NSPointInRect(point, handleBounds);
}






-(void)resizeViewUsingHandle:(NSInteger)handle withEvent:(NSEvent*)event
{

    while ([event type] != NSLeftMouseUp)
	{
		event = [[self window] 
			nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
			
		[self autoscroll:event];
		
        NSPoint handleLocation = 
			[self convertPoint:[event locationInWindow] fromView:nil];
			
		// We could insert some snapping here.
		
        handle = [self resizeByMovingHandle:handle toPoint:handleLocation];
    }
	
}






-(NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point
{
	
	// Start with the original bounds.
    NSRect bounds = [self bounds];

    // Is the user changing the width of the graphic?
    if (handle == TMViewUpperLeftHandle || 
		handle == TMViewMiddleLeftHandle || 
		handle == TMViewLowerLeftHandle)
	{
		// Change the left edge of the graphic.
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
    } 
	else if (handle == TMViewUpperRightHandle || 
			 handle == TMViewMiddleRightHandle || 
			 handle == TMViewLowerRightHandle)
	{
		// Change the right edge of the graphic.
        bounds.size.width = point.x - bounds.origin.x;
    }

    // Did the user actually flip the graphic over?
    if (bounds.size.width < 0.0f)
	{

		// The handle is now playing a different role relative to the graphic.
		static NSInteger flippings[9];
		static BOOL flippingsInitialized = NO;
		if (!flippingsInitialized)
		{
			flippings[TMViewUpperLeftHandle] = TMViewUpperRightHandle;
			flippings[TMViewUpperMiddleHandle] = TMViewUpperMiddleHandle;
			flippings[TMViewUpperRightHandle] = TMViewUpperLeftHandle;
			flippings[TMViewMiddleLeftHandle] = TMViewMiddleRightHandle;
			flippings[TMViewMiddleRightHandle] = TMViewMiddleLeftHandle;
			flippings[TMViewLowerLeftHandle] = TMViewLowerRightHandle;
			flippings[TMViewLowerMiddleHandle] = TMViewLowerMiddleHandle;
			flippings[TMViewLowerRightHandle] = TMViewLowerLeftHandle;
			flippingsInitialized = YES;
		}
        handle = flippings[handle];

		// Make the graphic's width positive again.
        bounds.size.width = 0.0f - bounds.size.width;
        bounds.origin.x -= bounds.size.width;
    }
    
	
    // Is the user changing the height of the graphic?
    if (handle == TMViewUpperLeftHandle || 
		handle == TMViewUpperMiddleHandle || 
		handle == TMViewUpperRightHandle)
	{
		// Change the top edge of the graphic.
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
    } 
	else if (handle == TMViewLowerLeftHandle || 
			 handle == TMViewLowerMiddleHandle || 
			 handle == TMViewLowerRightHandle)
	{
		// Change the bottom edge of the graphic.
		bounds.size.height = point.y - bounds.origin.y;
    }

    // Did the user actually flip the graphic upside down?
    if (bounds.size.height < 0.0f)
	{
		// The handle is now playing a different role relative to the graphic.
		static NSInteger flippings[9];
		static BOOL flippingsInitialized = NO;
		if (!flippingsInitialized)
		{
			flippings[TMViewUpperLeftHandle] = TMViewLowerLeftHandle;
			flippings[TMViewUpperMiddleHandle] = TMViewLowerMiddleHandle;
			flippings[TMViewUpperRightHandle] = TMViewLowerRightHandle;
			flippings[TMViewMiddleLeftHandle] = TMViewMiddleLeftHandle;
			flippings[TMViewMiddleRightHandle] = TMViewMiddleRightHandle;
			flippings[TMViewLowerLeftHandle] = TMViewUpperLeftHandle;
			flippings[TMViewLowerMiddleHandle] = TMViewUpperMiddleHandle;
			flippings[TMViewLowerRightHandle] = TMViewUpperRightHandle;
			flippingsInitialized = YES;
		}
        handle = flippings[handle];
	
		// Make the graphic's height positive again.
        bounds.size.height = 0.0f - bounds.size.height;
        bounds.origin.y -= bounds.size.height;
    }

    // Done.
    [self setFrame:[self convertRect:bounds toView:[self superview]]];
    return handle;

}





-(void)moveSelectedViewsWithEvent:(NSEvent*)event
{

	if ([[self superview] respondsToSelector:@selector(selectedViews)] == NO)
		return;
	

    TMPage *page = (TMPage*)[self superview];

	// Get the selected views.
	NSArray *selViews = [page selectedViews];

    
	// Store the last point.
	NSPoint lastPoint = 
		[[self superview] convertPoint:[event locationInWindow] fromView:nil];


	BOOL isMoving = NO;
    while ([event type] != NSLeftMouseUp)
	{
        event = [[self window] nextEventMatchingMask:
			(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
			
		[self autoscroll:event];
		
        NSPoint curPoint = [[self superview] 
			convertPoint:[event locationInWindow] fromView:nil];
			
        if (isMoving == NO && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || 
							   (fabs(curPoint.y - lastPoint.y) >= 2.0)))
		{
            isMoving = YES;
        }
		
        if (isMoving)
		{
            if (NSEqualPoints(lastPoint, curPoint) == NO)
			{
				for (NSView *view in selViews)
				{
					[view setFrame:NSOffsetRect([view frame], 
						(curPoint.x - lastPoint.x), 
						(curPoint.y - lastPoint.y))];
				}
            }

            lastPoint = curPoint;
			
        }
    }

    if (isMoving)
		[page displayNow];

}






-(NSRect)frameForViews:(NSArray*)views
{
	// The frame of an array of views is the union of all of their frames.
	NSRect frame = NSZeroRect;
	
    NSUInteger nviews = [views count];
	if (nviews > 0)
	{
		frame = [[views objectAtIndex:0] frame];
		NSUInteger viewcnt;
		for (viewcnt = 1; viewcnt < nviews; viewcnt++)
		{
			frame = NSUnionRect(frame, [[views objectAtIndex:viewcnt] frame]);
		}
	}
	
    return frame;
}




-(BOOL)viewHasInlineEditMode
{
	return NO;
}



-(void)startEditing
{
}


-(void)endEditing
{
}


@end
