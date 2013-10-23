//
//  TMDocument.m
//  ThemaVis
//
//  Created by Christian Kaiser on 24.03.08.
//  Copyright 361DEGRES 2008 . All rights reserved.
//

#import "TMDocument.h"

#import "TMLayerPanelController.h"
#import "TMColorTablePanelController.h"
#import "TMUtilities.h"



@implementation TMDocument

-(id)init
{
    self = [super init];
    if (self) 
	{
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		_layers = [NSMutableArray arrayWithCapacity:1];
		_colorTables = [NSMutableArray arrayWithCapacity:1];
		_classifications = [NSMutableArray arrayWithCapacity:1];
		
		
		// Load the layer panel controller.
		_layerPanelController = [[TMLayerPanelController alloc] init];
		_viewPanelController = [[TMViewPanelController alloc] init];
		
    }
    return self;
}






-(NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your 
	// document supports multiple NSWindowControllers, you should remove this
	// method and override -makeWindowControllers instead.
    return @"TMDocument";
}



-(void)windowControllerDidLoadNib:(NSWindowController*)aController
{
    [super windowControllerDidLoadNib:aController];
	
    // Add any code here that needs to be executed once the windowController 
	// has loaded the document's window.
	
	//[_pageScrollView setDocumentView:_page];
	//[_pageScrollView zoomToAll:self];
	
	
//	TMUnit pageUnit = [_page unit];
//	[_page setUnit:TMPixels];
//	double frameWidth = [_page pageWidth] + 40;
//	double frameHeight = [_page pageHeight] + 40; 
//	[_page setFrame:NSMakeRect(0, 0, frameWidth, frameHeight)];
//	[_page setBoundsOrigin:NSMakePoint(-20, -20)];
//	[_page setUnit:pageUnit];

	
	// Make the page the first responder.
	[[aController window] makeFirstResponder:_page];


	// Create the Shell interpreter which we will use for processing the commands.
	// We store the following variable in the shell: _document
	FSInterpreter *interpreter = [_shell interpreter];
	[interpreter setObject:self forIdentifier:@"_doc"];
	//[interpreter setObject:_page forIdentifier:@"_page"];
	//[interpreter setObject:_layers forIdentifier:@"_layers"];
	//[interpreter setObject:_classifications forIdentifier:@"_classifications"];
	//[interpreter setObject:_colorTables forIdentifier:@"_colorTables"];

	
	
	// Create new document or open existing file?
	if (_archive == nil)
	{
		NSLog(@"Creating new document");
		
		// Put the initialization string into the command log.
		[self logCommand:@"\"ThemaVis version 0.1\"\n"];
		[self logCommand:@"\"2009 © Copyright 361DEGRES Christian Kaiser. All rights reserved.\"\n\n"];
	
	}
	else
	{
		NSLog(@"Opening existing file");
		
		[self readArchive:_archive];
		_archive = nil;
	}
	

	
	// Add the shell window to the document's window controllers.
	//[self addWindowController:[_shellPanel windowController]];
	
	
	// Enables the transparency in the color panel.
	NSColorPanel *clrPanel = [NSColorPanel sharedColorPanel];
	[clrPanel setShowsAlpha:YES];
	
	
	
}





-(NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. 
	// If the given outError != NULL, ensure that you set *outError when 
	// returning nil.

    // You can also choose to override -fileWrapperOfType:error:, 
	// -writeToURL:ofType:error:, or 
	// -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should 
	// use the deprecated API -dataRepresentationOfType:. In this case you 
	// can also choose to override -fileWrapperRepresentationOfType: or 
	// -writeToFile:ofType: instead.
	
	
	if ([typeName compare:@"Map"] == NSOrderedSame)
	{
		NSData *docArchive = [self documentArchive];
		if (docArchive == nil && outError != NULL)
		{
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
		}
		return docArchive;
	}
	

    if ( outError != NULL )
	{
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}



-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the 
	// specified type.  If the given outError != NULL, ensure that you set 
	// *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or 
	// -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should 
	// use the deprecated API -loadDataRepresentation:ofType. In this case you 
	// can also choose to override -readFromFile:ofType: or 
	// -loadFileWrapperRepresentation:ofType: instead.
    
	if ([typeName compare:@"Map"] == NSOrderedSame)
	{
		_archive = data;
		return YES;
	}
	
	
	
    if ( outError != NULL )
	{
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain 
						code:unimpErr userInfo:NULL];
	}
    return NO;
}









-(NSData*)documentArchive
{
	NSMutableDictionary *doc = [[NSMutableDictionary alloc] initWithCapacity:5];
	
	[doc setObject:@"0.1.0" forKey:@"Version"];			// Archive version.
	
	[doc setObject:_layers forKey:@"Layers"];
	[doc setObject:_classifications forKey:@"Classifications"];
	[doc setObject:_colorTables forKey:@"ColorTables"];
	
	[doc setObject:_commandLog forKey:@"CommandLog"];
	
	[doc setObject:_page forKey:@"Page"];
	
	NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:doc];
	return archive;
}





-(void)readArchive:(NSData*)archive
{
	NSMutableDictionary *doc = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
	
	// Check the version.
	NSString *version = [doc objectForKey:@"Version"];
	if ([version compare:@"0.1.0"] != NSOrderedSame)
	{
		TMDisplayError(@"File format unknown", 
					   @"This version of ThemaVis is unable to read this file format. It is probably from a more recent version of ThemaVis.");
		return;
	}
	
	_colorTables = [doc objectForKey:@"ColorTables"];
	_classifications = [doc objectForKey:@"Classifications"];
	_layers = [doc objectForKey:@"Layers"];
	
	NSTextView *clog = [doc objectForKey:@"CommandLog"];
	[_commandLog setString:[clog string]];
	
	TMPage *p = [doc objectForKey:@"Page"];
	NSArray *pviews = [p subviews];
	NSMutableArray *pviewsCopy = [pviews mutableCopy];
	for (id pview in pviewsCopy)
	{
		[_page addSubview:pview];
	}
	[_page setUnit:[p unit]];
	[_page setWantsLayer:[p wantsLayer]];
	[_page setPageHeight:[p pageHeight]];
	[_page setPageWidth:[p pageWidth]];
	
	[_page setNeedsDisplay:YES];
	
}





-(TMPage*)page
{
	return _page;
}





-(FSInterpreterView*)shell
{
	return _shell;
}



-(BOOL)shellIsVisible
{
	return [_shellPanel isVisible];
}



-(IBAction)showOrHideShellPanel:(id)sender
{
	if ([_shellPanel isVisible])
		[_shellPanel orderOut:sender];
	else
		[_shellPanel makeKeyAndOrderFront:sender];
}




-(IBAction)showOrHideCommandLogPanel:(id)sender
{
	if ([_commandLogPanel isVisible])
		[_commandLogPanel orderOut:sender];
	else
		[_commandLogPanel makeKeyAndOrderFront:sender];
}



-(void)logCommand:(NSString*)cmd
{
	[_commandLog insertText:cmd];
}


-(FSInterpreterResult*)executeCommand:(NSString*)cmd
{
	[self logCommand:cmd];
	[self logCommand:@"\n"];
	return [[_shell interpreter] execute:cmd];
}


-(void)showLayerPanel
{
	[NSApp beginSheet:[_layerPanelController window] 
	   modalForWindow:_mainWindow
		modalDelegate:_layerPanelController 
	   didEndSelector:@selector(layerSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}


-(void)showViewPanel
{
	[NSApp beginSheet:[_viewPanelController window] 
	   modalForWindow:_mainWindow
		modalDelegate:_viewPanelController 
	   didEndSelector:@selector(viewSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
	
	[_viewPanelController updateViewDataWithNoSelection];
}





-(void)addLayer:(TMLayer*)layer
{
	
	// Get the name of the layer to add.
	NSString *lyrName = [layer name];
	
	// Make the name to be unique.
	if (_layers == nil)
		_layers = [NSMutableArray arrayWithCapacity:1];
	
	BOOL nameExists = YES;
	NSUInteger nameIndex = 0;
	while (nameExists)
	{
		nameExists = NO;
		for (TMLayer *lyr in _layers)
		{
			if ([lyrName compare:[lyr name]] == NSOrderedSame)
				nameExists = YES;
		}
		
		if (nameExists)
		{
			nameIndex++;
			lyrName = [NSString stringWithFormat:@"%@-%u", 
							[layer name], nameIndex];
		}
	}
	
	if (nameIndex > 0)
		[layer setName:lyrName];
	
	[_layers addObject:layer];
	
}



-(id)addClassification:(TMClassification*)classification
{
	if (_classifications == nil)
		_classifications = [NSMutableArray arrayWithCapacity:1];
		
	// Check whether the classification is already in the document.
	for (TMClassification *cf in _classifications)
	{
		if ([classification isEqualTo:cf])
			return cf;
	}
	
	// Get the name of the classification to add.
	NSString *cfName = [classification name];
	
	// Make the name to be unique.
	BOOL nameExists = YES;
	NSUInteger nameIndex = 0;
	while (nameExists)
	{
		nameExists = NO;
		for (TMClassification *cf in _classifications)
		{
			if ([cfName compare:[cf name]] == NSOrderedSame)
				nameExists = YES;
		}
		
		if (nameExists)
		{
			nameIndex++;
			cfName = [NSString stringWithFormat:@"%@-%u", 
							[classification name], nameIndex];
		}
	}
	
	if (nameIndex > 0)
		[classification setName:cfName];
	
	[_classifications addObject:classification];
	
	
	// Extract the color table inside the classification, if there is one.
	// Check whether this color table is already in our document.
	// If not, we add it to the document's color table.
	if ([classification respondsToSelector:@selector(colorTable)])
	{
		TMColorTable *ct =
			[classification performSelector:@selector(colorTable)];
		
		TMColorTable *ct2 = [self addColorTable:ct];
		
		if (ct != ct2 && 
			[classification respondsToSelector:@selector(setColorTable:)])
		{
			[classification performSelector:@selector(setColorTable:) 
				withObject:ct2];
		}
		
		[[TMColorTablePanelController sharedColorTablePanelController] 
			updatePanel:self];
	}
	
	return classification;
	
}




-(id)classificationWithName:(NSString*)name
{
	if (name == nil) return nil;
	
	for (TMClassification *cf in _classifications)
	{
		NSString *cfName = [cf name];
		if (cfName != nil && [cfName compare:name] == NSOrderedSame)
		{
			return cf;
		}
	}
	
	return nil;
}




-(TMColorTable*)addColorTable:(TMColorTable*)colorTable
{
	if (_colorTables == nil)
		_colorTables = [NSMutableArray arrayWithCapacity:1];
		
	// Check whether the color table is already in the document.
	for (TMColorTable *ct in _colorTables)
	{
		if ([colorTable isEqualTo:ct])
			return ct;
	}
	
	// Get the name of the color table to add.
	NSString *ctName = [colorTable name];
	
	// Make the name to be unique.
	BOOL nameExists = YES;
	NSUInteger nameIndex = 0;
	while (nameExists)
	{
		nameExists = NO;
		for (TMColorTable *ct in _colorTables)
		{
			if ([ctName compare:[ct name]] == NSOrderedSame)
				nameExists = YES;
		}
		
		if (nameExists)
		{
			nameIndex++;
			ctName = [NSString stringWithFormat:@"%@-%u", 
							[colorTable name], nameIndex];
		}
	}
	
	if (nameIndex > 0)
		[colorTable setName:ctName];
	
	[_colorTables addObject:colorTable];
	return colorTable;

}




-(NSMutableArray*)layers
{
	return _layers;
}




-(void)setLayers:(NSMutableArray*)layers
{
	_layers = layers;
}




-(void)windowDidBecomeMain:(NSNotification *)notification
{
	[[TMLayerPanelController sharedLayerPanelController] updatePanel];
}





-(NSMutableArray*)colorTables
{
	return _colorTables;
}



-(void)setColorTables:(NSMutableArray*)colorTables
{
	_colorTables = colorTables;
}



-(NSMutableArray*)classifications
{
	return _classifications;
}



-(void)setClassifications:(NSMutableArray*)classifications
{
	_classifications = classifications;
}






-(IBAction)showPagePropertiesPanel:(id)sender
{
	[_pageWidthTextField setIntegerValue:(NSInteger)[_page pageWidth]];
	[_pageHeightTextField setIntegerValue:(NSInteger)[_page pageHeight]];
	
	[NSApp runModalForWindow:_pagePropertiesPanel];
}




-(IBAction)pagePropertiesPanelTerminate:(id)sender
{
	if ([sender tag] == 1)
	{
		if ([_pageWidthTextField integerValue] > 0)
			[_page setPageWidth:(NSUInteger)[_pageWidthTextField integerValue]];
	
		if ([_pageHeightTextField integerValue] > 0)
			[_page setPageHeight:(NSUInteger)[_pageHeightTextField integerValue]];
	
		[_page setNeedsDisplay:YES];
	}
	
	[NSApp stopModal];
	[_pagePropertiesPanel orderOut:sender];
}




-(IBAction)exportToPDF:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Export map to PDF"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setRequiredFileType:@"pdf"];
	[savePanel setCanSelectHiddenExtension:YES];
	
	[savePanel beginSheetForDirectory:nil 
								 file:nil 
					   modalForWindow:_mainWindow 
						modalDelegate:self 
					   didEndSelector:@selector(exportToPDFPanelDidEnd:returnCode:contextInfo:) 
						  contextInfo:nil];
}



-(void)exportToPDFPanelDidEnd:(NSSavePanel*)sheet 
				   returnCode:(int)returnCode 
				  contextInfo:(void *)contextInfo
{
	
	if (returnCode == NSOKButton)
	{
		NSString *file = [sheet filename];
		file = [file stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];	// Replace the ' by \'
		[self executeCommand:[NSString stringWithFormat:@"(_doc page) exportToPDF:'%@'.", file]];
	}
	
}




@end
