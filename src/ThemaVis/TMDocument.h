//
//  TMDocument.h
//  ThemaVis
//
//  Created by Christian Kaiser on 24.03.08.
//  Copyright 361DEGRES 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <FScript/FScript.h>
#import <ThemaMap/ThemaMap.h>

#import "TMScrollView.h"
#import "TMLayerPanelController.h"
#import "TMViewPanelController.h"



@interface TMDocument : NSDocument
{

	// The main window.
	IBOutlet NSWindow *				_mainWindow;
	
	IBOutlet TMPage *				_page;
	IBOutlet TMScrollView *			_pageScrollView;
	
	IBOutlet FSInterpreterView *	_shell;
	IBOutlet NSPanel *				_shellPanel;

	NSMutableArray *				_layers;
	NSMutableArray *				_classifications;
	NSMutableArray *				_colorTables;
	
	TMLayerPanelController *		_layerPanelController;
	TMViewPanelController *			_viewPanelController;
	
	
	IBOutlet NSPanel *				_commandLogPanel;		// The window with the command log
	IBOutlet NSTextView *			_commandLog;			// The text view which is used for logging all the commands
	
	
	IBOutlet NSPanel *				_pagePropertiesPanel;
	IBOutlet NSTextField *			_pageWidthTextField;
	IBOutlet NSTextField *			_pageHeightTextField;
	
	
	NSData *						_archive;				// Needed for loading the document.
															// Some redesign is needed here!
	
}




-(NSData*)documentArchive;					// Returns an archived NSDictionary with the document content.
-(void)readArchive:(NSData*)archive;		// Reads an archive NSDictionary.



-(TMPage*)page;


-(FSInterpreterView*)shell;
-(BOOL)shellIsVisible;
-(IBAction)showOrHideShellPanel:(id)sender;



/**
 * Shows or hides the command log panel.
 */
-(IBAction)showOrHideCommandLogPanel:(id)sender;



-(void)logCommand:(NSString*)cmd;							// Inserts a given string at the end of the command log.
-(FSInterpreterResult*)executeCommand:(NSString*)cmd;		// Executes and logs the provided command.

-(void)showLayerPanel;										// Shows the layer panel as a sheet in this document.
-(void)showViewPanel;										// Show the view panel as a sheet in this document.



/**
 * Adds a layer and controls whether there is already a layer with the
 * same name. If so, it changes the layer name.
 */
-(void)addLayer:(TMLayer*)layer;


/**
 * Adds a classification. Makes sure that the classification name is unique.
 * If there is already a stricly equal classification, the classification
 * is not added and the pointer to the equal classification is returned.
 * Otherwise, the classification is added and a pointer to the added
 * classification is returned.
 */
-(id)addClassification:(TMClassification*)classification;


/**
 * Returns the classification with the provided name, or nil if there
 * is no such classification.
 */
-(id)classificationWithName:(NSString*)name;


/**
 * Adds a color table. Makes sure that the color table name is unique.
 * If there is already a stricly equal color table, the color table is not
 * added and the pointer to the equal color table is returned.
 * Otherwise, the color table is added and a pointer to the added color
 * table returned.
 */
-(TMColorTable*)addColorTable:(TMColorTable*)colorTable;



-(NSMutableArray*)layers;
-(void)setLayers:(NSMutableArray*)layers;

-(void)windowDidBecomeMain:(NSNotification*)notification;

-(NSMutableArray*)colorTables;
-(void)setColorTables:(NSMutableArray*)colorTables;

-(NSMutableArray*)classifications;
-(void)setClassifications:(NSMutableArray*)classifications;


-(IBAction)showPagePropertiesPanel:(id)sender;
-(IBAction)pagePropertiesPanelTerminate:(id)sender;





-(IBAction)exportToPDF:(id)sender;

-(void)exportToPDFPanelDidEnd:(NSSavePanel*)sheet 
				   returnCode:(int)returnCode 
				  contextInfo:(void *)contextInfo;


@end
