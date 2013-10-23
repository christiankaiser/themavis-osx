//
//  TMColorTablePanelController.h
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>


@interface TMColorTablePanelController : NSWindowController
{
	IBOutlet NSTableView * _colorTableList;
	IBOutlet NSTableView * _colorList;
	
	NSInteger _indexOfColorBeingEdited;
}



#pragma mark --- Creation of the Color Tabel Panel Controller ---

+(id)sharedColorTablePanelController;



#pragma mark --- Updating the Panel Content ---

-(IBAction)updatePanel:(id)sender;




#pragma mark --- Color Table Array Handling ---

/**
 * Retrieves and returns the color table array from the main document.
 */
-(NSMutableArray*)colorTables;


/**
 * Sets the color table array in the main document.
 */
-(void)setColorTables:(NSMutableArray*)colorTables;




#pragma mark --- Color Table Handling ---

-(IBAction)addColorTable:(id)sender;
-(IBAction)removeColorTable:(id)sender;

-(TMColorTable*)selectedColorTable;
	
-(IBAction)saveColorTable:(id)sender;
-(IBAction)openColorTable:(id)sender;

-(void)savePanelDidEnd:(NSSavePanel*)sheet 
	returnCode:(int)returnCode 
	contextInfo:(void *)contextInfo;

-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo;
	
	
-(void)tableViewSelectionDidChange:(NSNotification*)aNotification;




#pragma mark --- Color Handling ---

-(IBAction)addColor:(id)sender;
-(IBAction)removeColor:(id)sender;

-(IBAction)moveColorUp:(id)sender;
-(IBAction)moveColorDown:(id)sender;

-(void)colorClick:(id)sender;
-(void)colorChanged:(id)sender;




#pragma mark --- Table View Data Source ---


/**
 * Get the number of rows for the table views of the layer panel.
 */
-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView;


/**
 * Get the content for the specified cell in one of the table views of the
 * layer panel.
 */
-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn *)aTableColumn 
	row:(NSInteger)rowIndex;


/**
 * Setting the content for the specified cell in one of the table views of
 * the layer panel.
 */
-(void)tableView:(NSTableView*)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn*)aTableColumn 
	row:(NSInteger)rowIndex;





@end
