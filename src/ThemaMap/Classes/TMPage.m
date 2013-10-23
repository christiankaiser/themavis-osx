//
//  TMPage.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMPage.h"

#import "TMView.h"



@implementation TMPage



+(NSInteger)pixelsToMillimeters:(NSInteger)pixels
{
	NSInteger millimeters = pixels / 2.83465;
	return millimeters;
}



+(NSInteger)millimetersToPixels:(NSInteger)millimeters
{
	NSInteger pixels = millimeters * 2.83465;
	return pixels;
}



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
	
		// Set the default page size to A4 landscape.
		_unit = TMPixels;
		[self setPageWidth:841];
		[self setPageHeight:595];

		[self setBoundsOrigin:NSMakePoint(-20, -20)];
		
		_drawPageOutline = YES;
		_isInteractive = YES;		// Page is not interactive by default.
		
		_needsDisplay = NO;
		_displayUpdateInterval = 4.0f;
		
		_displayTimer = 
			[NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
				target:self 
				selector:@selector(displayNow) 
				userInfo:nil 
				repeats:YES];
		
    }
    return self;
}







-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	
	_unit = [decoder decodeIntForKey:@"TMPageUnit"];
	
	_pageWidth = [decoder decodeIntegerForKey:@"TMPageWidth"];
	_pageHeight = [decoder decodeIntegerForKey:@"TMPageHeight"];
	
	_drawPageOutline = [decoder decodeBoolForKey:@"TMPageDrawPageOutline"];
	_isInteractive = [decoder decodeBoolForKey:@"TMPageIsInteractive"];
	
	_displayUpdateInterval = (NSTimeInterval)[decoder decodeDoubleForKey:@"TMPageDisplayUpdateInterval"];
	
	
	[self setBoundsOrigin:NSMakePoint(-20, -20)];
	_needsDisplay = NO;
	
	_displayTimer = [NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
													 target:self 
												   selector:@selector(displayNow) 
												   userInfo:nil 
													repeats:YES];
	
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodeInt:_unit forKey:@"TMPageUnit"];
	
	[encoder encodeInteger:_pageWidth forKey:@"TMPageWidth"];
	[encoder encodeInteger:_pageHeight forKey:@"TMPageHeight"];
	
	[encoder encodeBool:_drawPageOutline forKey:@"TMPageDrawPageOutline"];
	[encoder encodeBool:_isInteractive forKey:@"TMPageIsInteractive"];
	
	[encoder encodeDouble:(double)_displayUpdateInterval forKey:@"TMPageDisplayUpdateInterval"];

}









- (void)drawRect:(NSRect)rect
{
    
	// Draw the page outline.
	if (_drawPageOutline)
	{
		NSRect pageRect;
		pageRect.origin.x = 0;
		pageRect.origin.y = 0;
		pageRect.size.width = (CGFloat)_pageWidth;
		pageRect.size.height = (CGFloat)_pageHeight;

		// Make a shadow effect
		NSShadow *dropShadow = [[NSShadow alloc] init];
		[dropShadow setShadowColor:[NSColor grayColor]];
		[dropShadow setShadowBlurRadius:7];
		[dropShadow setShadowOffset:NSMakeSize(5,-5)];

		// Save graphics state
		[NSGraphicsContext saveGraphicsState];

		[dropShadow set];
	
		[[NSColor whiteColor] set];
		[NSBezierPath fillRect:pageRect];
	
		// Restore state
		[NSGraphicsContext restoreGraphicsState];
		
		// Draw the border
		[[NSColor grayColor] set];
		[NSBezierPath strokeRect:pageRect];
		
	}
	
}





-(NSUInteger)pageWidth
{
	if (_unit == TMMillimeters)
		return [TMPage pixelsToMillimeters:_pageWidth];

	return _pageWidth;
}



-(void)setPageWidth:(NSUInteger)pageWidth
{
	if (_unit == TMMillimeters)
		_pageWidth = [TMPage millimetersToPixels:pageWidth];
	else
		_pageWidth = pageWidth;
	
	NSRect frame = [self frame];
	[self setFrameSize:NSMakeSize((_pageWidth+40), frame.size.height)];
	
}



-(NSUInteger)pageHeight
{
	if (_unit == TMMillimeters)
		return [TMPage pixelsToMillimeters:_pageHeight];

	return _pageHeight;
}



-(void)setPageHeight:(NSUInteger)pageHeight
{
	if (_unit == TMMillimeters)
		_pageHeight = [TMPage millimetersToPixels:pageHeight];
	else
		_pageHeight = pageHeight;
	
	NSRect frame = [self frame];
	[self setFrameSize:NSMakeSize(frame.size.width, (_pageHeight+40))];
}



-(TMUnit)unit
{
	return _unit;
}



-(void)setUnit:(TMUnit)unit
{
	_unit = unit;
}





-(BOOL)isInteractive
{
	return _isInteractive;
}



-(void)setIsInteractive:(BOOL)interactive
{
	_isInteractive = interactive;
}




-(void)zoomToActualSize
{
	[self setBounds:[self frame]];
}



-(void)zoomToAll
{
	NSRect zoomRect = 
		NSMakeRect(-20, -20, (_pageWidth + 40), (_pageHeight + 40));
	
	[self zoomToRect:zoomRect];
}



-(void)zoomToRect:(NSRect)rect
{
	// Adapt the zoom rect to the view's shape.
	NSRect zoomRect = rect;
	
	NSRect frame = [self frame];
	
	double frameWidthHeightRatio = frame.size.width / frame.size.height;
	double zoomWidthHeightRatio = zoomRect.size.width / zoomRect.size.width;
	
	if (zoomWidthHeightRatio > frameWidthHeightRatio)
	{
		// Adapt the height.
		double newHeight = zoomRect.size.width / frameWidthHeightRatio;
		double heightDiff = (newHeight - zoomRect.size.height) / 2;
		zoomRect.origin.y -= heightDiff;
		zoomRect.size.height = newHeight;
	}
	else
	{
		// Adapt the width.
		double newWidth = zoomRect.size.height * frameWidthHeightRatio;
		double widthDiff = (newWidth - zoomRect.size.width) / 2;
		zoomRect.origin.x -= widthDiff;
		zoomRect.size.width = newWidth;
	}
	
	[self setBounds:zoomRect];
}





#pragma mark --- Drawing the page ---

-(void)setNeedsDisplay:(BOOL)flag
{
	_needsDisplay = flag;
	
	// The following option is for updating in real time.
	// For big maps, this should be desactivated.
	[self displayNow];
}


-(void)displayNow
{
	if (_needsDisplay)
		[super setNeedsDisplay:YES];
	
	_needsDisplay = NO;
}


-(NSTimeInterval)displayUpdateInterval
{
	return _displayUpdateInterval;
}


-(void)setDisplayUpdateInterval:(NSTimeInterval)seconds
{
	_displayUpdateInterval = seconds;
	
	[_displayTimer invalidate];
	
	_displayTimer = 
		[NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
			target:self 
			selector:@selector(displayNow) 
			userInfo:nil 
			repeats:YES];
}



#pragma mark --- Event Handling ---

-(void)mouseDown:(NSEvent*)theEvent
{
	if (_isInteractive == NO)
		return;
	
	// Cycle through all subviews in order to deselect them.
	BOOL selectionChanged = NO;
	NSArray *subviews = [self subviews];
	for (NSView *sview in subviews)
	{
		if ([sview respondsToSelector:@selector(deselect)])
			[sview performSelector:@selector(deselect)];
		
		selectionChanged = YES;
	}
	
	if (selectionChanged)
		[self displayNow];
	
}




-(NSArray*)selectedViews
{
	NSMutableArray *sel = [NSMutableArray arrayWithCapacity:1];
	//NSArray *subviews = [self subviews];
	
	for (NSView *view in _subviews)
	{
		if ([view respondsToSelector:@selector(isSelected)])
		{
			if ([(TMView*)view isSelected] == YES)
				[sel addObject:view];
		}
	}
	
	return [NSArray arrayWithArray:sel];
}





-(void)exportToPDF:(NSString*)path
{
	BOOL drawPageOutlineBackup = _drawPageOutline;
	_drawPageOutline = NO;
	
	BOOL pageIsInteractiveBackup = _isInteractive;
	_isInteractive = NO;
	
	NSRect rect = NSMakeRect(0, 0, _pageWidth, _pageHeight);
	NSRect boundsBackup = [self bounds];
	NSRect frameBackup = [self frame];
	[self setFrame:rect];
	[self zoomToRect:rect];
	
	NSData *data = [self dataWithPDFInsideRect:rect];
	[data writeToFile:[path stringByStandardizingPath] atomically:YES];
	
	_drawPageOutline = drawPageOutlineBackup;
	[self setFrame:frameBackup];
	[self zoomToRect:boundsBackup];
	_isInteractive = pageIsInteractiveBackup;
	
}



-(BOOL)acceptsFirstResponder
{
	return YES;
}


-(void)keyDown:(NSEvent*)event
{
	NSString *s = [event characters];
	unsigned short c = [s characterAtIndex:0];
	
	// Delete backward ?
	if (c == 127)
		[self deleteBackward:self];
}


-(void)deleteBackward:(id)sender
{	
	// Remove the selected views.
	NSArray *selViews = [self selectedViews];
	NSArray *selViewsCopy = [selViews copy];
	for (NSView *view in selViewsCopy)
	{
		[view removeFromSuperview];
	}
}





@end
