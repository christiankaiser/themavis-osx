//
//  TMAppDelegate.m
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMAppDelegate.h"

#import "TMClassificationPanelController.h"
#import "TMColorTablePanelController.h"
#import "TMDocument.h"
#import "TMLayerPanelController.h"
#import "TMViewPanelController.h"



#pragma mark *** NSWindowController Conveniences ***

@interface NSWindowController(TMConvenience)
- (BOOL)isWindowShown;
- (void)showOrHideWindow;
@end

@implementation NSWindowController(TMConvenience)

-(BOOL)isWindowShown
{
    return [[self window] isVisible];
}


-(void)showOrHideWindow
{
    NSWindow *window = [self window];
    if ([window isVisible])
		[window orderOut:self];
    else
		[self showWindow:self];
}

@end




@implementation TMAppDelegate



-(IBAction)showOrHideLayerPanel:(id)sender
{
    // We always show the same layers panel. Its controller doesn't 
	// get deallocated when the user closes it.
    [[TMLayerPanelController sharedLayerPanelController] 
		showOrHideWindow];
}

-(IBAction)showLayerPanel:(id)sender
{
	// Get the current document. The document window will be used as parent for the
	// layer sheet.
	//TMDocument *doc = [[[NSDocumentController sharedDocumentController] orderedDocuments] objectAtIndex:0];
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	
	if (doc == nil) 
	{
		NSLog(@"Cannot find current document.");
		return;
	}
	
	// Show the layer sheet.
	[doc showLayerPanel];
}




-(IBAction)showOrHideClassificationPanel:(id)sender
{
    // We always show the same classification panel. Its controller doesn't 
	// get deallocated when the user closes it.
    [[TMClassificationPanelController sharedClassificationPanelController] 
		showOrHideWindow];
}



-(IBAction)showOrHideColorTablePanel:(id)sender
{
    // We always show the same color table panel. Its controller doesn't 
	// get deallocated when the user closes it.
    [[TMColorTablePanelController sharedColorTablePanelController] 
		showOrHideWindow];
}




-(IBAction)showOrHideShellPanel:(id)sender
{
	// For each document, we have a separate shell panel.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[doc showOrHideShellPanel:sender];
}


-(IBAction)showOrHideCommandLogPanel:(id)sender
{
	// For each document, we have a separate command log panel.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[doc showOrHideCommandLogPanel:sender];
}


-(IBAction)showOrHideViewPanel:(id)sender
{
	//[[TMViewPanelController sharedViewPanelController] showOrHideWindow];
}


-(IBAction)showViewPanel:(id)sender
{
	// Get the current document. The document window will be used as parent for the
	// layer sheet.
	//TMDocument *doc = [[[NSDocumentController sharedDocumentController] orderedDocuments] objectAtIndex:0];
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	
	if (doc == nil)
	{
		NSLog(@"Cannot find current document.");
		TMDisplayError(@"Error. Cannot find the current document.", @"");
	}
	
	
	// Show the layer sheet.
	[doc showViewPanel];
}






// Conformance to the NSObject(NSMenuValidation) informal protocol.
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{

    // A few menu item's names change between starting with "Show" and "Hide".
    SEL action = [menuItem action];
	
    if (action == @selector(showOrHideClassificationPanel:))
	{
		NSString *menuTitle;
		if ([[TMClassificationPanelController 
				sharedClassificationPanelController] isWindowShown])
		{
			menuTitle = NSLocalizedStringFromTable(@"Hide Classifications",
				@"TMAppDelegate", @"A main menu item title.");
		}
		else
		{
			menuTitle = NSLocalizedStringFromTable(@"Show Classifications",
				@"TMAppDelegate", @"A main menu item title.");
		}
	
		[menuItem setTitle:menuTitle];

    }
	
	else if (action == @selector(showOrHideLayerPanel:))
	{
		NSString *menuTitle;
		if ([[TMLayerPanelController 
				sharedLayerPanelController] isWindowShown])
		{
			menuTitle = NSLocalizedStringFromTable(@"Hide Layers",
				@"TMAppDelegate", @"A main menu item title.");
		}
		else
		{
			menuTitle = NSLocalizedStringFromTable(@"Show Layers",
				@"TMAppDelegate", @"A main menu item title.");
		}
	
		[menuItem setTitle:menuTitle];

    }
	
	else if (action == @selector(showOrHideColorTablePanel:))
	{
		NSString *menuTitle;
		if ([[TMColorTablePanelController 
				sharedColorTablePanelController] isWindowShown])
		{
			menuTitle = NSLocalizedStringFromTable(@"Hide Color Tables",
				@"TMAppDelegate", @"A main menu item title.");
		}
		else
		{
			menuTitle = NSLocalizedStringFromTable(@"Show Color Tables",
				@"TMAppDelegate", @"A main menu item title.");
		}
	
		[menuItem setTitle:menuTitle];

    }
	
	else if (action == @selector(showOrHideShellPanel:))
	{
		NSString *menuTitle;
		TMDocument *doc = [[NSDocumentController sharedDocumentController]
								currentDocument];
		
		if ([doc shellIsVisible])
		{
			menuTitle = NSLocalizedStringFromTable(@"Hide Shell",
				@"TMAppDelegate", @"A main menu item title.");
		}
		else
		{
			menuTitle = NSLocalizedStringFromTable(@"Show Shell",
				@"TMAppDelegate", @"A main menu item title.");
		}
	
		[menuItem setTitle:menuTitle];

    }
	
	/*else if (action == @selector(showOrHideViewPanel:))
	{
		NSString *menuTitle;
		if ([[TMViewPanelController sharedViewPanelController] isWindowShown])
		{
			menuTitle = NSLocalizedStringFromTable(@"Hide view settings",
				@"TMAppDelegate", @"A main menu item title.");
		}
		else
		{
			menuTitle = NSLocalizedStringFromTable(@"Show view settings",
				@"TMAppDelegate", @"A main menu item title.");
		}
	
		[menuItem setTitle:menuTitle];

    }*/
	
    return YES;

}





-(IBAction)insertMapView:(id)sender
{
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [doc page];
	NSRect pageBounds = [page bounds];
	CGFloat frameX = pageBounds.origin.x + (pageBounds.size.width / 2) - 200;
	CGFloat frameY = pageBounds.origin.y + (pageBounds.size.height / 2) - 150;
	NSRect frame = NSMakeRect(frameX, frameY, 400, 300);
	TMMapView *map = [[TMMapView alloc] initWithFrame:frame];
	[map setIsSelected:YES];
	[page addSubview:map];
	
	[doc updateChangeCount:NSChangeDone];
}





-(IBAction)insertLegendView:(id)sender
{
}





-(IBAction)insertTextView:(id)sender
{
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [doc page];
	NSRect pageBounds = [page bounds];
	CGFloat frameX = pageBounds.origin.x + (pageBounds.size.width / 2) - 100;
	CGFloat frameY = pageBounds.origin.y + (pageBounds.size.height / 2) - 20;
	NSRect frame = NSMakeRect(frameX, frameY, 200, 40);
	TMTextView *text = [[TMTextView alloc] initWithFrame:frame];
	[page addSubview:text];
	
	[doc updateChangeCount:NSChangeDone];
}





-(IBAction)showPagePropertiesPanel:(id)sender
{
	// Get the selected text view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[doc showPagePropertiesPanel:self];
}



-(IBAction)exportToPDF:(id)sender
{
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[doc exportToPDF:self];
}




@end
