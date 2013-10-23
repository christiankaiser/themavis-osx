//
//  TMViewPanelController.m
//  ThemaVis
//
//  Created by Christian on 03.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMViewPanelController.h"
#import "TMDocument.h"
#import "TMUtilities.h"



@implementation TMViewPanelController



/*+(id)sharedViewPanelController
{
    static TMViewPanelController *
		sharedViewPanelController = nil;


    if (!sharedViewPanelController)
	{
        sharedViewPanelController = 
			[[TMViewPanelController allocWithZone:NULL] init];
    }

    return sharedViewPanelController;
}*/



-(id)init
{
    self = [self initWithWindowNibName:@"ViewPanel"];
	
    if (self)
	{
        [self setWindowFrameAutosaveName:@"ViewPanel"];
		
		/*[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(viewSelectionChanged:) 
			name:@"TMViewSelectionChanged"
			object:nil];*/
    }
    return self;
}





#pragma mark --- Table View Data Source ---

// Get the number of rows for the table views of the view panel.
-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	if (tableView == _viewList)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		NSInteger nviews = [[[doc page] subviews] count];
		return nviews;
	}
	else if (tableView == _mapViewLayerList)
	{
		// Get the selected map view.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		NSInteger selectedView = [_viewList selectedRow];
		NSInteger nviews = [[[doc page] subviews] count];
		if (nviews <= selectedView) return 0;
		if (selectedView < 0) return 0;
		TMMapView *v = [[[doc page] subviews] objectAtIndex:selectedView];
		NSInteger nlayers = [[v layers] count];
		return nlayers;
	}
	
	return 0;
}


// Get the content for the specified cell in one of the table views of the view panel.
-(id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (tableView == _viewList)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMView *v = [[[doc page] subviews] objectAtIndex:rowIndex];
		NSString *vclass = [v className];
		if ([vclass compare:@"TMMapView"] == NSOrderedSame) vclass = @"map";
		else if ([vclass compare:@"TMTextView"] == NSOrderedSame) vclass = @"text";
		else if ([vclass compare:@"TMLegendView"] == NSOrderedSame) vclass = @"legend";
		else if ([vclass compare:@"TMScaleView"] == NSOrderedSame) vclass = @"scale";
		return [NSString stringWithFormat:@"%@ [%@]", [v name], vclass];
	}
	else if (tableView == _mapViewLayerList)
	{
		// Get the selected map view.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		TMLayer *l = [v objectInLayersAtIndex:rowIndex];
		return [l name];
	}
	
	return nil;
}



-(void)tableViewSelectionDidChange:(NSNotification*)aNotification
{
	
	NSTableView *changedTableView = (NSTableView*)[aNotification object];
	
	if (changedTableView == _viewList)
	{
		NSIndexSet *selectedRows = [_viewList selectedRowIndexes];
		NSInteger nSelectedRows = [selectedRows count];
		
		if (nSelectedRows == 0)
		{
			[self updateViewDataWithNoSelection];
			return;
		}
		
		if (nSelectedRows > 1)
		{
			[self updateViewDataWithMultipleSelection];
			return;
		}
		
		// Get the selected view.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];

		// Update the data using the view.
		[self updateViewDataWithView:v];
	}
	else if (changedTableView == _mapViewLayerList)
	{
		NSIndexSet *selectedRows = [_mapViewLayerList selectedRowIndexes];
		NSInteger nSelectedRows = [selectedRows count];
		
		if (nSelectedRows == 0)
		{
			[self updateLayerListWithNoSelection];
			return;
		}
		
		if (nSelectedRows > 1)
		{
			[self updateLayerListWithMultipleSelection];
			return;
		}
		
		// Get the selected layer.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		TMLayer *l = [v objectInLayersAtIndex:[_mapViewLayerList selectedRow]];
		
		// Update the data using the layer.
		[self updateLayerListWithLayer:l];
	}

}



#pragma mark --- Update the view data content ---

-(void)updateViewDataWithNoSelection
{
	[_viewNameLabel setTextColor:[NSColor grayColor]];
	[_viewNameField setStringValue:@"No selection"];
	[_viewNameField setTextColor:[NSColor grayColor]];
	[_viewNameField setSelectable:NO];
	
	[_viewCoordsTopLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsTopField setStringValue:@""];
	[_viewCoordsTopField setTextColor:[NSColor grayColor]];
	[_viewCoordsTopField setSelectable:NO];
	
	[_viewCoordsBottomLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsBottomField setStringValue:@""];
	[_viewCoordsBottomField setTextColor:[NSColor grayColor]];
	[_viewCoordsBottomField setSelectable:NO];
	
	[_viewCoordsLeftLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsLeftField setStringValue:@""];
	[_viewCoordsLeftField setTextColor:[NSColor grayColor]];
	[_viewCoordsLeftField setSelectable:NO];
	
	[_viewCoordsRightLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsRightField setStringValue:@""];
	[_viewCoordsRightField setTextColor:[NSColor grayColor]];
	[_viewCoordsRightField setSelectable:NO];
	
	[_viewPropertiesButton setEnabled:NO];
	
	
	[_viewStyleDrawContourButton setEnabled:NO];
	[_viewStyleDrawContourLineWidthLabel setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineWidthField setSelectable:NO];
	[_viewStyleDrawContourLineWidthField setStringValue:@""];
	[_viewStyleDrawContourLineWidthField setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineColorLabel setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineColorWell setEnabled:NO];
	
	[_viewStyleFillBackgroundButton setEnabled:NO];
	[_viewStyleFillBackgroundColorLabel setTextColor:[NSColor grayColor]];
	[_viewStyleFillBackgroundColorWell setEnabled:NO];
	
	
	
	[_removeViewButton setEnabled:NO];
	[_moveViewUpButton setEnabled:NO];
	[_moveViewDownButton setEnabled:NO];
	
}






-(void)updateViewDataWithMultipleSelection
{
	[_viewNameLabel setTextColor:[NSColor grayColor]];
	[_viewNameField setStringValue:@"Multiple selection"];
	[_viewNameField setTextColor:[NSColor grayColor]];
	[_viewNameField setSelectable:NO];
	
	[_viewCoordsTopLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsTopField setStringValue:@""];
	[_viewCoordsTopField setTextColor:[NSColor grayColor]];
	[_viewCoordsTopField setSelectable:NO];
	
	[_viewCoordsBottomLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsBottomField setStringValue:@""];
	[_viewCoordsBottomField setTextColor:[NSColor grayColor]];
	[_viewCoordsBottomField setSelectable:NO];
	
	[_viewCoordsLeftLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsLeftField setStringValue:@""];
	[_viewCoordsLeftField setTextColor:[NSColor grayColor]];
	[_viewCoordsLeftField setSelectable:NO];
	
	[_viewCoordsRightLabel setTextColor:[NSColor grayColor]];
	[_viewCoordsRightField setStringValue:@""];
	[_viewCoordsRightField setTextColor:[NSColor grayColor]];
	[_viewCoordsRightField setSelectable:NO];
	
	[_viewPropertiesButton setEnabled:NO];
	
	
	[_viewStyleDrawContourButton setEnabled:NO];
	[_viewStyleDrawContourLineWidthLabel setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineWidthField setSelectable:NO];
	[_viewStyleDrawContourLineWidthField setStringValue:@""];
	[_viewStyleDrawContourLineWidthField setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineColorLabel setTextColor:[NSColor grayColor]];
	[_viewStyleDrawContourLineColorWell setEnabled:NO];
	
	[_viewStyleFillBackgroundButton setEnabled:NO];
	[_viewStyleFillBackgroundColorLabel setTextColor:[NSColor grayColor]];
	[_viewStyleFillBackgroundColorWell setEnabled:NO];
	
	
	[_removeViewButton setEnabled:NO];
	[_moveViewUpButton setEnabled:NO];
	[_moveViewDownButton setEnabled:NO];
	
}



-(void)updateViewDataWithView:(TMView*)view
{
	
	// Enable the content fields
	
	[_viewNameLabel setTextColor:[NSColor blackColor]];
	[_viewNameField setStringValue:[view name]];
	[_viewNameField setTextColor:[NSColor blackColor]];
	[_viewNameField setEditable:YES];
	
	[_viewCoordsTopLabel setTextColor:[NSColor blackColor]];
	[_viewCoordsTopField setStringValue:[NSString stringWithFormat:@"%f", 
										 ([view frame].origin.y + [view frame].size.height)]];
	[_viewCoordsTopField setTextColor:[NSColor blackColor]];
	[_viewCoordsTopField setEditable:YES];
	
	[_viewCoordsBottomLabel setTextColor:[NSColor blackColor]];
	[_viewCoordsBottomField setStringValue:[NSString stringWithFormat:@"%f", ([view frame].origin.y)]];
	[_viewCoordsBottomField setTextColor:[NSColor blackColor]];
	[_viewCoordsBottomField setEditable:YES];
	
	[_viewCoordsLeftLabel setTextColor:[NSColor blackColor]];
	[_viewCoordsLeftField setStringValue:[NSString stringWithFormat:@"%f", ([view frame].origin.x)]];
	[_viewCoordsLeftField setTextColor:[NSColor blackColor]];
	[_viewCoordsLeftField setEditable:YES];
	
	[_viewCoordsRightLabel setTextColor:[NSColor blackColor]];
	[_viewCoordsRightField setStringValue:[NSString stringWithFormat:@"%f", 
										   ([view frame].origin.x + [view frame].size.width)]];
	[_viewCoordsRightField setTextColor:[NSColor blackColor]];
	[_viewCoordsRightField setEditable:YES];
	
	[_viewPropertiesButton setEnabled:YES];
	
	
	
	[_removeViewButton setEnabled:YES];
	[_moveViewUpButton setEnabled:YES];
	[_moveViewDownButton setEnabled:YES];
	
	
	
	
	// Setting the view's fill style
	
	TMFillStyle *vf = [view fillStyle];
	
	[_viewStyleDrawContourButton setEnabled:YES];
	[_viewStyleDrawContourButton setState:[vf drawBorder]];
	
	if ([vf drawBorder])
	{
		[_viewStyleDrawContourLineWidthLabel setTextColor:[NSColor blackColor]];
		[_viewStyleDrawContourLineWidthField setEditable:YES];
		[_viewStyleDrawContourLineWidthField setFloatValue:[vf borderWidth]];
		[_viewStyleDrawContourLineWidthField setTextColor:[NSColor blackColor]];
		[_viewStyleDrawContourLineColorLabel setTextColor:[NSColor blackColor]];
		[_viewStyleDrawContourLineColorWell setEnabled:YES];
		[_viewStyleDrawContourLineColorWell setColor:[vf borderColor]];
	}
	else
	{
		[_viewStyleDrawContourLineWidthLabel setTextColor:[NSColor grayColor]];
		[_viewStyleDrawContourLineWidthField setSelectable:NO];
		[_viewStyleDrawContourLineWidthField setStringValue:@""];
		[_viewStyleDrawContourLineWidthField setTextColor:[NSColor grayColor]];
		[_viewStyleDrawContourLineColorLabel setTextColor:[NSColor grayColor]];
		[_viewStyleDrawContourLineColorWell setEnabled:NO];
	}
	
	[_viewStyleFillBackgroundButton setEnabled:YES];
	[_viewStyleFillBackgroundButton setState:[vf fillFeature]];
	
	if ([vf fillFeature])
	{
		[_viewStyleFillBackgroundColorLabel setTextColor:[NSColor blackColor]];
		[_viewStyleFillBackgroundColorWell setEnabled:YES];
		[_viewStyleFillBackgroundColorWell setColor:[vf fillColor]];
	}
	else
	{
		[_viewStyleFillBackgroundColorLabel setTextColor:[NSColor grayColor]];
		[_viewStyleFillBackgroundColorWell setEnabled:NO];
	}
	
	
}










-(void)controlTextDidChange:(NSNotification*)aNotification
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Get the text field
	NSTextField *tf = [[[aNotification userInfo] objectForKey:@"NSFieldEditor"] delegate];
	if (tf  == _viewNameField)
	{
		[v setName:[_viewNameField stringValue]];
		[_viewList reloadData];
	}
	else if (tf  == _viewCoordsTopField)
	{
		NSInteger top = [_viewCoordsTopField integerValue];
		if (top > [v frame].origin.y)
		{
			[v setFrameSize:NSMakeSize([v frame].size.width, (top - [v frame].origin.y))];
			if (top > [[doc page] pageHeight])
				[_viewCoordsTopField setTextColor:[NSColor redColor]];
			else
				[_viewCoordsTopField setTextColor:[NSColor blackColor]];
		}
		else
		{
			[_viewCoordsTopField setTextColor:[NSColor redColor]];
		}
	}
	else if (tf  == _viewCoordsBottomField)
	{
		NSInteger bottom = [_viewCoordsBottomField integerValue];
		if (bottom < ([v frame].origin.y + [v frame].size.height))
		{
			[v setFrameSize:NSMakeSize([v frame].size.width, (([v frame].origin.y + [v frame].size.height) - bottom))];
			[v setFrameOrigin:NSMakePoint([v frame].origin.x, bottom)];
			if (bottom < 0 || bottom > [[doc page] pageHeight])
				[_viewCoordsBottomField setTextColor:[NSColor redColor]];
			else
				[_viewCoordsBottomField setTextColor:[NSColor blackColor]];
		}
		else
		{
			[_viewCoordsBottomField setTextColor:[NSColor redColor]];
		}
	}
	else if (tf  == _viewCoordsLeftField)
	{
		NSInteger left = [_viewCoordsLeftField integerValue];
		if (left < ([v frame].origin.x + [v frame].size.width))
		{
			[v setFrameSize:NSMakeSize((([v frame].origin.x + [v frame].size.width) - left), [v frame].size.height)];
			[v setFrameOrigin:NSMakePoint(left, [v frame].origin.y)];
			if (left < 0 || left > [[doc page] pageWidth])
				[_viewCoordsLeftField setTextColor:[NSColor redColor]];
			else
				[_viewCoordsLeftField setTextColor:[NSColor blackColor]];
		}
		else
		{
			[_viewCoordsLeftField setTextColor:[NSColor redColor]];
		}
	}
	else if (tf  == _viewCoordsRightField)
	{
		NSInteger right = [_viewCoordsRightField integerValue];
		if (right > [v frame].origin.x)
		{
			[v setFrameSize:NSMakeSize((right - [v frame].origin.x), [v frame].size.height)];
			if (right > [[doc page] pageWidth])
				[_viewCoordsRightField setTextColor:[NSColor redColor]];
			else
				[_viewCoordsRightField setTextColor:[NSColor blackColor]];
		}
		else
		{
			[_viewCoordsRightField setTextColor:[NSColor redColor]];
		}
	}
	
	else if (tf == _viewStyleDrawContourLineWidthField)
	{
		[[v fillStyle] setBorderWidth:[_viewStyleDrawContourLineWidthField doubleValue]];
	}
	
}




-(IBAction)drawContourHasChanged:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	[[v fillStyle] setDrawBorder:[_viewStyleDrawContourButton state]];
	[self updateViewDataWithView:v];
}


-(IBAction)borderColorHasChanged:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	[[v fillStyle] setBorderColor:[_viewStyleDrawContourLineColorWell color]];
}

-(IBAction)fillBackgroundHasChanged:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	[[v fillStyle] setFillFeature:[_viewStyleFillBackgroundButton state]];
	[self updateViewDataWithView:v];
}

-(IBAction)backgroundColorHasChanged:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	[[v fillStyle] setFillColor:[_viewStyleFillBackgroundColorWell color]];
}










#pragma mark --- Manage the view panel sheet ---

-(IBAction)endViewSheet:(id)sender
{
	[_viewList deselectAll:self];
	[NSApp endSheet:[self window]];
	[[self window] orderOut:sender];
}


-(void)viewSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[[doc page] setNeedsDisplay:YES];
}






#pragma mark --- Managing the views ---


-(IBAction)addNewView:(id)sender
{
	[NSApp runModalForWindow:_addNewViewPanel];
}


-(IBAction)addNewViewTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		if (doc == nil)
		{
			NSLog(@"[TMViewPanelController addNewViewTerminate:] Current document not found.");
			TMDisplayError(@"Error. Current document not found.", @"");
			return;
		}
		
		// Get the number of views already present in the document's page.
		NSInteger nviews = [[[doc page] subviews] count];
		
		switch ([_addNewViewTypeMenu selectedTag])
		{
			case 1:		// Map view
				[doc logCommand:@"\"Creating a new map view\"\n"];
				[doc executeCommand:@"_mapView := TMMapView alloc initWithFrame:(40<>60 extent:300<>200)."];
				[doc executeCommand:[NSString stringWithFormat:@"_mapView setName:'View %i'.", (nviews+1)]];
				[doc executeCommand:@"(_doc page) addSubview:_mapView."];
				break;
			case 2:		// Text view
				[doc logCommand:@"\"Creating a new text view\"\n"];
				[doc executeCommand:@"_textView := TMTextView alloc initWithFrame:(40<>20 extent:200<>50)."];
				[doc executeCommand:[NSString stringWithFormat:@"_textView setName:'View %i'.", (nviews+1)]];
				[doc executeCommand:@"(_doc page) addSubview:_textView."];
				break;
			case 3:		// Legend view
				[doc logCommand:@"\"Creating a new legend view\"\n"];
				[doc executeCommand:@"_legendView := TMLegendView alloc initWithFrame:(300<>100 extent:140<>200)."];
				[doc executeCommand:[NSString stringWithFormat:@"_legendView setName:'View %i'.", (nviews+1)]];
				[doc executeCommand:@"(_doc page) addSubview:_legendView."];
				break;
			case 4:		// Scale view
				[doc logCommand:@"\"Creating a new scale view\"\n"];
				[doc executeCommand:@"_scaleView := TMScaleView alloc initWithFrame:(40<>40 extent:200<>100)."];
				[doc executeCommand:[NSString stringWithFormat:@"_scaleView setName:'View %i'.", (nviews+1)]];
				[doc executeCommand:@"(_doc page) addSubview:_scaleView."];
				break;
			default:
				break;
		}
	}
	
	[NSApp stopModal];
	[_addNewViewPanel orderOut:sender];
	[_viewList reloadData];
}





-(IBAction)removeView:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Remove the view.
	[v removeFromSuperview];
	
	[_viewList reloadData];
}



-(IBAction)moveViewUp:(id)sender
{
	
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	NSMutableArray *sviews = [[[doc page] subviews] mutableCopy];
	
	
	// Get the index of the selected view.
	NSInteger selectedLayer = [_viewList selectedRow];
	
	if (selectedLayer > 0)
	{
		[sviews exchangeObjectAtIndex:selectedLayer withObjectAtIndex:(selectedLayer-1)];
		[[doc page] setSubviews:[NSArray arrayWithArray:sviews]];
		[_viewList selectRow:(selectedLayer-1) byExtendingSelection:NO];
	
		// Reload the data.
		[_viewList reloadData];
	}
	
}



-(IBAction)moveViewDown:(id)sender
{
	
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	NSMutableArray *sviews = [[[doc page] subviews] mutableCopy];
	
	
	// Get the index of the selected view.
	NSInteger selectedLayer = [_viewList selectedRow];
	
	if (selectedLayer < ([sviews count] - 1))
	{
		[sviews exchangeObjectAtIndex:selectedLayer withObjectAtIndex:(selectedLayer+1)];
		[[doc page] setSubviews:[NSArray arrayWithArray:sviews]];
		[_viewList selectRow:(selectedLayer+1) byExtendingSelection:NO];
		
		// Reload the data.
		[_viewList reloadData];
	}
	
}










#pragma mark --- Showing the view properties ---

-(IBAction)showViewProperties:(id)sender
{
	// Get the selected view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	NSString *vclass = [v className];
	NSLog([NSString stringWithFormat:@"View class: %@", vclass]);
	
	
	if ([v class] == [TMMapView class])
	{
		[self showMapViewProperties:sender];
	}
	else if ([v class] == [TMTextView class])
	{
		[self showTextViewProperties:sender];
	}
	else if ([v class] == [TMLegendView class])
	{
		[self showLegendViewProperties:sender];
	}
	else if ([v class] == [TMScaleView class])
	{
		[self showScaleViewProperties:sender];
	}
	else
	{
		TMDisplayError(@"No view properties available for this view type", @"The view type is unknown.");
	}
}



-(IBAction)showMapViewProperties:(id)sender
{
	// Get the selected map view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Update the data in the map view dialog.
	[_mapViewLayerList reloadData];
	[_mapViewLayerList deselectAll:self];
	[self updateLayerListWithNoSelection];
	TMEnvelope *bbox = [v envelope];
	[_mapViewCoordinateTop setDoubleValue:[bbox north]];
	[_mapViewCoordinateBottom setDoubleValue:[bbox south]];
	[_mapViewCoordinateLeft setDoubleValue:[bbox west]];
	[_mapViewCoordinateRight setDoubleValue:[bbox east]];
	
	// Show the dialog
	[NSApp runModalForWindow:_mapViewPropertiesPanel];
}


-(IBAction)showMapViewPropertiesTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		// OK button. Save map coordinates.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		TMEnvelope *env = [v envelope];
		[env setEast:[_mapViewCoordinateRight doubleValue]];
		[env setWest:[_mapViewCoordinateLeft doubleValue]];
		[env setNorth:[_mapViewCoordinateTop doubleValue]];
		[env setSouth:[_mapViewCoordinateBottom doubleValue]];
		
		// Update the map view.
		[v setNeedsDisplay:YES];
	}
	
	
	[NSApp stopModal];
	[_mapViewPropertiesPanel orderOut:sender];
}



-(IBAction)showTextViewProperties:(id)sender
{
	// Get the selected text view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMTextView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	[[_textViewEditorField textStorage] setAttributedString:[[v textView] textStorage]];
	
	// Show the dialog
	[NSApp runModalForWindow:_textViewPropertiesPanel];
}




-(IBAction)showTextViewPropertiesTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		// Get the selected text view.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		TMTextView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		
		// Update the text view content.
		[[[v textView] textStorage] setAttributedString:[_textViewEditorField textStorage]];
		
		[v setNeedsDisplay:YES];
	}
	
	[NSApp stopModal];
	[_textViewPropertiesPanel orderOut:sender];
}





-(IBAction)showLegendViewProperties:(id)sender
{
	// Update the pop-up menu with the layer list.
	[_legendViewLayerList removeAllItems];
	
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	for (TMLayer *l in [doc layers])
	{
		[_legendViewLayerList addItemWithTitle:[l name]];
	}
	if ([_legendViewLayerList numberOfItems] == 0)
		[_legendViewLayerList addItemWithTitle:@"<none>"];
	
	
	// Show the dialog
	[NSApp runModalForWindow:_legendViewPropertiesPanel];
}





-(IBAction)showLegendViewPropertiesTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		
		// Get the selected view.
		TMLegendView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		[v setLayer:nil];
		
		// Find the layer with the appropriate name.
		NSString *lname = [[_legendViewLayerList selectedItem] title];
		for (TMLayer *l in [doc layers])
		{
			if ([lname compare:[l name]] == NSOrderedSame)
				[v setLayer:l];
		}
		
		 
		[v setNeedsDisplay:YES];
	}
	
	[NSApp stopModal];
	[_legendViewPropertiesPanel orderOut:sender];
}





-(IBAction)showScaleViewProperties:(id)sender
{
	// Update the pop-up menu with the list of map views.
	[_scaleViewMapViewList removeAllItems];
	[_scaleViewMapViewList addItemWithTitle:@""];
	[_scaleViewMapViewList selectItemWithTitle:@""];
	
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMScaleView *sview = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	TMPage *page = [doc page];
	for (id v in [page subviews])
	{
		if ([v class] == [TMMapView class])
		{
			TMMapView *mv = v;
			[_scaleViewMapViewList addItemWithTitle:[mv name]];
			
			if (mv == [sview mapView])
				[_scaleViewMapViewList selectItemWithTitle:[mv name]];
			
		}
	}
	
	
	[_scaleViewScaleLengthTextField setDoubleValue:[sview scaleLength]];
	[_scaleViewScaleUnitFactorTextField setDoubleValue:[sview scaleUnitFactor]];
	[_scaleViewUnitTextField setStringValue:[sview scaleUnit]];
	[_scaleViewNumberOfDivisionsTextField setIntegerValue:[sview numberOfDivisions]];
	
	
	
	// Show the dialog
	[NSApp runModalForWindow:_scaleViewPropertiesPanel];
}





-(IBAction)showScaleViewPropertiesTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		
		// Get the selected view.
		TMScaleView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
		[v setMapView:nil];
		
		// Find the map view with the appropriate name.
		NSString *mapViewName = [[_scaleViewMapViewList selectedItem] title];
		for (id sv in [[doc page] subviews])
		{
			if ([sv class] == [TMMapView class])
			{
				TMMapView *mv = sv;
				if ([mapViewName compare:[mv name]] == NSOrderedSame)
					[v setMapView:mv];
			}
		}
		
		// Copy the values.
		[v setScaleLength:[_scaleViewScaleLengthTextField doubleValue]];
		[v setScaleUnitFactor:[_scaleViewScaleUnitFactorTextField doubleValue]];
		[v setScaleUnit:[_scaleViewUnitTextField stringValue]];
		[v setNumberOfDivisions:[_scaleViewNumberOfDivisionsTextField integerValue]];
		
		
		[v setNeedsDisplay:YES];
	}
	
	[NSApp stopModal];
	[_scaleViewPropertiesPanel orderOut:sender];
}







#pragma mark --- Map view properties actions ---

-(IBAction)addLayer:(id)sender
{
	
	// Update the layer popup menu.
	
	[_mapViewAddLayerMenu removeAllItems];
	
	// Get the list of layers.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	NSArray *layers = [doc layers];
	
	// Add all layers to the popup menu.
	for (TMLayer *l in layers)
	{
		[_mapViewAddLayerMenu addItemWithTitle:[l name]];
	}
	
	
	// Show dialog for adding a layer.
	[NSApp beginSheet:_mapViewAddLayerSheet 
	   modalForWindow:_mapViewPropertiesPanel
		modalDelegate:nil 
	   didEndSelector:nil 
		  contextInfo:nil];
}





-(IBAction)addLayerDidEnd:(id)sender
{
	// Get the name of the selected layer.
	NSString * selectedLayer = [[_mapViewAddLayerMenu selectedItem] title];
	
	// Find the layer with this name.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	NSArray *layers = [doc layers];
	for (TMLayer *l in layers)
	{
		if ([[l name] compare:selectedLayer] == NSOrderedSame)
		{
			// Add the layer to the current view.
			[v addObjectToLayers:l];
		}
	}
	
	// Reload the list data
	[_mapViewLayerList reloadData];

	// Close the sheet.
	[self addLayerClose:sender];
}


-(IBAction)addLayerClose:(id)sender
{	
	[NSApp endSheet:_mapViewAddLayerSheet];
	[_mapViewAddLayerSheet orderOut:sender];
}





-(IBAction)removeLayer:(id)sender
{
	// Get the current view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Get the index of the selected layer.
	NSInteger selectedLayer = [_mapViewLayerList selectedRow];
	
	// Remove the layer.
	[v removeObjectFromLayersAtIndex:selectedLayer];
	
	// Reload the data.
	[_mapViewLayerList reloadData];
}





-(IBAction)moveLayerUp:(id)sender
{
	// Get the current view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Get the index of the selected layer.
	NSInteger selectedLayer = [_mapViewLayerList selectedRow];
	
	if (selectedLayer > 0)
	{
		[[v layers] exchangeObjectAtIndex:selectedLayer withObjectAtIndex:(selectedLayer-1)];
		[_mapViewLayerList selectRow:(selectedLayer-1) byExtendingSelection:NO];
	}
	
	// Reload the data.
	[_mapViewLayerList reloadData];
}




-(IBAction)moveLayerDown:(id)sender
{
	// Get the current view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	// Get the index of the selected layer.
	NSInteger selectedLayer = [_mapViewLayerList selectedRow];
	
	if (selectedLayer < ([[v layers] count] - 1))
	{
		[[v layers] exchangeObjectAtIndex:selectedLayer withObjectAtIndex:(selectedLayer+1)];
		[_mapViewLayerList selectRow:(selectedLayer+1) byExtendingSelection:NO];
	}
	
	// Reload the data.
	[_mapViewLayerList reloadData];
}




-(IBAction)computeFullExtent:(id)sender
{
	// Get the list of layers in the current view.
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	TMMapView *v = [[[doc page] subviews] objectAtIndex:[_viewList selectedRow]];
	
	NSArray *layers = [v layers];
	TMEnvelope *bbox = nil;
	for (TMLayer *l in layers)
	{
		if (bbox == nil)
			bbox = [[TMEnvelope alloc] initWithEnvelope:[l envelope]];
		else
			[bbox expandToIncludeEnvelope:[l envelope]];
	}
	
	[_mapViewCoordinateLeft setDoubleValue:[bbox west]];
	[_mapViewCoordinateRight setDoubleValue:[bbox east]];
	[_mapViewCoordinateBottom setDoubleValue:[bbox south]];
	[_mapViewCoordinateTop setDoubleValue:[bbox north]];
	
}





#pragma mark --- Map view layer list data management ---

-(void)updateLayerListWithNoSelection
{
	[_mapViewMoveLayerDownButton setEnabled:NO];
	[_mapViewMoveLayerUpButton setEnabled:NO];
	[_mapViewRemoveLayerButton setEnabled:NO];
}


-(void)updateLayerListWithMultipleSelection
{
	[_mapViewMoveLayerDownButton setEnabled:NO];
	[_mapViewMoveLayerUpButton setEnabled:NO];
	[_mapViewRemoveLayerButton setEnabled:YES];
}


-(void)updateLayerListWithLayer:(TMLayer*)layer
{
	[_mapViewMoveLayerDownButton setEnabled:YES];
	[_mapViewMoveLayerUpButton setEnabled:YES];
	[_mapViewRemoveLayerButton setEnabled:YES];
}







/*-(void)viewSelectionChanged:(NSNotification*)aNotification
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [document page];
	NSArray *selectedViews = [page selectedViews];
	NSUInteger nviews = [selectedViews count];
	if (nviews == 0)
	{
		NSInteger tabIndex =
			[_tabView indexOfTabViewItemWithIdentifier:@"NoSelection"];
		[_tabView selectTabViewItem:[_tabView tabViewItemAtIndex:tabIndex]];
	}
	else if (nviews == 1)
	{
		TMView *selView = [selectedViews objectAtIndex:0];
		[self updateWithView:selView];
	}
	else
	{
		NSInteger tabIndex =
			[_tabView indexOfTabViewItemWithIdentifier:@"MultipleSelection"];
		[_tabView selectTabViewItem:[_tabView tabViewItemAtIndex:tabIndex]];
	}
	
}




-(void)updateWithView:(TMView*)view
{

	if (view == nil ||
		[view isKindOfClass:[TMTextView class]])
	{
		NSInteger tabIndex = 
			[_tabView indexOfTabViewItemWithIdentifier:@"NotAvailable"];
		[_tabView selectTabViewItem:[_tabView tabViewItemAtIndex:tabIndex]];
		return;
	}
	
	
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	
	
	if ([view isKindOfClass:[TMMapView class]])
	{
		NSInteger tabIndex =
			[_tabView indexOfTabViewItemWithIdentifier:@"Map"];
		[_tabView selectTabViewItem:[_tabView tabViewItemAtIndex:tabIndex]];
	
		if ([[document layers] count] > 0)
			[_addLayerButton setEnabled:YES];
		else
			[_addLayerButton setEnabled:NO];
		
		// ...
		
		return;
	}
	
}





-(IBAction)showAddLayerSheet:(id)sender
{

	// Add all current layers in the menu.
	
	[_addLayerPopUp removeAllItems];
	
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	NSMutableArray *lyrs = [document layers];
	for (TMLayer *lyr in lyrs)
	{
		[_addLayerPopUp addItemWithTitle:[lyr name]];
	}


	[NSApp beginSheet:_addLayerSheet
		modalForWindow:[self window] 
		modalDelegate:self
		didEndSelector:nil
		contextInfo:nil];
}





-(IBAction)hideAddLayerSheet:(id)sender
{
	[NSApp endSheet:_addLayerSheet];
	[_addLayerSheet setIsVisible:NO];
}




-(IBAction)addLayerToView:(id)sender
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [document page];
	NSArray *selectedViews = [page selectedViews];
	if ([selectedViews count] == 1)
	{
		id selView = [selectedViews objectAtIndex:0];
		if ([selView isKindOfClass:[TMMapView class]])
		{
			// Get the index of the selected layer.
			NSInteger selIndex = [_addLayerPopUp indexOfSelectedItem];
			TMLayer *selLayer = [[document layers] objectAtIndex:selIndex];
	
			TMMapView *map = (TMMapView*)selView;
			[map addObjectToLayers:selLayer];
			if ([map countOfLayers] == 1)
				[self zoomMapViewToFullExtent:self];
				
			[map setNeedsDisplay:YES];
		}
	}
	
	[self hideAddLayerSheet:sender];
	[_layerList reloadData];
	
}



-(IBAction)removeLayerFromView:(id)sender
{
	// Get the selected layer index.
	NSInteger selLayerIndex = [_layerList selectedRow];

	// Get the selected map view.
	TMMapView *map = [self selectedMapView];
	if (map == nil) return;
	
	[map removeObjectFromLayersAtIndex:selLayerIndex];
	[map setNeedsDisplay:YES];
	[_layerList reloadData];
}




-(IBAction)moveLayerUp:(id)sender
{
	// Get the selected layer index.
	NSInteger selLayerIndex = [_layerList selectedRow];
	if (selLayerIndex == 0) return;
	
	// Get the selected map view.
	TMMapView *map = [self selectedMapView];
	if (map == nil) return;
	
	NSUInteger nlayers = [map countOfLayers];
	
	[[map layers] exchangeObjectAtIndex:(nlayers-selLayerIndex-1) 
		withObjectAtIndex:(nlayers-selLayerIndex)];
	
	[_layerList selectRow:(selLayerIndex-1) byExtendingSelection:NO];
	
	[map setNeedsDisplay:YES];
	[_layerList reloadData];
	
}



-(IBAction)moveLayerDown:(id)sender
{

	// Get the selected layer index.
	NSInteger selLayerIndex = [_layerList selectedRow];
	
	// Get the selected map view.
	TMMapView *map = [self selectedMapView];
	if (map == nil) return;
	
	NSUInteger nlayers = [map countOfLayers];
	if (selLayerIndex == (nlayers - 1)) return;
	
	[[map layers] exchangeObjectAtIndex:(nlayers-selLayerIndex-1) 
		withObjectAtIndex:(nlayers-selLayerIndex-2)];
	
	[_layerList selectRow:(selLayerIndex+1) byExtendingSelection:NO];
	
	[map setNeedsDisplay:YES];
	[_layerList reloadData];

}




-(IBAction)zoomMapViewToFullExtent:(id)sender
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [document page];
	NSArray *selectedViews = [page selectedViews];
	if ([selectedViews count] == 1)
	{
		id selView = [selectedViews objectAtIndex:0];
		if ([selView isKindOfClass:[TMMapView class]])
		{
			TMMapView *map = (TMMapView*)selView;
			[map zoomToFullExtent];
			[map setNeedsDisplay:YES];
			[self updateMapCoordinates];
		}
	}
}




-(void)updateMapCoordinates
{
	
	// Find the selected map view.
	
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [document page];
	
	NSArray *selectedViews = [page selectedViews];
	if ([selectedViews count] != 1)
		return;
	
	id selView = [selectedViews objectAtIndex:0];
	if ([selView isKindOfClass:[TMMapView class]] == NO)
		return;
	
	TMMapView *map = (TMMapView*)selView;
	

	// Get the map's envelope.
	TMEnvelope *mapEnv = [map envelope];
	
	
	// Set the text field contents using the map envelope.
	[_leftMapCoordinate setDoubleValue:[mapEnv west]];
	[_bottomMapCoordinate setDoubleValue:[mapEnv south]];
	[_widthMapCoordinate setDoubleValue:[mapEnv width]];
	[_heightMapCoordinate setDoubleValue:[mapEnv height]];
	

}





-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	if (tableView == _layerList)
	{
		// Find the selected map view.
		TMMapView *map = [self selectedMapView];
		if (map == nil) return 0;
		return [map countOfLayers];
	}
	return 0;
}




-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex
{
	
	if (tableView == _layerList)
	{
		// Find the selected map view.
		TMMapView *map = [self selectedMapView];
		if (map == nil) return nil;
		
		NSUInteger nlyrs = [map countOfLayers];
		TMLayer *layer = [map objectInLayersAtIndex:(nlyrs-rowIndex-1)];
		return [layer name];
	}
	
	return nil;
	
}






-(TMMapView*)selectedMapView
{

	// Find the selected map view.
	
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	TMPage *page = [document page];
	
	NSArray *selectedViews = [page selectedViews];
	if ([selectedViews count] != 1)
		return nil;
	
	id selView = [selectedViews objectAtIndex:0];
	if ([selView isKindOfClass:[TMMapView class]] == NO)
		return nil;
	
	TMMapView *map = (TMMapView*)selView;
	return map;
	
}




-(void)controlTextDidChange:(NSNotification*)aNotification
{

	if ([aNotification object] == _leftMapCoordinate)
	{
		TMMapView *map = [self selectedMapView];
		if (map == nil) return;
		TMEnvelope *env = [map envelope];
		double width = [env width];
		double newWest = [[aNotification object] doubleValue];
		[env setWest:newWest];
		[env setEast:(newWest + width)];
		[map displaySoon];
	}
	else if ([aNotification object] == _bottomMapCoordinate)
	{
		TMMapView *map = [self selectedMapView];
		if (map == nil) return;
		TMEnvelope *env = [map envelope];
		double height = [env height];
		double newSouth = [[aNotification object] doubleValue];
		[env setSouth:newSouth];
		[env setNorth:(newSouth + height)];
		[map displaySoon];
	}
	else if ([aNotification object] == _widthMapCoordinate)
	{
		TMMapView *map = [self selectedMapView];
		if (map == nil) return;
		TMEnvelope *env = [map envelope];
		double width = [env width];
		double newWidth = [[aNotification object] doubleValue];
		if (newWidth <= 0) return;
		double newHeight = [env height] * (newWidth / width);
		[env setEast:([env west] + newWidth)];
		[env setNorth:([env south] + newHeight)];
		[map displaySoon];
		[self updateMapCoordinates];
	}
	else if ([aNotification object] == _heightMapCoordinate)
	{
		TMMapView *map = [self selectedMapView];
		if (map == nil) return;
		TMEnvelope *env = [map envelope];
		double height = [env height];
		double newHeight = [[aNotification object] doubleValue];
		if (newHeight <= 0) return;
		double newWidth = [env width] * (newHeight / height);
		[env setNorth:([env south] + newHeight)];
		[env setEast:([env west] + newWidth)];
		[map displaySoon];
		[self updateMapCoordinates];
	}
	
}
*/


@end
