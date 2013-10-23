//
//  TMColorTablePanelController.m
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import "TMColorTablePanelController.h"
#import "TMColorCell.h"
#import "TMDocument.h"


@implementation TMColorTablePanelController



#pragma mark --- Creation of the Color Tabel Panel Controller ---


+(id)sharedColorTablePanelController
{
    static TMColorTablePanelController *
		sharedColorTablePanelController = nil;


    if (!sharedColorTablePanelController)
	{
        sharedColorTablePanelController = 
			[[TMColorTablePanelController allocWithZone:NULL] init];
    }

    return sharedColorTablePanelController;
}



-(id)init
{
    self = [self initWithWindowNibName:@"ColorTablePanel"];
	
    if (self)
	{
        [self setWindowFrameAutosaveName:@"ColorTablePanel"];
    }
    return self;
}



-(void)awakeFromNib
{
	TMColorCell *colorCell = [[TMColorCell alloc] init];
	[colorCell setTarget:self];
	[colorCell setAction:@selector(colorClick:)];
	
	NSTableColumn *column = [[_colorList tableColumns] objectAtIndex:0];
	[column setDataCell:colorCell];
}


#pragma mark --- Updating the Panel Content ---

-(IBAction)updatePanel:(id)sender
{
	[_colorTableList reloadData];
	[_colorList reloadData];
}




#pragma mark --- Color Table Array Handling ---


-(NSMutableArray*)colorTables
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	return [document colorTables];
}



-(void)setColorTables:(NSMutableArray*)colorTables
{
	TMDocument *document = [[NSApp orderedDocuments] objectAtIndex:0];
	[document setColorTables:colorTables];
}





#pragma mark --- Color Table Handling ---

-(IBAction)addColorTable:(id)sender
{
	TMColorTable *ct = [[TMColorTable alloc] init];
	[ct setName:@"New color table"];
	
	// Check whether the color table name exists already.
	NSMutableArray *colorTables = [self colorTables];
	BOOL nameExists = NO;
	for (TMColorTable *ctArray in colorTables)
	{
		if ([[ctArray name] compare:@"New color table"] == NSOrderedSame)
			nameExists = YES;
	}
	
	
	if (nameExists)
	{
		NSUInteger nameIndex = 1;
		NSString *ctName;
		while (nameExists)
		{
			ctName = 
				[NSString stringWithFormat:@"New color table %u", nameIndex];
				
			nameExists = NO;
			for (TMColorTable *ctArray in colorTables)
			{
				if ([[ctArray name] compare:ctName] == NSOrderedSame)
					nameExists = YES;
			}
			
			nameIndex++;
		}
		
		[ct setName:ctName];
	}
	
	
	[[self colorTables] addObject:ct];
	[self updatePanel:self];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}




-(IBAction)removeColorTable:(id)sender
{
	[[self colorTables] removeObjectAtIndex:[_colorTableList selectedRow]];
	[self updatePanel:self];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}




-(TMColorTable*)selectedColorTable
{
	NSInteger selColorTable = [_colorTableList selectedRow];
	if (selColorTable < 0)
		return nil;
	else
		return [[self colorTables] objectAtIndex:selColorTable];
}





-(IBAction)saveColorTable:(id)sender
{

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Save color table"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setRequiredFileType:@"tmcolors"];
	[savePanel setCanSelectHiddenExtension:YES];
	
	[savePanel beginSheetForDirectory:nil 
		file:nil 
		modalForWindow:[self window] 
		modalDelegate:self 
		didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) 
		contextInfo:nil];
}



-(IBAction)openColorTable:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	
	NSArray *fileTypes = [NSArray arrayWithObjects:@"tmcolors", nil];
	
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
		TMColorTable *ct = [self selectedColorTable];
		if (ct == nil) return;
	
		NSString *file = [sheet filename];
		[NSKeyedArchiver archiveRootObject:ct toFile:file];
	}

}



-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo
{

	if (returnCode == NSOKButton)
	{
		TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
		NSArray *files = [panel filenames];
		for (NSString *filePath in files)
		{
			TMColorTable *ct = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
			[doc addColorTable:ct];
		}
		
		[self updatePanel:self];
	}
	
}





-(void)tableViewSelectionDidChange:(NSNotification*)aNotification
{

	NSTableView *changedTableView = (NSTableView*)[aNotification object];
	
	if (changedTableView == _colorTableList)
	{
		[_colorList deselectAll:self];
		[_colorList reloadData];
	}

}




#pragma mark --- Color Handling ---

-(IBAction)addColor:(id)sender
{
	TMColorTable *ct = [self selectedColorTable];
	if (ct == nil) return;
	
	NSColor *newColor = [NSColor colorWithDeviceCyan:0.6 
		magenta:0.0 yellow:1.0 black:0.0 alpha:1.0];
	[ct addObjectToColors:newColor];
	
	[self updatePanel:self];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}



-(IBAction)removeColor:(id)sender
{
	TMColorTable *ct = [self selectedColorTable];
	if (ct == nil) return;
	
	[[ct colors] removeObjectAtIndex:[_colorList selectedRow]];
	[_colorList deselectAll:self];
	[_colorList reloadData];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}



-(IBAction)moveColorUp:(id)sender
{
	TMColorTable *ct = [self selectedColorTable];
	if (ct == nil) return;
	
	NSInteger selColorIndex = [_colorList selectedRow];
	if (selColorIndex == 0) return;
	
	NSMutableArray *colors = [ct colors];
	[colors exchangeObjectAtIndex:(selColorIndex) 
		withObjectAtIndex:(selColorIndex-1)];
	
	[_colorList reloadData];
	[_colorList selectRow:(selColorIndex-1) byExtendingSelection:NO];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}



-(IBAction)moveColorDown:(id)sender
{
	TMColorTable *ct = [self selectedColorTable];
	if (ct == nil) return;
	
	NSMutableArray *colors = [ct colors];
	NSUInteger ncolors = [colors count];
	
	NSInteger selColorIndex = [_colorList selectedRow];
	if (selColorIndex == (ncolors-1)) return;
	
	[colors exchangeObjectAtIndex:(selColorIndex) 
		withObjectAtIndex:(selColorIndex+1)];
	
	[_colorList reloadData];
	[_colorList selectRow:(selColorIndex+1) byExtendingSelection:NO];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}





-(void)colorClick:(id)sender
{
	_indexOfColorBeingEdited = [sender clickedRow];
	TMColorTable *ct = [self selectedColorTable];
	
	NSColorPanel* panel = [NSColorPanel sharedColorPanel];
	[panel setTarget:self];
	[panel setAction:@selector(colorChanged:)];
	
	[panel setColor:[[ct colors] objectAtIndex:_indexOfColorBeingEdited]];
	
	[panel makeKeyAndOrderFront:self];
}





-(void)colorChanged:(id)sender 
{
	// Sender is the NSColorPanel.
	NSColor *newColor = [sender color];
	
	TMColorTable *ct = [self selectedColorTable];
	[[ct colors] replaceObjectAtIndex:_indexOfColorBeingEdited 
		withObject:newColor];
	
	[_colorList reloadData];
	
	TMDocument *doc = [[NSApp orderedDocuments] objectAtIndex:0];
	[doc updateChangeCount:NSChangeDone];
}







#pragma mark --- Table View Data Source ---


-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
	if (tableView == _colorTableList)
	{
		NSInteger nColorTables = [[self colorTables] count];
		return nColorTables;
	}
	else if (tableView == _colorList)
	{
		TMColorTable *ct = [self selectedColorTable];
		if (ct == nil)
			return 0;
		else
			return [ct countOfColors];
	}
	
	return 0;
}



-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn *)aTableColumn 
	row:(NSInteger)rowIndex
{
	if (tableView == _colorTableList)
	{
		TMColorTable *ct = [[self colorTables] objectAtIndex:rowIndex];
		return [ct name];
	}
	else if (tableView == _colorList)
	{
		TMColorTable *ct = [self selectedColorTable];
		if (ct == nil) return nil;
		
		return [ct objectInColorsAtIndex:rowIndex];
	}
	
	return nil;
}



-(void)tableView:(NSTableView*)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex
{
	if (aTableView == _colorTableList)
	{
		TMColorTable *ct = [[self colorTables] objectAtIndex:rowIndex];
		[ct setName:anObject];
	}
	else if (aTableView == _colorList)
	{
		TMColorTable *ct = [self selectedColorTable];
		if (ct == nil) return;
		
		NSMutableArray *colors = [ct colors];
		[colors replaceObjectAtIndex:rowIndex withObject:anObject];
	}
}






@end
