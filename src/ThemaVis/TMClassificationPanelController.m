//
//  TMClassificationPanelController.m
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TMClassificationPanelController.h"
#import "TMColorTablePanelController.h"
#import "TMDocument.h"



@implementation TMClassificationPanelController




#pragma mark --- Creating the Panel Controller ---


+(id)sharedClassificationPanelController
{
    static TMClassificationPanelController *sharedClassificationPanelController = nil;
    if (!sharedClassificationPanelController)
	{
        sharedClassificationPanelController = [[TMClassificationPanelController allocWithZone:NULL] init];
    }
    return sharedClassificationPanelController;
}



-(id)init
{
    self = [self initWithWindowNibName:@"ClassificationPanel"];
	
    if (self)
	{
        [self setWindowFrameAutosaveName:@"ClassificationPanel"];
    }
    return self;
}




-(void)awakeFromNib
{
	[self updatePanel:self];
}



#pragma mark --- Updating the Panel Content ---

-(IBAction)updatePanel:(id)sender
{

	[_classificationList reloadData];
	
	
	// Get the selection of the classification list and adjust the
	// visibility of the other controls.
	
	NSInteger selClassification = [_classificationList selectedRow];
	if (selClassification == -1)
	{
		[_classificationTypeLabel setHidden:YES];
		[_classificationTypeMenu setHidden:YES];
		[_colorTableLabel setHidden:YES];
		[_colorTableMenu setHidden:YES];
		[_valueLabelScrollView setHidden:YES];
		[_hasNoValueButton setHidden:YES];
		[_noValueLabel setHidden:YES];
		[_noValueField setHidden:YES];
		[_noValueColorLabel setHidden:YES];
		[_noValueColorWell setHidden:YES];
		[_noSelectionLabel setHidden:NO];
		return;
	}
	else
	{
		[_noSelectionLabel setHidden:YES];
		[_classificationTypeLabel setHidden:NO];
		[_classificationTypeMenu setHidden:NO];
		[_colorTableLabel setHidden:NO];
		[_colorTableMenu setHidden:NO];
		[_valueLabelScrollView setHidden:NO];
		[_hasNoValueButton setHidden:NO];
		[_noValueLabel setHidden:NO];
		[_noValueField setHidden:NO];
		[_noValueColorLabel setHidden:NO];
		[_noValueColorWell setHidden:NO];
	}
	
	
	// Update classification type popup menu.
	id cf = [self selectedClassification];
	if (cf != nil)
	{
		if ([cf isMemberOfClass:[TMContinuousClassification class]])
			[_classificationTypeMenu selectItemWithTag:1];
		else if ([cf isMemberOfClass:[TMDiscreteClassification class]])
			[_classificationTypeMenu selectItemWithTag:2];
		else if ([cf isMemberOfClass:[TMGradientClassification class]])
			[_classificationTypeMenu selectItemWithTag:3];
	}
	
	
	// Update color table popup menu.
	TMColorTable *ct = [self selectedColorTable];
	[_colorTableMenu removeAllItems];
	[_colorTableMenu addItemWithTitle:@"<none>"];

	NSMutableArray *colorTables = 
		[[[NSApp orderedDocuments] objectAtIndex:0] colorTables];
		
	for (TMColorTable *ctArray in colorTables)
		[_colorTableMenu addItemWithTitle:[ctArray name]];
		
	if (ct == nil)
		[_colorTableMenu selectItemWithTitle:@"<none>"];
	else
		[_colorTableMenu selectItemWithTitle:[ct name]];
	
	
	// Update the No Data section.
	if (cf != nil && [cf hasNoDataValue])
	{
		[_hasNoValueButton setState:NSOnState];
		[_noValueLabel setTextColor:[NSColor blackColor]];
		[_noValueField setEnabled:YES];
		[_noValueColorLabel setTextColor:[NSColor blackColor]];
		[_noValueColorWell setEnabled:YES];
		[_noValueField setDoubleValue:[[cf noDataValue] doubleValue]];
		[_noValueColorWell setColor:[cf noDataColor]];
	}
	else
	{
		[_hasNoValueButton setState:NSOffState];
		[_noValueLabel setTextColor:[NSColor grayColor]];
		[_noValueField setEnabled:NO];
		[_noValueColorLabel setTextColor:[NSColor grayColor]];
		[_noValueColorWell setEnabled:NO];
	}

	[_valueLabelList reloadData];
}




#pragma mark --- Classification Handling ---


-(NSMutableArray*)classifications
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	return [document classifications];
}


-(IBAction)addClassification:(id)sender
{
	// By default, we add a continuous classification.
	TMContinuousClassification *cl = [[TMContinuousClassification alloc] init];
	if (cl == nil) return;
	[[self classifications] addObject:cl];
	[self updatePanel:sender];
}


-(IBAction)removeClassification:(id)sender
{
	NSInteger selClassification = [_classificationList selectedRow];
	if (selClassification < 0) return;
	[[self classifications] removeObjectAtIndex:selClassification];
	[self updatePanel:sender];
}


-(id)selectedClassification
{
	NSInteger selClassification = [_classificationList selectedRow];
	NSMutableArray *classifications = [self classifications];
	if (selClassification >= [classifications count]) return nil;
	return [[self classifications] objectAtIndex:selClassification];
}





-(IBAction)saveClassification:(id)sender
{

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Save classification"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setRequiredFileType:@"tmclasses"];
	[savePanel setCanSelectHiddenExtension:YES];
	
	[savePanel beginSheetForDirectory:nil 
		file:nil 
		modalForWindow:[self window] 
		modalDelegate:self 
		didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
		contextInfo:nil];
}



-(IBAction)openClassification:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	
	NSArray *fileTypes = 
		[NSArray arrayWithObjects:@"tmclasses", nil];
	
	[openPanel beginSheetForDirectory:nil file:nil 
		types:fileTypes modalForWindow:[self window] 
		modalDelegate:self 
		didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
		contextInfo:nil];
}



-(void)savePanelDidEnd:(NSSavePanel*)sheet 
	returnCode:(int)returnCode 
	contextInfo:(void *)contextInfo
{

	if (returnCode == NSOKButton)
	{
		id cf = [self selectedClassification];
		if (cf == nil) return;
	
		NSString *file = [sheet filename];
		[NSKeyedArchiver archiveRootObject:cf toFile:file];
	}

}



-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo
{

	if (returnCode == NSOKButton)
	{
		NSArray *files = [panel filenames];
		for (NSString *filePath in files)
		{
			id cf = 
				[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
			
			TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
			[doc addClassification:cf];
		}
		
		[self updatePanel:self];
	}
	
}





-(void)tableViewSelectionDidChange:(NSNotification*)aNotification
{
	[self updatePanel:self];
}






#pragma mark --- Classification Type Handling ---

-(IBAction)classificationTypeHasChanged:(id)sender
{
	// The current classification.
	NSInteger cfIndex = [_classificationList selectedRow];
	if (cfIndex < 0) return;
	TMClassification *cf = [[self classifications] objectAtIndex:cfIndex];
	
	// Get the classification type name through the menu.
	NSString *selType = [[_classificationTypeMenu selectedItem] title];
	
	// Create a new classification with the corresponding type.
	if ([selType compare:@"Continuous"] == NSOrderedSame)
	{
		TMContinuousClassification *ccf = 
			[[TMContinuousClassification alloc] init];
		
		[ccf setName:[cf name]];
		[ccf setDescription:[cf description]];
		
		if ([cf respondsToSelector:@selector(colorTable)])
		{
			TMColorTable *ct = [cf performSelector:@selector(colorTable)];
			[ccf setColorTable:ct];
		}
		
		if ([cf respondsToSelector:@selector(labels)])
		{
			NSMutableArray *labels = [cf performSelector:@selector(labels)];
			[ccf setLabels:labels];
		}
		
		if ([cf respondsToSelector:@selector(limits)])
		{
			NSMutableArray *limits = [cf performSelector:@selector(limits)];
			[ccf setLimits:limits];
		}
		
		if ([cf respondsToSelector:@selector(values)])
		{
			NSMutableArray *values = [cf performSelector:@selector(values)];
			[ccf setLimits:values];
		}
		
		NSUInteger ncols = [[ccf colorTable] countOfColors];
		NSUInteger nlimits = [ccf countOfLimits];
		NSUInteger nlabels = [ccf countOfLabels];
		NSUInteger i;
		if ((ncols-1) > nlimits)
		{
			for (i=nlimits; i < (ncols-1); i++)
				[ccf addObjectToLimits:[NSNumber numberWithDouble:0.0]];
		}
		
		if ((ncols-1) > nlabels)
		{
			for (i=nlabels; i < (ncols-1); i++)
				[ccf addObjectToLabels:@"New label"];
		}
		
		[[self classifications] replaceObjectAtIndex:cfIndex withObject:ccf];
		
	}
	else if ([selType compare:@"Discrete"] == NSOrderedSame)
	{
	
		TMDiscreteClassification *dcf = 
			[[TMDiscreteClassification alloc] init];
		
		[dcf setName:[cf name]];
		[dcf setDescription:[cf description]];
		
		if ([cf respondsToSelector:@selector(colorTable)])
		{
			TMColorTable *ct = [cf performSelector:@selector(colorTable)];
			[dcf setColorTable:ct];
		}
		
		if ([cf respondsToSelector:@selector(labels)])
		{
			NSMutableArray *labels = [cf performSelector:@selector(labels)];
			[dcf setLabels:labels];
		}
		
		if ([cf respondsToSelector:@selector(limits)])
		{
			NSMutableArray *limits = [cf performSelector:@selector(limits)];
			[dcf setValues:limits];
		}
		
		if ([cf respondsToSelector:@selector(values)])
		{
			NSMutableArray *values = [cf performSelector:@selector(values)];
			[dcf setValues:values];
		}
		
		NSUInteger ncols = [[dcf colorTable] countOfColors];
		NSUInteger nvalues = [dcf countOfValues];
		NSUInteger nlabels = [dcf countOfLabels];
		NSUInteger i;
		if (ncols > nvalues)
		{
			for (i=nvalues; i < ncols; i++)
				[dcf addObjectToValues:[NSNumber numberWithDouble:0.0]];
		}
		
		if (ncols > nlabels)
		{
			for (i=nlabels; i < ncols; i++)
				[dcf addObjectToLabels:@"New label"];
		}
		
		if (ncols < nvalues)
		{
			for (i=nvalues; i > ncols; i--)
				[dcf removeObjectFromValuesAtIndex:([dcf countOfValues]-1)];
		}
		
		if (ncols < nlabels)
		{
			for (i=nlabels; i > ncols; i--)
				[dcf removeObjectFromLabelsAtIndex:([dcf countOfValues]-1)];
		}
		
		[[self classifications] replaceObjectAtIndex:cfIndex withObject:dcf];
		
	}
	else if ([selType compare:@"Gradient"] == NSOrderedSame)
	{
	
		TMGradientClassification *gcf = 
			[[TMGradientClassification alloc] init];
		
		[gcf setName:[cf name]];
		[gcf setDescription:[cf description]];
		
		if ([cf respondsToSelector:@selector(colorTable)])
		{
			TMColorTable *ct = [cf performSelector:@selector(colorTable)];
			[gcf setColorTable:ct];
		}
		
		if ([cf respondsToSelector:@selector(labels)])
		{
			NSMutableArray *labels = [cf performSelector:@selector(labels)];
			[gcf setLabels:labels];
		}
		
		if ([cf respondsToSelector:@selector(limits)])
		{
			NSMutableArray *limits = [cf performSelector:@selector(limits)];
			[gcf setValues:limits];
		}
		
		if ([cf respondsToSelector:@selector(values)])
		{
			NSMutableArray *values = [cf performSelector:@selector(values)];
			[gcf setValues:values];
		}
		
		NSUInteger ncols = [[gcf colorTable] countOfColors];
		NSUInteger nvalues = [gcf countOfValues];
		NSUInteger nlabels = [gcf countOfLabels];
		NSUInteger i;
		if (ncols > nvalues)
		{
			for (i=nvalues; i < ncols; i++)
				[gcf addObjectToValues:[NSNumber numberWithDouble:0.0]];
		}
		
		if ((ncols-1) > nlabels)
		{
			for (i=nlabels; i < ncols; i++)
				[gcf addObjectToLabels:@"New label"];
		}
		
		[[self classifications] replaceObjectAtIndex:cfIndex withObject:gcf];
		
	}
	
	[self updatePanel:self];
}




#pragma mark --- Color Table Handling ---

-(TMColorTable*)selectedColorTable
{
	id cf = [self selectedClassification];
	if (cf == nil) return nil;

	if ([cf respondsToSelector:@selector(colorTable)])
	{
		TMColorTable *ct = [cf performSelector:@selector(colorTable)];
		return ct;
	}
	
	return nil;
}



-(IBAction)colorTableHasChanged:(id)sender
{
	TMColorTable *ct = nil;
	
	// Get the color table through the menu.
	NSString *selName = [[_colorTableMenu selectedItem] title];
	
	NSMutableArray *colorTables = 
		[[[NSApp orderedDocuments] objectAtIndex:0] colorTables];
	for (TMColorTable *ctArray in colorTables)
	{
		if ([selName compare:[ctArray name]] == NSOrderedSame)
			ct = ctArray;
	}
	
	id cf = [self selectedClassification];
	if ([cf respondsToSelector:@selector(setColorTable:)])
		[cf performSelector:@selector(setColorTable:) withObject:ct];
	
	
	// Get the number of colors.
	NSUInteger ncols = [ct countOfColors];
	
	// Adjust the classification to the number of colors.
	if ([cf isMemberOfClass:[TMContinuousClassification class]])
	{
		TMContinuousClassification *ccf = cf;
		
		NSMutableArray *limits = [ccf limits];
		if ([limits count] < ncols)
		{
			NSUInteger i;
			for (i = [limits count]; i <= ncols; i++)
				[limits addObject:[NSNumber numberWithDouble:0.0]];
		}
		
		NSMutableArray *labels = [ccf labels];
		if ([labels count] < ncols)
		{
			NSUInteger i;
			for (i = [labels count]; i <= ncols; i++)
				[labels addObject:@"New label"];
		}
		
	}
	else if ([cf isMemberOfClass:[TMDiscreteClassification class]])
	{
		TMDiscreteClassification *dcf = cf;
		
		NSMutableArray *values = [dcf values];
		if ([values count] < ncols)
		{
			NSUInteger i;
			for (i = [values count]; i <= ncols; i++)
				[values addObject:[NSNumber numberWithDouble:0.0]];
		}
		
		NSMutableArray *labels = [dcf labels];
		if ([labels count] < ncols)
		{
			NSUInteger i;
			for (i = [labels count]; i <= ncols; i++)
				[labels addObject:@"New label"];
		}
		
	}
	else if ([cf isMemberOfClass:[TMGradientClassification class]])
	{
		TMGradientClassification *gcf = cf;
		
		NSMutableArray *values = [gcf values];
		if ([values count] < ncols)
		{
			NSUInteger i;
			for (i = [values count]; i <= ncols; i++)
				[values addObject:[NSNumber numberWithDouble:0.0]];
		}
		
		NSMutableArray *labels = [gcf labels];
		if ([labels count] < ncols)
		{
			NSUInteger i;
			for (i = [labels count]; i <= ncols; i++)
				[labels addObject:@"New label"];
		}
	}
	
	[_valueLabelList reloadData];
	
}






#pragma mark --- No Data Value Handling ---

-(IBAction)hasNoDataValueChanged:(id)sender
{
	TMClassification *cf = [self selectedClassification];
	if (cf == nil) return;
	
	if ([sender state] == NSOnState)
	{
		[cf setHasNoDataValue:YES];
		
		if ([cf noDataValue] == nil)
			[cf setNoDataValue:[NSNumber numberWithDouble:0.0f]];
		
		if ([cf noDataColor] == nil)
			[cf setNoDataColor:[NSColor whiteColor]];
	}
	else
	{
		[cf setHasNoDataValue:NO];
	}
	
	[self updatePanel:self];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}



-(IBAction)noDataColorHasChanged:(id)sender
{
	TMClassification *cf = [self selectedClassification];
	if (cf == nil) return;
	[cf setNoDataColor:[sender color]];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[[doc page] setNeedsDisplay:YES];
}





#pragma mark --- Text Field Handling ---

-(void)controlTextDidChange:(NSNotification*)aNotification
{
	if ([aNotification object] == _noValueField)
	{
		TMClassification *cf = [self selectedClassification];
		if (cf == nil) return;
		[cf setNoDataValue:[NSNumber 
			numberWithDouble:[_noValueField doubleValue]]];
		
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
	}

}







#pragma mark --- Table View Data Source ---


-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	if (tableView == _classificationList)
	{
		NSInteger nClassifications = [[self classifications] count];
		return nClassifications;
	}
	else if (tableView = _valueLabelList)
	{
		TMColorTable *ct = [self selectedColorTable];
		if (ct == nil) return 0;
		
		id cf = [self selectedClassification];
		if ([cf isMemberOfClass:[TMContinuousClassification class]])
			return ([ct countOfColors] - 1);
		else
			return [ct countOfColors];
	}
	
	return 0;
}



-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn *)aTableColumn 
	row:(NSInteger)rowIndex
{

	if (tableView == _classificationList)
	{
		TMClassification *cl = [[self classifications] objectAtIndex:rowIndex];
		return [cl name];
	}
	else if (tableView = _valueLabelList)
	{
		NSString *colId = [aTableColumn identifier];
		id cf = [self selectedClassification];
		if ([colId compare:@"value"] == NSOrderedSame)
		{
			if ([cf respondsToSelector:@selector(values)])
			{
				NSMutableArray *values = [cf performSelector:@selector(values)];
				return [values objectAtIndex:rowIndex];
			}
			else if ([cf respondsToSelector:@selector(limits)])
			{
				NSMutableArray *limits = [cf performSelector:@selector(limits)];
				return [limits objectAtIndex:rowIndex];
			}
			else
			{
				return nil;
			}
		}
		else if ([colId compare:@"label"] == NSOrderedSame)
		{
			if ([cf respondsToSelector:@selector(labels)])
			{
				NSMutableArray *labels = [cf performSelector:@selector(labels)];
				return [labels objectAtIndex:rowIndex];
			}
			else
			{
				return nil;
			}
		}
	}

	return nil;
	
}




-(void)tableView:(NSTableView*)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex
{

	if (aTableView == _classificationList)
	{
		TMClassification *cl = [[self classifications] objectAtIndex:rowIndex];
		[cl setName:anObject];
	}
	else if (aTableView = _valueLabelList)
	{
		NSString *colName = [aTableColumn identifier];
		id cf = [self selectedClassification];
		if ([colName compare:@"value"] == NSOrderedSame)
		{
			if ([cf respondsToSelector:@selector(values)])
			{
				NSMutableArray *values = [cf performSelector:@selector(values)];
				[values replaceObjectAtIndex:rowIndex withObject:anObject];
			}
			else if ([cf respondsToSelector:@selector(limits)])
			{
				NSMutableArray *limits = [cf performSelector:@selector(limits)];
				[limits replaceObjectAtIndex:rowIndex withObject:anObject];
			}
							
		}
		else if ([colName compare:@"label"] == NSOrderedSame)
		{
			if ([cf respondsToSelector:@selector(labels)])
			{
				NSMutableArray *labels = [cf performSelector:@selector(labels)];
				[labels replaceObjectAtIndex:rowIndex withObject:anObject];
			}
		}
		
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		[[doc page] setNeedsDisplay:YES];
		
	}
	
}








@end
