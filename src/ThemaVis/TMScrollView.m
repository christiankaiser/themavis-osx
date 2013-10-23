//
//  TMScrollView.m
//  ThemaVis
//
//  Created by Christian on 02.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMScrollView.h"


static NSString * const zoomLabels[] = {@"10%", @"25%", @"50%", @"75%", @"100%",
	@"125%", @"150%", @"200%", @"400%", @"800%", @"1600%"};
	
static const CGFloat zoomFactors[] = 
	{0.1f, 0.25f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 2.0f, 4.0f, 8.0f, 16.0f};
	
static const NSInteger zoomItemCount = sizeof(zoomLabels) / sizeof(NSString*);




@implementation TMScrollView



-(IBAction)setFactorAction:(id)sender
{
	NSNumber *factor = [sender representedObject];
	[self setFactor:[factor floatValue]];
}



-(CGFloat)factor
{
	return _factor;
}


-(void)setFactor:(CGFloat)factor
{
	NSView *clipView = [[self documentView] superview];
    NSSize clipViewFrameSize = [clipView frame].size;
	
    [clipView setBoundsSize:NSMakeSize((clipViewFrameSize.width / factor), 
		(clipViewFrameSize.height / factor))];
	
	_factor = factor;
}



/**
 * An override of the NSScrollView method.
 * Needed for the popup button next to the horizontal scroll bar.
 */
-(void)tile
{

	[super tile];

	if ([self hasVerticalScroller] == NO)
		return;


    // Do NSScrollView's regular tiling, and find out where it left the 
	// horizontal scroller.
    NSScroller *horizontalScroller = [self horizontalScroller];
    NSRect horizontalScrollerFrame = [horizontalScroller frame];

    // Place the zoom factor popup button to the left of where the horizontal 
	// scroller will go, creating it first if necessary, and leaving its 
	// width alone.
    [self validateFactorPopUpButton];
    NSRect factorPopUpButtonFrame = [_factorPopUpButton frame];
    factorPopUpButtonFrame.origin.x = horizontalScrollerFrame.origin.x;
    factorPopUpButtonFrame.origin.y = horizontalScrollerFrame.origin.y;
    factorPopUpButtonFrame.size.height = horizontalScrollerFrame.size.height;
    [_factorPopUpButton setFrame:factorPopUpButtonFrame];

    // Adjust the scroller's frame to make room for the zoom factor 
	// popup button next to it.
    horizontalScrollerFrame.origin.x += factorPopUpButtonFrame.size.width;
    horizontalScrollerFrame.size.width -= factorPopUpButtonFrame.size.width;
    [horizontalScroller setFrame:horizontalScrollerFrame];
    
}






-(void)validateFactorPopUpButton
{

    // Ignore redundant invocations.
    if (_factorPopUpButton == nil)
	{
		_factor = 1.0;
		
		// Create the popup button and configure its appearance. 
		// The initial size doesn't matter.
        _factorPopUpButton = [[NSPopUpButton alloc] 
			initWithFrame:NSZeroRect pullsDown:NO];
			
		NSPopUpButtonCell *factorPopUpButtonCell = [_factorPopUpButton cell];
        [factorPopUpButtonCell setArrowPosition:NSPopUpArrowAtBottom];
        [factorPopUpButtonCell setBezelStyle:NSShadowlessSquareBezelStyle];
        [_factorPopUpButton setFont:[NSFont systemFontOfSize:
			[NSFont smallSystemFontSize]]];

        // Populate it and size it to fit the just-added menu item cells.
		NSInteger index;
		for (index = 0; index < zoomItemCount; index++) 
		{
            [_factorPopUpButton addItemWithTitle:zoomLabels[index]];
			
			[[_factorPopUpButton lastItem] setRepresentedObject:
				[NSNumber numberWithDouble:zoomFactors[index]]];
					
			[[_factorPopUpButton lastItem] setTarget:self];
			[[_factorPopUpButton lastItem] 
				setAction:@selector(setFactorAction:)];
			
			if (zoomFactors[index] == _factor)
				[_factorPopUpButton selectItem:[_factorPopUpButton lastItem]];
				
		}

		[_factorPopUpButton sizeToFit];

        [self addSubview:_factorPopUpButton];
    }

}






@end
