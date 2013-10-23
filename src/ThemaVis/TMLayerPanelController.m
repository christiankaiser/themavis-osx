//
//  TMLayerPanelController.m
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import "TMLayerPanelController.h"
#import "TMDocument.h"

#import "NSString+Explode.h"
#import <stdio.h>



@implementation TMLayerPanelController



+(id)sharedLayerPanelController
{
    static TMLayerPanelController *
		sharedLayerPanelController = nil;


    if (!sharedLayerPanelController)
	{
        sharedLayerPanelController = 
			[[TMLayerPanelController allocWithZone:NULL] init];
    }

    return sharedLayerPanelController;
}



-(id)init
{
    self = [self initWithWindowNibName:@"LayerPanel"];
	
    if (self)
	{
        [self setWindowFrameAutosaveName:@"LayerPanel"];
    }
    return self;
}




-(void)windowDidLoad
{
	[super windowDidLoad];
	[self updatePanelWithNoSelection];
}





-(IBAction)endLayerSheet:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:sender];
}




-(void)layerSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	[[doc page] setNeedsDisplay:YES];
}






-(NSMutableArray*)layers
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	return [document layers];
}



-(void)setLayers:(NSMutableArray*)layers
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	[document setLayers:layers];
}








-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	if (tableView == _layerList)
		return [[self layers] count];
	
	if (tableView == _attributeTable)
	{
		return [[self selectedLayer] countOfFeatures];
	}
	
	
	return 0;
}



-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex
{
	
	if (tableView == _layerList)
	{
		TMLayer *layer = [[self layers] objectAtIndex:rowIndex];
		return [layer name];
	}
	
	
	if (tableView == _attributeTable)
	{
		TMFeature *feat = 
			[[self selectedLayer] objectInFeaturesAtIndex:rowIndex];
		
		id value = [feat attributeForKey:[aTableColumn identifier]];
		
		if ([value isKindOfClass:[TMGeometry class]])
		{
			if ([value isMemberOfClass:[TMPolygon class]] ||
				[value isMemberOfClass:[TMMultiPolygon class]])
				return @"Polygon";
			
			if ([value isMemberOfClass:[TMLineString class]])
				return @"Line";
			
			if ([value isMemberOfClass:[TMPoint class]])
				return @"Point";
		
			return @"Geometry";
		}
			
		
		return value;
	}
	
	return nil;
	
}



-(void)tableView:(NSTableView*)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex
{
	
	if (aTableView == _layerList)
	{
		TMLayer *layer = [[self layers] objectAtIndex:rowIndex];
		[layer setName:anObject];
		return;
	}
	
}






-(IBAction)addLayer:(id)sender
{

	// Show an open file dialog sheet for Shape files (.shp)
	// and BNA files (.bna, .plg, .pts, .lns).
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	
	NSArray *fileTypes = 
		[NSArray arrayWithObjects:@"shp", nil];
	
	[openPanel beginSheetForDirectory:nil file:nil 
		types:fileTypes modalForWindow:[self window] 
		modalDelegate:self 
		didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
		contextInfo:nil];

}




-(IBAction)removeLayer:(id)sender
{
	// Get the selected layers in the list.
	[[self layers] removeObjectsAtIndexes:[_layerList selectedRowIndexes]];
	[_layerList deselectAll:sender];
	[_layerList reloadData];
}






-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo
{

	
	// Only load the selected files if the OK button has been selected.
	if (returnCode == NSOKButton)
	{
		// Get the current document.
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		
		
		// Import all selected Shape files.
		NSArray *files = [panel filenames];
		for (NSString *filePath in files)
		{
			NSString *fileType = 
				[[filePath substringFromIndex:([filePath length]-3)]
					lowercaseString];
			
			if ([fileType compare:@"shp"] == NSOrderedSame)
			{
				// Execute the commands from inside the shell.
				//TMShapefile *shp = [[TMShapefile alloc] initWithPath:filePath];
				//TMLayer *layer = [shp read];
				//[doc addLayer:layer];
				[doc logCommand:@"\"Import layer from Shape file\"\n"];
				FSInterpreterResult *res = [doc executeCommand:
					 [NSString stringWithFormat:@"_shape := TMShapefile alloc initWithPath:'%@'.", filePath]];
				res = [doc executeCommand:@"_layer := _shape read."];
				res = [doc executeCommand:@"_doc addLayer:_layer."];
				[doc logCommand:@"\n"];
			}
				
		}
		
		[_layerList reloadData];
	}
	
}





-(void)tableViewSelectionDidChange:(NSNotification*)aNotification
{
	
	NSTableView *changedTableView = (NSTableView*)[aNotification object];
	
	if (changedTableView == _layerList)
	{
		NSIndexSet *selectedRows = [_layerList selectedRowIndexes];
		NSInteger nSelectedRows = [selectedRows count];
		
		if (nSelectedRows == 0)
		{
			[self updatePanelWithNoSelection];
			return;
		}
		
		if (nSelectedRows > 1)
		{
			[self updatePanelWithMultipleSelection];
			return;
		}
		
		TMLayer *selectedLayer = 
			[[self layers] objectAtIndex:[_layerList selectedRow]];
		
		[self updatePanelWithLayer:selectedLayer];
	}
	
}




-(void)updatePanel
{
	[_layerList reloadData];
}




-(void)updatePanelWithNoSelection
{

	// Update the Alias text field.
	[_aliasTextField setStringValue:@"No selection"];
	[_aliasTextField setTextColor:[NSColor grayColor]];
	[_aliasTextField setSelectable:NO];
	
	// Update the attributes table view.
	[_attributeTableScrollView setHidden:YES];
	[_noAttributesLabel setStringValue:@"No selection"];
	[_noAttributesLabel setHidden:NO];
	
	// Update the map view.
	[_mapView setHidden:YES];
	[_mapViewLabel setStringValue:@"No selection"];
	[_mapViewLabel setHidden:NO];
	

	// Update the mapping style elements.
	[_mappingStyleMenu setEnabled:NO];
	[_mappingStyleMenuLabel setEnabled:NO];
	[_mappingStyleMenuLabel setTextColor:[NSColor grayColor]];
	[_mappingStylePropertiesButton setEnabled:NO];
	
	
	// Update the label elements.
	[_showLabelsButton setEnabled:NO];
	[_showLabelsAttributeLabel setEnabled:NO];
	[_showLabelsAttributeLabel setTextColor:[NSColor grayColor]];
	[_showLabelsAttributeMenu setEnabled:NO];
	[_showLabelsAttributeMenu removeAllItems];

}





-(void)updatePanelWithLayer:(TMLayer*)layer
{

	// Update the Alias text field.
	[_aliasTextField setStringValue:[layer alias]];
	[_aliasTextField setTextColor:[NSColor blackColor]];
	[_aliasTextField setSelectable:YES];
	[_aliasTextField setEditable:YES];
	
	
	// Update the attributes table view.
	[_noAttributesLabel setHidden:YES];
	
	// Remove all table columns.
	NSTableColumn *col;
	NSArray *cols = [_attributeTable tableColumns];
	NSArray *colsCopy = [cols copy];
	for (col in colsCopy)
		[_attributeTable removeTableColumn:col];
	
	// Get the attribute dictionary.
	TMFeature *feat = [[layer features] objectAtIndex:0];
	NSMutableDictionary *attrs = [feat attributes];
	
	// Create a new column for each attribute.
	NSString *attrName;
	for (attrName in attrs)
	{
		col = [[NSTableColumn alloc] initWithIdentifier:attrName];
		[[col headerCell] setStringValue:attrName];
		[_attributeTable addTableColumn:col];
	}
	
	[_attributeTableScrollView setHidden:NO];
	[_attributeTable reloadData];
	


	// Update the map view.
	[_mapViewLabel setHidden:YES];
	[[_mapView layers] removeAllObjects];
	[_mapView addObjectToLayers:[self selectedLayer]];
	[_mapView zoomToFullExtent];
	[_mapView setNeedsDisplay:YES];
	[_mapView setHidden:NO];


	// Update the style settings.
	[self updateStyleSettingsWithLayer:layer];
	[self updateLabelSettingsWithLayer:layer];
	
}




-(void)updatePanelWithMultipleSelection
{
	
	// Update the Alias text field.
	[_aliasTextField setStringValue:@"Mutliple values"];
	[_aliasTextField setTextColor:[NSColor grayColor]];
	[_aliasTextField setSelectable:NO];
	
	// Update the attributes table view.
	[_attributeTableScrollView setHidden:YES];
	[_noAttributesLabel setStringValue:@"Multiple selection"];
	[_noAttributesLabel setHidden:NO];
	
	// Update the map view.
	[_mapView setHidden:YES];
	[_mapViewLabel setStringValue:@"Multiple selection"];
	[_mapViewLabel setHidden:NO];
	
	// Update the mapping style elements.
	[_mappingStyleMenu setEnabled:NO];
	[_mappingStyleMenuLabel setEnabled:NO];
	[_mappingStyleMenuLabel setTextColor:[NSColor grayColor]];
	[_mappingStylePropertiesButton setEnabled:NO];
	
	
	// Update the label elements.
	[_showLabelsButton setEnabled:NO];
	[_showLabelsAttributeLabel setEnabled:NO];
	[_showLabelsAttributeLabel setTextColor:[NSColor grayColor]];
	[_showLabelsAttributeMenu setEnabled:NO];
	[_showLabelsAttributeMenu removeAllItems];
}




-(void)updateStyleSettingsWithLayer:(TMLayer*)layer
{
	
	// Update the mapping style elements.
	[_mappingStyleMenu setEnabled:YES];
	[_mappingStyleMenuLabel setEnabled:YES];
	[_mappingStyleMenuLabel setTextColor:[NSColor blackColor]];
	[_mappingStylePropertiesButton setEnabled:YES];
	
	
	TMStyle *style = [layer style];
	
	
	// Simple fill style
	if ([style isMemberOfClass:[TMFillStyle class]])
	{
		[_mappingStyleMenu selectItemWithTitle:@"Simple fill style"];
		/*[_styleScrollView setDocumentView:_simpleFillStyleView];
		
		if ([(TMFillStyle*)style drawBorder])
			[_fillStyleDrawContourButton setState:NSOnState];
		else
			[_fillStyleDrawContourButton setState:NSOffState];
		
		[_fillStyleLineWidthField 
			setDoubleValue:[(TMFillStyle*)style borderWidth]];
		
		[_fillStyleLineColorWell setColor:[(TMFillStyle*)style borderColor]];
		
		if ([(TMFillStyle*)style fillFeature])
			[_fillStyleFillFeatureButton setState:NSOnState];
		else
			[_fillStyleFillFeatureButton setState:NSOffState];
		
		[_fillStyleFillColorWell setColor:[(TMFillStyle*)style fillColor]];*/
		
	}
	
	
	// Simple symbol style
	else if ([style isMemberOfClass:[TMSymbolStyle class]])
	{
		[_mappingStyleMenu selectItemWithTitle:@"Simple symbol"];
		/*[_styleScrollView setDocumentView:_simpleSymbolView];
		
		[_simpleSymbolTypeView setPath:[(TMSymbolStyle*)style symbol]];
		[_simpleSymbolHeight setIntegerValue:[(TMSymbolStyle*)style symbolHeight]];
		[_simpleSymbolWidth setIntegerValue:[(TMSymbolStyle*)style symbolWidth]];
		
		// Symbol style: Draw contour button.
		TMFillStyle *symbolFillStyle = [(TMSymbolStyle*)style symbolStyle];
		if ([symbolFillStyle drawBorder])
		{
			[_simpleSymbolStyleDrawContourButton setState:NSOnState];
			[_simpleSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolStyleLineWidthField setEnabled:YES];
			[_simpleSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolStyleLineColorWell setEnabled:YES];
		}
		else
		{
			[_simpleSymbolStyleDrawContourButton setState:NSOffState];
			[_simpleSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolStyleLineWidthField setEnabled:NO];
			[_simpleSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolStyleLineColorWell setEnabled:NO];
		}
		
		// Symbol style: line width and color.
		[_simpleSymbolStyleLineWidthField 
			setDoubleValue:[symbolFillStyle borderWidth]];
		[_simpleSymbolStyleLineColorWell setColor:[symbolFillStyle borderColor]];
		
		// Symbol style: Fill feature button.
		if ([symbolFillStyle fillFeature])
		{
			[_simpleSymbolStyleFillFeatureButton setState:NSOnState];
			[_simpleSymbolStyleFillColorLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolStyleFillColorWell setEnabled:YES];
		}
		else
		{
			[_simpleSymbolStyleFillFeatureButton setState:NSOffState];
			[_simpleSymbolStyleFillColorLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolStyleFillColorWell setEnabled:NO];
		}
		
		// Symbol style: fill color.
		[_simpleSymbolStyleFillColorWell setColor:[symbolFillStyle fillColor]];
		
		
		// Feature style : draw contour button.
		TMFillStyle *symbolFeatureStyle = [(TMSymbolStyle*)style featureStyle];
		if ([symbolFeatureStyle drawBorder])
		{
			[_simpleSymbolFeatureDrawContourButton setState:NSOnState];
			[_simpleSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolFeatureLineWidthField setEnabled:YES];
			[_simpleSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolFeatureLineColorWell setEnabled:YES];
		}
		else
		{
			[_simpleSymbolFeatureDrawContourButton setState:NSOffState];
			[_simpleSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolFeatureLineWidthField setEnabled:NO];
			[_simpleSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolFeatureLineColorWell setEnabled:NO];
		}
		
		// Feature style: line width and color.
		[_simpleSymbolFeatureLineWidthField 
			setDoubleValue:[symbolFeatureStyle borderWidth]];
		[_simpleSymbolFeatureLineColorWell 
			setColor:[symbolFeatureStyle borderColor]];
		
		// Feature style: fill feature button.
		if ([symbolFeatureStyle fillFeature])
		{
			[_simpleSymbolFeatureFillFeatureButton setState:NSOnState];
			[_simpleSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
			[_simpleSymbolFeatureFillColorWell setEnabled:YES];
		}
		else
		{
			[_simpleSymbolFeatureFillFeatureButton setState:NSOffState];
			[_simpleSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
			[_simpleSymbolFeatureFillColorWell setEnabled:NO];
		}
		
		// Feature style: fill color.
		[_simpleSymbolFeatureFillColorWell 
			setColor:[symbolFeatureStyle fillColor]];
		*/
	}
	
	
	// Choropleth map style
	else if ([style isMemberOfClass:[TMChoroplethStyle class]])
	{
		[_mappingStyleMenu selectItemWithTitle:@"Choropleth map"];
		/*[_styleScrollView setDocumentView:_choroplethMapView];
		
		// Generate the attribute menu.
		NSString *selAttr = [(TMChoroplethStyle*)style attributeName];
		[_choroplethAttributeMenu removeAllItems];
		[_choroplethAttributeMenu addItemWithTitle:@"<none>"];
		[_choroplethAttributeMenu selectItemWithTitle:@"<none>"];
		
		if ([layer countOfFeatures] > 0)
		{
			TMFeature *feat = [layer objectInFeaturesAtIndex:0];
			NSMutableDictionary *attrs = [feat attributes];
			for (NSString *attrKey in attrs)
			{
				id attr = [feat attributeForKey:attrKey];
				if ([attr isKindOfClass:[NSNumber class]])
				{
					[_choroplethAttributeMenu addItemWithTitle:attrKey];
					if ([attrKey compare:selAttr] == NSOrderedSame)
						[_choroplethAttributeMenu selectItemWithTitle:attrKey];
				}
			}
		}
		
		// Generate the classification menu.
		NSString *selCf = [[(TMChoroplethStyle*)style classification] name];
		[_choroplethClassificationMenu removeAllItems];
		[_choroplethClassificationMenu addItemWithTitle:@"<none>"];
		[_choroplethClassificationMenu selectItemWithTitle:@"<none>"];
		
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		NSMutableArray *classifications = [doc classifications];
		if (classifications != nil)
		{
			for (TMClassification *cf in classifications)
			{
				NSString *cfName = [cf name];
				[_choroplethClassificationMenu addItemWithTitle:cfName];
				if (selCf != nil && [selCf compare:cfName] == NSOrderedSame)
					[_choroplethClassificationMenu 
						selectItemWithTitle:cfName];
			}
		}
		
		
		// Set the feature style
		if ([(TMChoroplethStyle*)style drawBorder])
		{
			[_choroplethDrawContourButton setEnabled:YES];
			[_choroplethLineWidthLabel setTextColor:[NSColor blackColor]];
			[_choroplethLineWidthField setEnabled:YES];
			[_choroplethLineColorLabel setTextColor:[NSColor blackColor]];
			[_choroplethLineColorWell setEnabled:YES];
			
			[_choroplethLineWidthField 
				setDoubleValue:[(TMChoroplethStyle*)style borderWidth]];
			
			[_choroplethLineColorWell 
				setColor:[(TMChoroplethStyle*)style borderColor]];
		}
		else
		{
			[_choroplethDrawContourButton setEnabled:NO];
			[_choroplethLineWidthLabel setTextColor:[NSColor grayColor]];
			[_choroplethLineWidthField setEnabled:NO];
			[_choroplethLineColorLabel setTextColor:[NSColor grayColor]];
			[_choroplethLineColorWell setEnabled:NO];
		}
		*/
	}
	
	
	// Proportional symbol style
	else if ([style isMemberOfClass:[TMProportionalSymbolStyle class]])
	{
		[_mappingStyleMenu selectItemWithTitle:@"Proportional symbol"];
		/*[_styleScrollView setDocumentView:_proportionalSymbolView];
		
		// Display the symbol type.
		[_propSymbolTypeView setPath:[(TMProportionalSymbolStyle*)style symbol]];
		
		// Generate the attribute menu.
		NSString *selAttr = [(TMProportionalSymbolStyle*)style attributeName];
		[_propSymbolAttributeMenu removeAllItems];
		[_propSymbolAttributeMenu addItemWithTitle:@"<none>"];
		[_propSymbolAttributeMenu selectItemWithTitle:@"<none>"];
		
		if ([layer countOfFeatures] > 0)
		{
			TMFeature *feat = [layer objectInFeaturesAtIndex:0];
			NSMutableDictionary *attrs = [feat attributes];
			for (NSString *attrKey in attrs)
			{
				id attr = [feat attributeForKey:attrKey];
				if ([attr isKindOfClass:[NSNumber class]])
				{
					[_propSymbolAttributeMenu addItemWithTitle:attrKey];
					if ([attrKey compare:selAttr] == NSOrderedSame)
						[_propSymbolAttributeMenu selectItemWithTitle:attrKey];
				}
			}
		}
		
		// Calibration size & value, bias
		[_propSymbolCalibrationSizeField setIntegerValue:
			[(TMProportionalSymbolStyle*)style calibrationSize]];
		[_propSymbolCalibrationValueField setDoubleValue:
			[[(TMProportionalSymbolStyle*)style calibrationValue] doubleValue]];
		[_propSymbolBiasField setDoubleValue:
			[[(TMProportionalSymbolStyle*)style bias] doubleValue]];
		
		// Symbol style: Draw contour button.
		TMFillStyle *symbolFillStyle = 
			[(TMProportionalSymbolStyle*)style symbolStyle];
		if ([symbolFillStyle drawBorder])
		{
			[_propSymbolStyleDrawContourButton setState:NSOnState];
			[_propSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
			[_propSymbolStyleLineWidthField setEnabled:YES];
			[_propSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
			[_propSymbolStyleLineColorWell setEnabled:YES];
		}
		else
		{
			[_propSymbolStyleDrawContourButton setState:NSOffState];
			[_propSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
			[_propSymbolStyleLineWidthField setEnabled:NO];
			[_propSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
			[_propSymbolStyleLineColorWell setEnabled:NO];
		}
		
		// Symbol style: line width and color.
		[_propSymbolStyleLineWidthField 
			setDoubleValue:[symbolFillStyle borderWidth]];
		[_propSymbolStyleLineColorWell setColor:[symbolFillStyle borderColor]];
		
		// Symbol style: Fill feature button.
		if ([symbolFillStyle fillFeature])
		{
			[_propSymbolStyleFillFeatureButton setState:NSOnState];
			[_propSymbolStyleFillColorLabel setTextColor:[NSColor blackColor]];
			[_propSymbolStyleFillColorWell setEnabled:YES];
		}
		else
		{
			[_propSymbolStyleFillFeatureButton setState:NSOffState];
			[_propSymbolStyleFillColorLabel setTextColor:[NSColor grayColor]];
			[_propSymbolStyleFillColorWell setEnabled:NO];
		}
		
		// Symbol style: fill color.
		[_propSymbolStyleFillColorWell setColor:[symbolFillStyle fillColor]];
		
		
		// Feature style : draw contour button.
		TMFillStyle *symbolFeatureStyle = 
			[(TMProportionalSymbolStyle*)style featureStyle];
		if ([symbolFeatureStyle drawBorder])
		{
			[_propSymbolFeatureDrawContourButton setState:NSOnState];
			[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
			[_propSymbolFeatureLineWidthField setEnabled:YES];
			[_propSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
			[_propSymbolFeatureLineColorWell setEnabled:YES];
		}
		else
		{
			[_propSymbolFeatureDrawContourButton setState:NSOffState];
			[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
			[_propSymbolFeatureLineWidthField setEnabled:NO];
			[_propSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
			[_propSymbolFeatureLineColorWell setEnabled:NO];
		}
		
		// Feature style: line width and color.
		[_propSymbolFeatureLineWidthField 
		 setDoubleValue:[symbolFeatureStyle borderWidth]];
		[_propSymbolFeatureLineColorWell 
		 setColor:[symbolFeatureStyle borderColor]];
		
		// Feature style: fill feature button.
		if ([symbolFeatureStyle fillFeature])
		{
			[_propSymbolFeatureFillFeatureButton setState:NSOnState];
			[_propSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
			[_propSymbolFeatureFillColorWell setEnabled:YES];
		}
		else
		{
			[_propSymbolFeatureFillFeatureButton setState:NSOffState];
			[_propSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
			[_propSymbolFeatureFillColorWell setEnabled:NO];
		}
		
		// Feature style: fill color.
		[_propSymbolFeatureFillColorWell 
		 setColor:[symbolFeatureStyle fillColor]];
		*/
	}
	
	
	// Colored proportional symbol style
	else if ([style isMemberOfClass:[TMColoredProportionalSymbolStyle class]])
	{
		[_mappingStyleMenu selectItemWithTitle:@"Colored proportional symbol"];
	}
	
	// Other style (unknown class)
	else
	{
		NSLog(@"Unknown class.");
	}
	
	
	
}






-(void)updateLabelSettingsWithLayer:(TMLayer*)layer
{
	TMStyle *style = [layer style];
	
	[_showLabelsButton setEnabled:YES];
	[_showLabelsButton setState:[style drawLabels]];
	
	if ([style drawLabels])
	{
		[_showLabelsAttributeLabel setEnabled:YES];
		[_showLabelsAttributeLabel setTextColor:[NSColor blackColor]];
		[_showLabelsAttributeMenu setEnabled:YES];
	}
	else
	{
		[_showLabelsAttributeLabel setEnabled:NO];
		[_showLabelsAttributeLabel setTextColor:[NSColor grayColor]];
		[_showLabelsAttributeMenu setEnabled:NO];
	}
	
	[_showLabelsAttributeMenu removeAllItems];
	[_showLabelsAttributeMenu addItemWithTitle:@""];
	[_showLabelsAttributeMenu selectItemWithTitle:@""];
	
	NSString *currentLabelAttribute = [style labelAttribute];
	
	NSDictionary *attributes = [[layer objectInFeaturesAtIndex:0] attributes];
	for (NSString *attrKey in [attributes allKeys])
	{
		id attrVal = [attributes objectForKey:attrKey];
		if ([attrVal isKindOfClass:[NSString class]] || [attrVal respondsToSelector:@selector(stringValue)])
		{
			[_showLabelsAttributeMenu addItemWithTitle:attrKey];
			
			if (currentLabelAttribute != nil && [currentLabelAttribute compare:attrKey] == NSOrderedSame)
				[_showLabelsAttributeMenu selectItemWithTitle:attrKey];
		}
	}
}




-(IBAction)showLabelHasChanged:(id)sender
{
	TMLayer *layer = [self selectedLayer];
	[[layer style] setDrawLabels:[_showLabelsButton state]];
	
	[self updateLabelSettingsWithLayer:layer];
}


-(IBAction)showLabelAttributeHasChanged:(id)sender
{
	TMLayer *layer = [self selectedLayer];
	
	NSString *selectedAttribute = [[_showLabelsAttributeMenu selectedItem] title];
	if ([selectedAttribute compare:@""] == NSOrderedSame)
		[[layer style] setLabelAttribute:nil];
	else
		[[layer style] setLabelAttribute:selectedAttribute];

}





-(void)controlTextDidChange:(NSNotification*)aNotification
{
	
	if ([aNotification object] == _aliasTextField)
	{
		[[self selectedLayer] setAlias:[_aliasTextField stringValue]];
	}
	
	else if ([aNotification object] == _fillStyleLineWidthField)
	{
		TMFillStyle *style = (TMFillStyle*)[[self selectedLayer] style];
		[style setBorderWidth:[_fillStyleLineWidthField doubleValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _simpleSymbolWidth)
	{
		TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
		[style setSymbolWidth:[_simpleSymbolWidth integerValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _simpleSymbolHeight)
	{
		TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
		[style setSymbolHeight:[_simpleSymbolHeight integerValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _simpleSymbolStyleLineWidthField)
	{
		TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
		TMFillStyle *symbolStyle = [style symbolStyle];
		[symbolStyle setBorderWidth:[_simpleSymbolStyleLineWidthField doubleValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _simpleSymbolFeatureLineWidthField)
	{
		TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
		TMFillStyle *featStyle = [style featureStyle];
		[featStyle setBorderWidth:[_simpleSymbolFeatureLineWidthField doubleValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	// Proportional symbol style view.
	
	else if ([aNotification object] == _propSymbolCalibrationSizeField)
	{
		TMProportionalSymbolStyle *style = 
			(TMProportionalSymbolStyle*)[[self selectedLayer] style];
		
		NSInteger calibrationSize = 
			[_propSymbolCalibrationSizeField integerValue];
		
		if (calibrationSize > 0)
		{
			[style setCalibrationSize:calibrationSize];
			TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
			[[doc page] setNeedsDisplay:YES];
		}
	}
	
	else if ([aNotification object] == _propSymbolCalibrationValueField)
	{
		TMProportionalSymbolStyle *style = 
			(TMProportionalSymbolStyle*)[[self selectedLayer] style];
		[style setCalibrationValue:
			[NSNumber numberWithDouble:[_propSymbolCalibrationValueField doubleValue]]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _propSymbolBiasField)
	{
		TMProportionalSymbolStyle *style = 
			(TMProportionalSymbolStyle*)[[self selectedLayer] style];
		[style setBias:
			[NSNumber numberWithDouble:[_propSymbolBiasField doubleValue]]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _propSymbolStyleLineWidthField)
	{
		TMProportionalSymbolStyle *style = 
			(TMProportionalSymbolStyle*)[[self selectedLayer] style];
		TMFillStyle *symbolStyle = [style symbolStyle];
		[symbolStyle setBorderWidth:[_propSymbolStyleLineWidthField doubleValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	else if ([aNotification object] == _propSymbolFeatureLineWidthField)
	{
		TMProportionalSymbolStyle *style = 
			(TMProportionalSymbolStyle*)[[self selectedLayer] style];
		TMFillStyle *featStyle = [style featureStyle];
		[featStyle setBorderWidth:[_propSymbolFeatureLineWidthField doubleValue]];
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}
	
	
	
}






-(TMLayer*)selectedLayer
{
	NSMutableArray *layers = [self layers];
	if (layers == nil || [layers count] == 0)
		return nil;
	
	if (_layerList == nil)
		return nil;
	
	NSInteger selRow = [_layerList selectedRow];
	return [layers objectAtIndex:selRow];
}


-(NSInteger)indexOfSelectedLayer
{
	NSMutableArray *layers = [self layers];
	if (layers == nil || [layers count] == 0)
		return -1;
	
	if (_layerList == nil)
		return -1;
	
	return [_layerList selectedRow];
}






-(IBAction)styleTypeChanged:(id)sender
{
	
	TMLayer *selLayer = [self selectedLayer];
	if (selLayer == nil) return;
	
	// Get the style type of the menu.
	NSString *selStyleName = [[_mappingStyleMenu selectedItem] title];
	
	// Get the current mapping style.
	id style = [selLayer style];
	
	
	// Transform the style.
	if ([selStyleName compare:@"Simple fill style"] == NSOrderedSame)
	{
		if ([style isMemberOfClass:[TMFillStyle class]]) return;
		TMFillStyle *newStyle = [[TMFillStyle alloc] init];
		[[self selectedLayer] setStyle:newStyle];
	}
	else if ([selStyleName compare:@"Simple symbol"] == NSOrderedSame)
	{
		if ([style isMemberOfClass:[TMSymbolStyle class]]) return;
		TMSymbolStyle *newStyle = [[TMSymbolStyle alloc] init];
		[[self selectedLayer] setStyle:newStyle];
	}
	else if ([selStyleName compare:@"Choropleth map"] == NSOrderedSame)
	{
		if ([style isMemberOfClass:[TMChoroplethStyle class]]) return;
		TMChoroplethStyle *newStyle = [[TMChoroplethStyle alloc] init];
		[[self selectedLayer] setStyle:newStyle];
	}
	else if ([selStyleName compare:@"Proportional symbol"] == NSOrderedSame)
	{
		if ([style isMemberOfClass:[TMProportionalSymbolStyle class]]) return;
		TMProportionalSymbolStyle *newStyle =
			[[TMProportionalSymbolStyle alloc] init];
		[[self selectedLayer] setStyle:newStyle];
	}
	else if ([selStyleName compare:@"Colored proportional symbol"] ==
				NSOrderedSame)
	{
		if ([style isMemberOfClass:[TMColoredProportionalSymbolStyle class]])
			return;
		TMColoredProportionalSymbolStyle *newStyle =
			[[TMColoredProportionalSymbolStyle alloc] init];
		[[self selectedLayer] setStyle:newStyle];
	}
	
	
	[self updateStyleSettingsWithLayer:selLayer];
	
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	//[[doc page] setNeedsDisplay:YES];
	
}





-(IBAction)showStyleProperties:(id)sender
{
	
	TMLayer *selLayer = [self selectedLayer];
	if (selLayer == nil) return;
	
	// Get the style type of the menu.
	NSString *selStyleName = [[_mappingStyleMenu selectedItem] title];
	
	
	// Enabling the alpha channel in the color panel.
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	
	// Open the panel corresponding to the selected style.
	NSInteger result;
	if ([selStyleName compare:@"Simple fill style"] == NSOrderedSame)
	{
		TMFillStyle *style = (TMFillStyle*)[selLayer style];
		[_fillStyleDrawContourButton setState:[style drawBorder]];
		[_fillStyleLineWidthField setDoubleValue:[style borderWidth]];
		[_fillStyleLineColorWell setColor:[style borderColor]];
		[_fillStyleFillFeatureButton setState:[style fillFeature]];
		[_fillStyleFillColorWell setColor:[style fillColor]];
		
		result = [NSApp runModalForWindow:_simpleFillStylePanel];
	}
	else if ([selStyleName compare:@"Simple symbol"] == NSOrderedSame)
	{
		TMSymbolStyle *style = (TMSymbolStyle*)[selLayer style];
		[_simpleSymbolTypeView setPath:[style symbol]];
		[_simpleSymbolWidth setIntegerValue:(NSInteger)[style symbolWidth]];
		[_simpleSymbolHeight setIntegerValue:(NSInteger)[style symbolHeight]];
		[_simpleSymbolStyleDrawContourButton setState:[[style symbolStyle] drawBorder]];
		[_simpleSymbolStyleLineWidthField setDoubleValue:[[style symbolStyle] borderWidth]];
		[_simpleSymbolStyleLineColorWell setColor:[[style symbolStyle] borderColor]];
		[_simpleSymbolStyleFillFeatureButton setState:[[style symbolStyle] fillFeature]];
		[_simpleSymbolStyleFillColorWell setColor:[[style symbolStyle] fillColor]];
		[_simpleSymbolFeatureDrawContourButton setState:[[style featureStyle] drawBorder]];
		[_simpleSymbolFeatureLineWidthField setDoubleValue:[[style featureStyle] borderWidth]];
		[_simpleSymbolFeatureLineColorWell setColor:[[style featureStyle] borderColor]];
		[_simpleSymbolFeatureFillFeatureButton setState:[[style featureStyle] fillFeature]];
		[_simpleSymbolFeatureFillColorWell setColor:[[style featureStyle] fillColor]];
		
		result = [NSApp runModalForWindow:_simpleSymbolPanel];
	}
	else if ([selStyleName compare:@"Choropleth map"] == NSOrderedSame)
	{
		[self choroplethMapStylePrepareDialog];
		result = [NSApp runModalForWindow:_choroplethMapPanel];
	}
	else if ([selStyleName compare:@"Proportional symbol"] == NSOrderedSame)
	{
		[self proportionalSymbolStylePrepareDialog];
		result = [NSApp runModalForWindow:_proportionalSymbolPanel];
	}
	else if ([selStyleName compare:@"Colored proportional symbol"] == NSOrderedSame)
	{
		[self coloredProportionalSymbolStylePrepareDialog];
		result = [NSApp runModalForWindow:_coloredProportionalSymbolPanel];
	}
	
}



-(void)choroplethMapStylePrepareDialog
{
	TMLayer *layer = [self selectedLayer];
	TMChoroplethStyle *style = (TMChoroplethStyle*)[layer style];
	
	
	// Generate the attribute menu.
	NSString *selAttr = [(TMChoroplethStyle*)style attributeName];
	[_choroplethAttributeMenu removeAllItems];
	[_choroplethAttributeMenu addItemWithTitle:@"<none>"];
	[_choroplethAttributeMenu selectItemWithTitle:@"<none>"];

	// Add all numerical attributes to the menu.
	if ([layer countOfFeatures] > 0)
	{
		TMFeature *feat = [layer objectInFeaturesAtIndex:0];
		NSMutableDictionary *attrs = [feat attributes];
		for (NSString *attrKey in attrs)
		{
			id attr = [feat attributeForKey:attrKey];
			if ([attr isKindOfClass:[NSNumber class]])
			{
				[_choroplethAttributeMenu addItemWithTitle:attrKey];
				if ([attrKey compare:selAttr] == NSOrderedSame)
					[_choroplethAttributeMenu selectItemWithTitle:attrKey];
			}
		}
	}
	
	
	
	// Generate the classification menu.
	NSString *selCf = [[(TMChoroplethStyle*)style classification] name];
	[_choroplethClassificationMenu removeAllItems];
	[_choroplethClassificationMenu addItemWithTitle:@"<none>"];
	[_choroplethClassificationMenu selectItemWithTitle:@"<none>"];
	
	// Get the array with all classifications
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	NSMutableArray *classifications = [doc classifications];
	if (classifications != nil)
	{
		for (TMClassification *cf in classifications)
		{
			NSString *cfName = [cf name];
			[_choroplethClassificationMenu addItemWithTitle:cfName];
			if (selCf != nil && [selCf compare:cfName] == NSOrderedSame)
				[_choroplethClassificationMenu selectItemWithTitle:cfName];
		}
	}
	
	
	// Set the feature style (only the border).
	[_choroplethDrawContourButton setState:[style drawBorder]];
	if ([style drawBorder])
	{
		// Enable the border parameters.
		[_choroplethLineWidthLabel setTextColor:[NSColor blackColor]];
		[_choroplethLineWidthField setEnabled:YES];
		[_choroplethLineColorLabel setTextColor:[NSColor blackColor]];
		[_choroplethLineColorWell setEnabled:YES];

		// Set the values.
		[_choroplethLineWidthField setDoubleValue:[style borderWidth]];
		[_choroplethLineColorWell setColor:[style borderColor]];
	}
	else
	{
		// Disable the border parameters.
		[_choroplethLineWidthLabel setTextColor:[NSColor grayColor]];
		[_choroplethLineWidthField setEnabled:NO];
		[_choroplethLineColorLabel setTextColor:[NSColor grayColor]];
		[_choroplethLineColorWell setEnabled:NO];
	}
	
}




-(void)proportionalSymbolStylePrepareDialog
{

	TMLayer *layer = [self selectedLayer];
	TMProportionalSymbolStyle *style = (TMProportionalSymbolStyle*)[layer style];
	
	// Display the symbol type.
	[_propSymbolTypeView setPath:[style symbol]];
	
	// Generate the attribute menu.
	NSString *selAttr = [style attributeName];
	[_propSymbolAttributeMenu removeAllItems];
	[_propSymbolAttributeMenu addItemWithTitle:@"<none>"];
	[_propSymbolAttributeMenu selectItemWithTitle:@"<none>"];
	
	if ([layer countOfFeatures] > 0)
	{
		TMFeature *feat = [layer objectInFeaturesAtIndex:0];
		NSMutableDictionary *attrs = [feat attributes];
		for (NSString *attrKey in attrs)
		{
			id attr = [feat attributeForKey:attrKey];
			if ([attr isKindOfClass:[NSNumber class]])
			{
				[_propSymbolAttributeMenu addItemWithTitle:attrKey];
				if ([attrKey compare:selAttr] == NSOrderedSame)
					[_propSymbolAttributeMenu selectItemWithTitle:attrKey];
			}
		}
	}
	
	// Calibration size & value, bias
	[_propSymbolCalibrationSizeField setIntegerValue:[style calibrationSize]];
	[_propSymbolCalibrationValueField setDoubleValue:[[style calibrationValue] doubleValue]];
	[_propSymbolBiasField setDoubleValue:[[style bias] doubleValue]];
	
	// Symbol style: Draw contour button.
	[_propSymbolStyleDrawContourButton setState:[[style symbolStyle] drawBorder]];
	if ([[style symbolStyle] drawBorder] == YES)
	{
		[_propSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleLineWidthField setEnabled:YES];
		[_propSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleLineColorWell setEnabled:YES];
	}
	else
	{
		[_propSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleLineWidthField setEnabled:NO];
		[_propSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleLineColorWell setEnabled:NO];
	}
	
	// Symbol style: line width and color.
	[_propSymbolStyleLineWidthField setDoubleValue:[[style symbolStyle] borderWidth]];
	[_propSymbolStyleLineColorWell setColor:[[style symbolStyle] borderColor]];
	
	// Symbol style: Fill feature button.
	[_propSymbolStyleFillFeatureButton setState:[[style symbolStyle] fillFeature]];
	if ([[style symbolStyle] fillFeature])
	{
		[_propSymbolStyleFillColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleFillColorWell setEnabled:YES];
	}
	else
	{
		[_propSymbolStyleFillColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleFillColorWell setEnabled:NO];
	}
	
	// Symbol style: fill color.
	[_propSymbolStyleFillColorWell setColor:[[style symbolStyle] fillColor]];
	
	
	// Feature style: draw contour button.
	[_propSymbolFeatureDrawContourButton setState:[[style featureStyle] drawBorder]];
	if ([[style featureStyle] drawBorder])
	{
		[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureLineWidthField setEnabled:YES];
		[_propSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureLineColorWell setEnabled:YES];
	}
	else
	{
		[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureLineWidthField setEnabled:NO];
		[_propSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureLineColorWell setEnabled:NO];
	}
	
	
	// Feature style: line width and color.
	[_propSymbolFeatureLineWidthField setDoubleValue:[[style featureStyle] borderWidth]];
	[_propSymbolFeatureLineColorWell setColor:[[style featureStyle] borderColor]];
	
	// Feature style: fill feature button.
	[_propSymbolFeatureFillFeatureButton setState:[[style featureStyle] fillFeature]];
	if ([[style featureStyle] fillFeature])
	{
		[_propSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureFillColorWell setEnabled:YES];
	}
	else
	{
		[_propSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureFillColorWell setEnabled:NO];
	}
	
	
	// Feature style: fill color.
	[_propSymbolFeatureFillColorWell setColor:[[style featureStyle] fillColor]];
	
}



-(void)coloredProportionalSymbolStylePrepareDialog
{
	TMLayer *layer = [self selectedLayer];
	TMColoredProportionalSymbolStyle *style = (TMColoredProportionalSymbolStyle*)[layer style];
	TMProportionalSymbolStyle *pstyle = [style proportionalSymbolStyle];
	TMChoroplethStyle *cstyle = [style choroplethStyle];
	
	
	// Display the symbol type.
	[_colPropSymbolTypeView setPath:[pstyle symbol]];
	
	// Generate the attribute menu.
	NSString *selAttr = [pstyle attributeName];
	[_colPropSymbolAttributeMenu removeAllItems];
	[_colPropSymbolAttributeMenu addItemWithTitle:@"<none>"];
	[_colPropSymbolAttributeMenu selectItemWithTitle:@"<none>"];
	
	if ([layer countOfFeatures] > 0)
	{
		TMFeature *feat = [layer objectInFeaturesAtIndex:0];
		NSMutableDictionary *attrs = [feat attributes];
		for (NSString *attrKey in attrs)
		{
			id attr = [feat attributeForKey:attrKey];
			if ([attr isKindOfClass:[NSNumber class]])
			{
				[_colPropSymbolAttributeMenu addItemWithTitle:attrKey];
				if ([attrKey compare:selAttr] == NSOrderedSame)
					[_colPropSymbolAttributeMenu selectItemWithTitle:attrKey];
			}
		}
	}
	
	// Calibration size & value, bias
	[_colPropSymbolCalibrationSizeField setIntegerValue:[pstyle calibrationSize]];
	[_colPropSymbolCalibrationValueField setDoubleValue:[[pstyle calibrationValue] doubleValue]];
	[_colPropSymbolBiasField setDoubleValue:[[pstyle bias] doubleValue]];
	
	
	
	// Symbol color:
	
	// Generate the attribute menu.
	selAttr = [cstyle attributeName];
	[_colPropSymbolFillAttributeMenu removeAllItems];
	[_colPropSymbolFillAttributeMenu addItemWithTitle:@"<none>"];
	[_colPropSymbolFillAttributeMenu selectItemWithTitle:@"<none>"];
	
	// Add all numerical attributes to the menu.
	if ([layer countOfFeatures] > 0)
	{
		TMFeature *feat = [layer objectInFeaturesAtIndex:0];
		NSMutableDictionary *attrs = [feat attributes];
		for (NSString *attrKey in attrs)
		{
			id attr = [feat attributeForKey:attrKey];
			if ([attr isKindOfClass:[NSNumber class]])
			{
				[_colPropSymbolFillAttributeMenu addItemWithTitle:attrKey];
				if ([attrKey compare:selAttr] == NSOrderedSame)
					[_colPropSymbolFillAttributeMenu selectItemWithTitle:attrKey];
			}
		}
	}
	
	
	
	// Generate the classification menu.
	NSString *selCf = [[cstyle classification] name];
	[_colPropSymbolFillClassificationMenu removeAllItems];
	[_colPropSymbolFillClassificationMenu addItemWithTitle:@"<none>"];
	[_colPropSymbolFillClassificationMenu selectItemWithTitle:@"<none>"];
	
	// Get the array with all classifications
	TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	NSMutableArray *classifications = [doc classifications];
	if (classifications != nil)
	{
		for (TMClassification *cf in classifications)
		{
			NSString *cfName = [cf name];
			[_colPropSymbolFillClassificationMenu addItemWithTitle:cfName];
			if (selCf != nil && [selCf compare:cfName] == NSOrderedSame)
				[_colPropSymbolFillClassificationMenu selectItemWithTitle:cfName];
		}
	}

	
	
	
	// Symbol style: Draw contour button.
	[_colPropSymbolStyleDrawContourButton setState:[[pstyle symbolStyle] drawBorder]];
	if ([[pstyle symbolStyle] drawBorder] == YES)
	{
		[_colPropSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
		[_colPropSymbolStyleLineWidthField setEnabled:YES];
		[_colPropSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
		[_colPropSymbolStyleLineColorWell setEnabled:YES];
	}
	else
	{
		[_colPropSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
		[_colPropSymbolStyleLineWidthField setEnabled:NO];
		[_colPropSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
		[_colPropSymbolStyleLineColorWell setEnabled:NO];
	}
	
	// Symbol style: line width and color.
	[_colPropSymbolStyleLineWidthField setDoubleValue:[[pstyle symbolStyle] borderWidth]];
	[_colPropSymbolStyleLineColorWell setColor:[[pstyle symbolStyle] borderColor]];
	
	
	// Feature style: draw contour button.
	[_colPropSymbolFeatureDrawContourButton setState:[[pstyle featureStyle] drawBorder]];
	if ([[pstyle featureStyle] drawBorder])
	{
		[_colPropSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
		[_colPropSymbolFeatureLineWidthField setEnabled:YES];
		[_colPropSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
		[_colPropSymbolFeatureLineColorWell setEnabled:YES];
	}
	else
	{
		[_colPropSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
		[_colPropSymbolFeatureLineWidthField setEnabled:NO];
		[_colPropSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
		[_colPropSymbolFeatureLineColorWell setEnabled:NO];
	}
	
	
	// Feature style: line width and color.
	[_colPropSymbolFeatureLineWidthField setDoubleValue:[[pstyle featureStyle] borderWidth]];
	[_colPropSymbolFeatureLineColorWell setColor:[[pstyle featureStyle] borderColor]];
	
	// Feature style: fill feature button.
	[_colPropSymbolFeatureFillFeatureButton setState:[[pstyle featureStyle] fillFeature]];
	if ([[pstyle featureStyle] fillFeature])
	{
		[_colPropSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
		[_colPropSymbolFeatureFillColorWell setEnabled:YES];
	}
	else
	{
		[_colPropSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
		[_colPropSymbolFeatureFillColorWell setEnabled:NO];
	}
	
	
	// Feature style: fill color.
	[_colPropSymbolFeatureFillColorWell setColor:[[pstyle featureStyle] fillColor]];
	
}




-(IBAction)simpleFillStyleTerminate:(id)sender
{
	
	if ([sender tag] == 1)
	{
	
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		if (doc == nil)
		{
			NSLog(@"[TMLayerPanelController simpleFillStyleTerminate:] Current document not found.");
			return;
		}

		[doc logCommand:@"\"Setting simple fill style attributes for selected layer\"\n"];


		// Get the index of the selected layer.
		NSInteger iSelLayer = [self indexOfSelectedLayer];
		if (iSelLayer < 0)
		{
			NSLog(@"[TMLayerPanelController simpleFillStyleTerminate:] No selected layer found.");
			return;
		}

		[doc executeCommand:[NSString stringWithFormat:@"_style := ((_doc layers) objectAtIndex:%i) style.", iSelLayer]];

		// Setting the border style attributes.
		[doc executeCommand:[NSString stringWithFormat:@"_style setDrawBorder:%i.", [_fillStyleDrawContourButton state]]];
		if ([_fillStyleDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"_style setBorderWidth:%f.", [_fillStyleLineWidthField doubleValue]]];
			//NSColor *clr1 = [NSColor colorWithDeviceCyan:0.0 magenta:0.0 yellow:0.0 black:0.0 alpha:1.0];
			NSColor *clr1 = [_fillStyleLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			
			[doc executeCommand:[NSString stringWithFormat:@"_style setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}

		// Setting the fill style attributes.
		[doc executeCommand:[NSString stringWithFormat:@"_style setFillFeature:%i.", [_fillStyleFillFeatureButton state]]];
		if ([_fillStyleFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_fillStyleFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			
			[doc executeCommand:[NSString stringWithFormat:@"_style setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}

		[doc logCommand:@"\n"];
	
	}
	
	
	[NSApp stopModal];
	[_simpleFillStylePanel orderOut:sender];
}




-(IBAction)simpleSymbolStyleTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		if (doc == nil)
		{
			NSLog(@"[TMLayerPanelController simpleFillStyleTerminate:] Current document not found.");
			return;
		}
		
		[doc logCommand:@"\"Setting simple symbol style attributes for selected layer\"\n"];
		
		
		// Get the index of the selected layer.
		NSInteger iSelLayer = [self indexOfSelectedLayer];
		if (iSelLayer < 0)
		{
			NSLog(@"[TMLayerPanelController simpleFillStyleTerminate:] No selected layer found.");
			return;
		}
		
		[doc executeCommand:[NSString stringWithFormat:@"_style := ((_doc layers) objectAtIndex:%i) style.", iSelLayer]];
		[doc executeCommand:[_simpleSymbolTypeView pathAsFScriptString:@"_bezier"]];
		[doc executeCommand:@"_style setSymbol:_bezier."];
		[doc executeCommand:[NSString stringWithFormat:@"_style setSymbolWidth:%i.", [_simpleSymbolWidth integerValue]]];
		[doc executeCommand:[NSString stringWithFormat:@"_style setSymbolHeight:%i.", [_simpleSymbolHeight integerValue]]];
		
		[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setDrawBorder:%i.",
							 [_simpleSymbolStyleDrawContourButton state]]];
		if ([_simpleSymbolStyleDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setBorderWidth:%f.",
								 [_simpleSymbolStyleLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_simpleSymbolStyleLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setFillFeature:%i.",
							 [_simpleSymbolStyleFillFeatureButton state]]];
		if ([_simpleSymbolStyleFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_simpleSymbolStyleFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		// Update the feature style
		[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setDrawBorder:%i.",
							 [_simpleSymbolFeatureDrawContourButton state]]];
		if ([_simpleSymbolFeatureDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setBorderWidth:%f.",
								 [_simpleSymbolFeatureLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_simpleSymbolFeatureLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setFillFeature:%i.",
							 [_simpleSymbolFeatureFillFeatureButton state]]];
		if ([_simpleSymbolFeatureFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_simpleSymbolFeatureFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		[doc logCommand:@"\n"];
		
	}
	[NSApp stopModal];
	[_simpleSymbolPanel orderOut:sender];
}


-(IBAction)choroplethMapStyleTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		[doc logCommand:@"\"Setting choropleth map style attributes for selected layer\"\n"];
		
		
		// Get the style of the currently selected layer.
		NSInteger iSelLayer = [self indexOfSelectedLayer];
		if (iSelLayer < 0)
		{
			NSLog(@"[TMLayerPanelController choroplethMapStyleTerminate:] No selected layer found.");
			return;
		}
		[doc executeCommand:[NSString stringWithFormat:@"_style := ((_doc layers) objectAtIndex:%i) style.", iSelLayer]];
		
		
		// Get the attribute name.
		NSString *selAttr = [[_choroplethAttributeMenu selectedItem] title];
		if ([selAttr compare:@"<none>"] == NSOrderedSame) selAttr = @"";
		[doc executeCommand:[NSString stringWithFormat:@"_style setAttributeName:'%@'.", selAttr]];
		
		
		// Classification.
		[doc executeCommand:[NSString stringWithFormat:@"_style setClassification:(_doc classificationWithName:'%@').",
							 [[_choroplethClassificationMenu selectedItem] title]]];

		
		// Contour.
		[doc executeCommand:[NSString stringWithFormat:@"_style setDrawBorder:%i.", [_choroplethDrawContourButton state]]];
		if ([_choroplethDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"_style setBorderWidth:%f.",
								 [_choroplethLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_choroplethLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"_style setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		[doc logCommand:@"\n"];
	}
	[NSApp stopModal];
	[_choroplethMapPanel orderOut:sender];
}





-(IBAction)proportionalSymbolStyleTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		if (doc == nil)
		{
			NSLog(@"[TMLayerPanelController proportionalSymbolStyleTerminate:] Current document not found.");
			return;
		}
		
		[doc logCommand:@"\"Setting proportional symbol style attributes for selected layer\"\n"];
		
		
		// Get the index of the selected layer.
		NSInteger iSelLayer = [self indexOfSelectedLayer];
		if (iSelLayer < 0)
		{
			NSLog(@"[TMLayerPanelController proportionalSymbolStyleTerminate:] No selected layer found.");
			return;
		}
		
		
		// Set the symbol type.
		[doc executeCommand:[NSString stringWithFormat:@"_style := ((_doc layers) objectAtIndex:%i) style.", iSelLayer]];
		[doc executeCommand:[_propSymbolTypeView pathAsFScriptString:@"_bezier"]];
		[doc executeCommand:@"_style setSymbol:_bezier."];
		
		
		// Get the attribute name.
		NSString *selAttr = [[_propSymbolAttributeMenu selectedItem] title];
		if ([selAttr compare:@"<none>"] == NSOrderedSame) selAttr = @"";
		[doc executeCommand:[NSString stringWithFormat:@"_style setAttributeName:'%@'.", selAttr]];
		
		
		// Calibration size, value and bias.
		[doc executeCommand:[NSString stringWithFormat:@"_style setCalibrationValue:%f.",
							 [_propSymbolCalibrationValueField doubleValue]]];
		[doc executeCommand:[NSString stringWithFormat:@"_style setCalibrationSize:%i.",
							 [_propSymbolCalibrationSizeField integerValue]]];
		[doc executeCommand:[NSString stringWithFormat:@"_style setBias:'%f'.",
							 [_propSymbolBiasField doubleValue]]];
		
		
		// Symbol style: contour.
		[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setDrawBorder:%i.", 
							 [_propSymbolStyleDrawContourButton state]]];
		if ([_propSymbolStyleDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setBorderWidth:%f.",
								 [_propSymbolStyleLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_propSymbolStyleLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		// Symbol style: fill color.
		[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setFillFeature:%i.", 
							 [_propSymbolStyleFillFeatureButton state]]];
		if ([_propSymbolStyleFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_propSymbolStyleFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style symbolStyle) setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		
		// Feature style: contour.
		[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setDrawBorder:%i.", 
							 [_propSymbolFeatureDrawContourButton state]]];
		if ([_propSymbolFeatureDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setBorderWidth:%f.",
								 [_propSymbolFeatureLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_propSymbolFeatureLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		// Feature style: fill color.
		[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setFillFeature:%i.", 
							 [_propSymbolFeatureFillFeatureButton state]]];
		if ([_propSymbolFeatureFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_propSymbolFeatureFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"(_style featureStyle) setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		[doc logCommand:@"\n"];
		
	}
	[NSApp stopModal];
	[_proportionalSymbolPanel orderOut:sender];
}





-(IBAction)coloredProportionalSymbolStyleTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		
		TMDocument *doc = [[NSDocumentController sharedDocumentController] currentDocument];
		if (doc == nil)
		{
			NSLog(@"[TMLayerPanelController coloredProportionalSymbolStyleTerminate:] Current document not found.");
			return;
		}
		
		[doc logCommand:@"\"Setting colored proportional symbol style attributes for selected layer\"\n"];
		
		
		// Get the index of the selected layer.
		NSInteger iSelLayer = [self indexOfSelectedLayer];
		if (iSelLayer < 0)
		{
			NSLog(@"[TMLayerPanelController coloredProportionalSymbolStyleTerminate:] No selected layer found.");
			return;
		}
		
		
		// Set the symbol type.
		[doc executeCommand:[NSString stringWithFormat:@"_style := ((_doc layers) objectAtIndex:%i) style.", iSelLayer]];
		[doc executeCommand:[_colPropSymbolTypeView pathAsFScriptString:@"_bezier"]];
		[doc executeCommand:@"(_style proportionalSymbolStyle) setSymbol:_bezier."];
		
		
		// Get the attribute name.
		NSString *selAttr = [[_colPropSymbolAttributeMenu selectedItem] title];
		if ([selAttr compare:@"<none>"] == NSOrderedSame) selAttr = @"";
		[doc executeCommand:[NSString stringWithFormat:@"(_style proportionalSymbolStyle) setAttributeName:'%@'.", selAttr]];
		
		
		// Calibration size, value and bias.
		[doc executeCommand:[NSString stringWithFormat:@"(_style proportionalSymbolStyle) setCalibrationValue:%f.",
							 [_colPropSymbolCalibrationValueField doubleValue]]];
		[doc executeCommand:[NSString stringWithFormat:@"(_style proportionalSymbolStyle) setCalibrationSize:%i.",
							 [_colPropSymbolCalibrationSizeField integerValue]]];
		[doc executeCommand:[NSString stringWithFormat:@"(_style proportionalSymbolStyle) setBias:'%f'.",
							 [_colPropSymbolBiasField doubleValue]]];
		
		
		// Symbol style: contour.
		[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) symbolStyle) setDrawBorder:%i.", 
							 [_colPropSymbolStyleDrawContourButton state]]];
		if ([_colPropSymbolStyleDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) symbolStyle) setBorderWidth:%f.",
								 [_colPropSymbolStyleLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_colPropSymbolStyleLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) symbolStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		
		
		// Symbol style: fill color (choropleth map).
		
		// Get the attribute name.
		selAttr = [[_colPropSymbolFillAttributeMenu selectedItem] title];
		if ([selAttr compare:@"<none>"] == NSOrderedSame) selAttr = @"";
		[doc executeCommand:[NSString stringWithFormat:@"(_style choroplethStyle) setAttributeName:'%@'.", selAttr]];
		
		
		// Classification.
		[doc executeCommand:[NSString stringWithFormat:@"(_style choroplethStyle) setClassification:(_doc classificationWithName:'%@').",
							 [[_colPropSymbolFillClassificationMenu selectedItem] title]]];
		
		
		
		
		// Feature style: contour.
		[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) featureStyle) setDrawBorder:%i.", 
							 [_colPropSymbolFeatureDrawContourButton state]]];
		if ([_colPropSymbolFeatureDrawContourButton state] == NSOnState)
		{
			[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) featureStyle) setBorderWidth:%f.",
								 [_colPropSymbolFeatureLineWidthField doubleValue]]];
			
			NSColor *clr1 = [_colPropSymbolFeatureLineColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) featureStyle) setBorderColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		// Feature style: fill color.
		[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) featureStyle) setFillFeature:%i.", 
							 [_colPropSymbolFeatureFillFeatureButton state]]];
		if ([_colPropSymbolFeatureFillFeatureButton state] == NSOnState)
		{
			NSColor *clr1 = [_colPropSymbolFeatureFillColorWell color];
			NSColor *clr = [clr1 colorUsingColorSpaceName:@"NSDeviceCMYKColorSpace"];
			CGFloat cyan = round([clr cyanComponent] * 100) / 100;
			CGFloat magenta = round([clr magentaComponent] * 100) / 100;
			CGFloat yellow = round([clr yellowComponent] * 100) / 100;
			CGFloat black = round([clr blackComponent] * 100) / 100;
			CGFloat alpha = round([clr alphaComponent] * 100) / 100;
			[doc executeCommand:[NSString stringWithFormat:@"((_style proportionalSymbolStyle) featureStyle) setFillColor:(NSColor colorWithDeviceCyan:%0.2f magenta:%0.2f yellow:%0.2f black:%0.2f alpha:%0.2f).",
								 cyan, magenta, yellow, black, alpha]];
		}
		
		
		[doc logCommand:@"\n"];

		
	}
	[NSApp stopModal];
	[_coloredProportionalSymbolPanel orderOut:sender];
}





#pragma mark --- Simple Fill Style Panel ---



-(IBAction)fillStyleDrawContourChanged:(id)sender
{
	TMFillStyle *style = (TMFillStyle*)[[self selectedLayer] style];
	if ([sender state] == NSOnState)
	{
		[style setDrawBorder:YES];
		[_fillStyleLineWidthField setEnabled:YES];
		[_fillStyleLineColorWell setEnabled:YES];
		[_fillStyleLineWidthLabel setTextColor:[NSColor blackColor]];
		[_fillStyleLineColorLabel setTextColor:[NSColor blackColor]];
	}
	else
	{
		[style setDrawBorder:NO];
		[_fillStyleLineWidthField setEnabled:NO];
		[_fillStyleLineColorWell setEnabled:NO];
		[_fillStyleLineWidthLabel setTextColor:[NSColor grayColor]];
		[_fillStyleLineColorLabel setTextColor:[NSColor grayColor]];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)fillStyleLineColorChanged:(id)sender
{
	TMFillStyle *style = (TMFillStyle*)[[self selectedLayer] style];
	[style setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)fillStyleFillFeatureChanged:(id)sender
{
	TMFillStyle *style = (TMFillStyle*)[[self selectedLayer] style];
	if ([sender state] == NSOnState)
	{
		[style setFillFeature:YES];
		[_fillStyleFillColorWell setEnabled:YES];
		[_fillStyleFillColorLabel setTextColor:[NSColor blackColor]];
	}
	else
	{
		[style setFillFeature:NO];
		[_fillStyleFillColorWell setEnabled:NO];
		[_fillStyleFillColorLabel setTextColor:[NSColor grayColor]];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)fillStyleFillColorChanged:(id)sender
{
	TMFillStyle *style = (TMFillStyle*)[[self selectedLayer] style];
	[style setFillColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}





#pragma mark --- Simple Symbol Style Panel ---


-(IBAction)chooseSymbol:(id)sender
{
	[NSApp beginSheet:_simpleSymbolChooseWindow 
		modalForWindow:_simpleSymbolPanel
		modalDelegate:nil 
	    didEndSelector:nil 
		contextInfo:nil];
}



-(IBAction)chooseSymbolDidEnd:(id)sender
{
	NSInteger selectedSymbol = [_symbolTypeMatrix selectedColumn];
	
	NSBezierPath *path;
	//TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	NSRect rect = NSMakeRect(3, 3, 22, 22);
	
	if (selectedSymbol == 0)
		path = [NSBezierPath bezierPathWithOvalInRect:rect];
	
	if (selectedSymbol == 1)
		path = [NSBezierPath bezierPathWithRect:rect];
	
	if (selectedSymbol == 2)
	{
		NSBezierPath *hexagon = [NSBezierPath bezierPath];
		[hexagon moveToPoint:NSMakePoint(6.1f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(21.2f, 11.2f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(6.1f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(1.1f, 11.2f)];
		[hexagon closePath];
		path = hexagon;
	}
	
	if (selectedSymbol == 3)
	{
		NSBezierPath *triangle = [NSBezierPath bezierPath];
		[triangle moveToPoint:NSMakePoint(11.0f, 21.5f)];
		[triangle lineToPoint:NSMakePoint(21.5f, 0.5f)];
		[triangle lineToPoint:NSMakePoint(0.5f, 0.5f)];
		[triangle closePath];
		path = triangle;
	}
	
	
	// Update the symbol type view.
	[_simpleSymbolTypeView setPath:path];
	[_simpleSymbolTypeView setNeedsDisplay:YES];
	
	[self chooseSymbolClose:sender];
	
	//[self updateStyleSettingsWithLayer:[self selectedLayer]];
	
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	//[[doc page] setNeedsDisplay:YES];
}


-(IBAction)chooseSymbolClose:(id)sender
{	
	[NSApp endSheet:_simpleSymbolChooseWindow];
	[_simpleSymbolChooseWindow orderOut:sender];
}



-(IBAction)simpleSymbolStyleDrawContourChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	if ([sender state] == NSOnState)
	{
		[symbolStyle setDrawBorder:YES];
		[_simpleSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolStyleLineWidthField setEnabled:YES];
		[_simpleSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolStyleLineColorWell setEnabled:YES];
	}
	else
	{
		[symbolStyle setDrawBorder:NO];
		[_simpleSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolStyleLineWidthField setEnabled:NO];
		[_simpleSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolStyleLineColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)simpleSymbolStyleLineColorChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	[symbolStyle setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)simpleSymbolStyleFillFeatureChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	if ([sender state] == NSOnState)
	{
		[symbolStyle setFillFeature:YES];
		[_simpleSymbolStyleFillColorLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolStyleFillColorWell setEnabled:YES];
	}
	else
	{
		[symbolStyle setFillFeature:NO];
		[_simpleSymbolStyleFillColorLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolStyleFillColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)simpleSymbolStyleFillColorChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	[symbolStyle setFillColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)simpleSymbolFeatureDrawContourChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	if ([sender state] == NSOnState)
	{
		[featureStyle setDrawBorder:YES];
		[_simpleSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolFeatureLineWidthField setEnabled:YES];
		[_simpleSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolFeatureLineColorWell setEnabled:YES];
	}
	else
	{
		[featureStyle setDrawBorder:NO];
		[_simpleSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolFeatureLineWidthField setEnabled:NO];
		[_simpleSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolFeatureLineColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}




-(IBAction)simpleSymbolFeatureLineColorChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	[featureStyle setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)simpleSymbolFeatureFillFeatureChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	if ([sender state] == NSOnState)
	{
		[featureStyle setFillFeature:YES];
		[_simpleSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
		[_simpleSymbolFeatureFillColorWell setEnabled:YES];
	}
	else
	{
		[featureStyle setFillFeature:NO];
		[_simpleSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
		[_simpleSymbolFeatureFillColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}




-(IBAction)simpleSymbolFeatureFillColorChanged:(id)sender
{
	TMSymbolStyle *style = (TMSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	[featureStyle setFillColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}






#pragma mark --- Choropleth Map Style Panel ---


-(IBAction)choroplethAttributeChanged:(id)sender
{
	TMChoroplethStyle *style = (TMChoroplethStyle*)[[self selectedLayer] style];
	NSString *selAttr = [[sender selectedItem] title];
	if ([selAttr compare:@"<none>"] == NSOrderedSame)
		[style setAttributeName:nil];
	else
		[style setAttributeName:selAttr];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)choroplethClassificationChanged:(id)sender
{
	TMChoroplethStyle *style = (TMChoroplethStyle*)[[self selectedLayer] style];
	NSString *selCf = [[sender selectedItem] title];
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	if ([selCf compare:@"<none>"] == NSOrderedSame)
		[style setClassification:nil];
	else
	{
		id cf = [doc classificationWithName:selCf];
		[style setClassification:cf];
	}
	
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)choroplethDrawContourChanged:(id)sender
{
	//TMChoroplethStyle *style = (TMChoroplethStyle*)[[self selectedLayer] style];
	if ([sender state] == NSOnState)
	{
		//[style setDrawBorder:YES];
		[_choroplethLineWidthField setEnabled:YES];
		[_choroplethLineColorWell setEnabled:YES];
		[_choroplethLineWidthLabel setTextColor:[NSColor blackColor]];
		[_choroplethLineColorLabel setTextColor:[NSColor blackColor]];
	}
	else
	{
		//[style setDrawBorder:NO];
		[_choroplethLineWidthField setEnabled:NO];
		[_choroplethLineColorWell setEnabled:NO];
		[_choroplethLineWidthLabel setTextColor:[NSColor grayColor]];
		[_choroplethLineColorLabel setTextColor:[NSColor grayColor]];
	}
	
	//TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	//[[doc page] setNeedsDisplay:YES];
}



-(IBAction)choroplethLineColorChanged:(id)sender
{
	TMChoroplethStyle *style = (TMChoroplethStyle*)[[self selectedLayer] style];
	[style setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}






#pragma mark --- Proportional Symbol Style Panel ---


-(IBAction)choosePropSymbol:(id)sender
{
	[NSApp beginSheet:_propSymbolChooseWindow 
		modalForWindow:_proportionalSymbolPanel
		modalDelegate:nil 
	    didEndSelector:nil 
		contextInfo:nil];
}


-(IBAction)choosePropSymbolDidEnd:(id)sender
{
	NSInteger selectedSymbol = [_propSymbolTypeMatrix selectedColumn];
	
	NSBezierPath *path;
	NSRect rect = NSMakeRect(3, 3, 22, 22);
	
	if (selectedSymbol == 0)
		path = [NSBezierPath bezierPathWithOvalInRect:rect];
	
	if (selectedSymbol == 1)
		path = [NSBezierPath bezierPathWithRect:rect];
	
	if (selectedSymbol == 2)
	{
		NSBezierPath *hexagon = [NSBezierPath bezierPath];
		[hexagon moveToPoint:NSMakePoint(6.1f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(21.2f, 11.2f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(6.1f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(1.1f, 11.2f)];
		[hexagon closePath];
		path = hexagon;
	}
	
	if (selectedSymbol == 3)
	{
		NSBezierPath *triangle = [NSBezierPath bezierPath];
		[triangle moveToPoint:NSMakePoint(11.0f, 21.5f)];
		[triangle lineToPoint:NSMakePoint(21.5f, 0.5f)];
		[triangle lineToPoint:NSMakePoint(0.5f, 0.5f)];
		[triangle closePath];
		path = triangle;
	}
	
	
	// Update the symbol type view.
	[_propSymbolTypeView setPath:path];
	[_propSymbolTypeView setNeedsDisplay:YES];
		
	[self choosePropSymbolClose:sender];
}




-(IBAction)choosePropSymbolClose:(id)sender
{
	[NSApp endSheet:_propSymbolChooseWindow];
	[_propSymbolChooseWindow close];
}



-(IBAction)propSymbolAttributeChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	
	NSString *selAttr = [[sender selectedItem] title];
	if ([selAttr compare:@"<none>"] == NSOrderedSame)
		[style setAttributeName:nil];
	else
		[style setAttributeName:selAttr];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolStyleDrawContourChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	if ([sender state] == NSOnState)
	{
		[symbolStyle setDrawBorder:YES];
		[_propSymbolStyleLineWidthLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleLineWidthField setEnabled:YES];
		[_propSymbolStyleLineColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleLineColorWell setEnabled:YES];
	}
	else
	{
		[symbolStyle setDrawBorder:NO];
		[_propSymbolStyleLineWidthLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleLineWidthField setEnabled:NO];
		[_propSymbolStyleLineColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleLineColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}




-(IBAction)propSymbolStyleLineColorChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	[symbolStyle setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolStyleFillFeatureChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	if ([sender state] == NSOnState)
	{
		[symbolStyle setFillFeature:YES];
		[_propSymbolStyleFillColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolStyleFillColorWell setEnabled:YES];
	}
	else
	{
		[symbolStyle setFillFeature:NO];
		[_propSymbolStyleFillColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolStyleFillColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];

}



-(IBAction)propSymbolStyleFillColorChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *symbolStyle = [style symbolStyle];
	[symbolStyle setFillColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolFeatureDrawContourChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	if ([sender state] == NSOnState)
	{
		[featureStyle setDrawBorder:YES];
		[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureLineWidthField setEnabled:YES];
		[_propSymbolFeatureLineColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureLineColorWell setEnabled:YES];
	}
	else
	{
		[featureStyle setDrawBorder:NO];
		[_propSymbolFeatureLineWidthLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureLineWidthField setEnabled:NO];
		[_propSymbolFeatureLineColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureLineColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolFeatureLineColorChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	[featureStyle setBorderColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolFeatureFillFeatureChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	if ([sender state] == NSOnState)
	{
		[featureStyle setFillFeature:YES];
		[_propSymbolFeatureFillColorLabel setTextColor:[NSColor blackColor]];
		[_propSymbolFeatureFillColorWell setEnabled:YES];
	}
	else
	{
		[featureStyle setFillFeature:NO];
		[_propSymbolFeatureFillColorLabel setTextColor:[NSColor grayColor]];
		[_propSymbolFeatureFillColorWell setEnabled:NO];
	}
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)propSymbolFeatureFillColorChanged:(id)sender
{
	TMProportionalSymbolStyle *style = 
		(TMProportionalSymbolStyle*)[[self selectedLayer] style];
	TMFillStyle *featureStyle = [style featureStyle];
	[featureStyle setFillColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}








#pragma mark --- Colored Proportional Symbol Style ---



-(IBAction)chooseColPropSymbol:(id)sender
{
	[NSApp beginSheet:_colPropSymbolChooseWindow 
	   modalForWindow:_coloredProportionalSymbolPanel
		modalDelegate:nil 
	   didEndSelector:nil 
		  contextInfo:nil];
}


-(IBAction)chooseColPropSymbolDidEnd:(id)sender
{
	NSInteger selectedSymbol = [_colPropSymbolTypeMatrix selectedColumn];
	
	NSBezierPath *path;
	NSRect rect = NSMakeRect(3, 3, 22, 22);
	
	if (selectedSymbol == 0)
		path = [NSBezierPath bezierPathWithOvalInRect:rect];
	
	if (selectedSymbol == 1)
		path = [NSBezierPath bezierPathWithRect:rect];
	
	if (selectedSymbol == 2)
	{
		NSBezierPath *hexagon = [NSBezierPath bezierPath];
		[hexagon moveToPoint:NSMakePoint(6.1f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 19.9f)];
		[hexagon lineToPoint:NSMakePoint(21.2f, 11.2f)];
		[hexagon lineToPoint:NSMakePoint(16.2f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(6.1f, 2.5f)];
		[hexagon lineToPoint:NSMakePoint(1.1f, 11.2f)];
		[hexagon closePath];
		path = hexagon;
	}
	
	if (selectedSymbol == 3)
	{
		NSBezierPath *triangle = [NSBezierPath bezierPath];
		[triangle moveToPoint:NSMakePoint(11.0f, 21.5f)];
		[triangle lineToPoint:NSMakePoint(21.5f, 0.5f)];
		[triangle lineToPoint:NSMakePoint(0.5f, 0.5f)];
		[triangle closePath];
		path = triangle;
	}
	
	
	// Update the symbol type view.
	[_colPropSymbolTypeView setPath:path];
	[_colPropSymbolTypeView setNeedsDisplay:YES];
	
	[self chooseColPropSymbolClose:sender];
}




-(IBAction)chooseColPropSymbolClose:(id)sender
{
	[NSApp endSheet:_colPropSymbolChooseWindow];
	[_colPropSymbolChooseWindow close];
}




#pragma mark --- Attribute handling ---

-(IBAction)joinDataFile:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	
	NSArray *fileTypes = [NSArray arrayWithObjects:@"txt", @"csv", nil];
	
	[openPanel beginSheetForDirectory:nil file:nil 
								types:fileTypes modalForWindow:[self window] 
						modalDelegate:self 
					   didEndSelector:@selector(joinDataFileOpenDialogDidEnd:returnCode:contextInfo:)
						  contextInfo:nil];
}






-(void)joinDataFileOpenDialogDidEnd:(NSOpenPanel*)panel 
						 returnCode:(int)returnCode  
						contextInfo:(void*)contextInfo
{
	
	if (returnCode == NSOKButton)
	{
		NSString *file = [panel filename];
		[_joinDataFilePath setStringValue:file];
		
		// Read the variable names from the text file.
		FILE *fp = fopen([file fileSystemRepresentation], "r");
		char line[10240];
		fgets(line, 10240, fp);
		fclose(fp);
		NSString *firstLine = [NSString stringWithCString:line encoding:[NSString defaultCStringEncoding]];
		NSArray *varNames = [firstLine explodeUsing:@"\t"];
		
		// Populating the CSV field menu.
		[_joinDataFileCSVFieldMenu removeAllItems];
		[_joinDataFileCSVFieldMenu addItemWithTitle:@""];
		for (NSString *varName in varNames)
		{
			[_joinDataFileCSVFieldMenu addItemWithTitle:varName];
		}
		
		// Populating the attribute field menu.
		[_joinDataFileAttributeMenu removeAllItems];
		[_joinDataFileAttributeMenu addItemWithTitle:@""];
		TMLayer *lyr = [self selectedLayer];
		TMFeature *feat = [[lyr features] objectAtIndex:0];
		for (NSString *attrName in [[feat attributes] allKeys])
		{
			[_joinDataFileAttributeMenu addItemWithTitle:attrName];
		}
		
		[NSApp runModalForWindow:_joinDataFileDialog];
		
			  
	}
	

}



-(IBAction)joinDataFileTerminate:(id)sender
{
	
	if ([sender tag] == 1)
	{
		NSString *csvField = [[_joinDataFileCSVFieldMenu selectedItem] title];
		NSString *attr = [[_joinDataFileAttributeMenu selectedItem] title];
		
		if ([csvField compare:@""] == NSOrderedSame || [attr compare:@""] == NSOrderedSame)
		{
			TMDisplayError(@"Error joining data.", @"Please select a valid CSV field and feature attribute.");
		}
		else
		{
			TMLayer *lyr = [self selectedLayer];
			NSString *csvFile = [_joinDataFilePath stringValue];
			[lyr joinCSVFile:csvFile separator:'\t' featureAttribute:attr csvField:csvField];
			
			[self updatePanelWithLayer:[self selectedLayer]];
		}
	}
	
	
	[NSApp stopModal];
	[_joinDataFileDialog orderOut:sender];
}







@end
