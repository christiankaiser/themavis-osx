//
//  TMClassificationPanelController.h
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>


@interface TMClassificationPanelController : NSWindowController
{
	IBOutlet NSTableView * _classificationList;
	IBOutlet NSPopUpButton * _classificationTypeMenu;
	IBOutlet NSPopUpButton * _colorTableMenu;
	IBOutlet NSButton * _hasNoValueButton;
	IBOutlet NSTextField * _noValueLabel;
	IBOutlet NSTextField * _noValueField;
	IBOutlet NSTextField * _noValueColorLabel;
	IBOutlet NSColorWell * _noValueColorWell;
	IBOutlet NSTableView * _valueLabelList;
	IBOutlet NSScrollView * _valueLabelScrollView;
	
	IBOutlet NSTextField * _classificationTypeLabel;
	IBOutlet NSTextField * _colorTableLabel;
	
	IBOutlet NSTextField * _noSelectionLabel;
}



#pragma mark --- Creating the Panel Controller ---

+(id)sharedClassificationPanelController;



#pragma mark --- Updating the Panel Content ---

-(IBAction)updatePanel:(id)sender;




#pragma mark --- Classification Handling ---

/**
 * Returns the array of classification from the document.
 */
-(NSMutableArray*)classifications;

/**
 * Creates a new classification and adds it to the classification array.
 */
-(IBAction)addClassification:(id)sender;

/**
 * Removes the selected classification.
 */
-(IBAction)removeClassification:(id)sender;

/**
 * Returns the selected classification.
 */
-(id)selectedClassification;


-(IBAction)saveClassification:(id)sender;
-(IBAction)openClassification:(id)sender;

-(void)savePanelDidEnd:(NSSavePanel*)sheet 
	returnCode:(int)returnCode 
	contextInfo:(void *)contextInfo;

-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo;
	

-(void)tableViewSelectionDidChange:(NSNotification*)aNotification;




#pragma mark --- Classification Type Handling ---

-(IBAction)classificationTypeHasChanged:(id)sender;




#pragma mark --- Color Table Handling ---

-(TMColorTable*)selectedColorTable;

-(IBAction)colorTableHasChanged:(id)sender;



#pragma mark --- No Data Value Handling ---

-(IBAction)hasNoDataValueChanged:(id)sender;
-(IBAction)noDataColorHasChanged:(id)sender;




#pragma mark --- Text Field Handling ---

/**
 * Delegate method for text fields.
 */
-(void)controlTextDidChange:(NSNotification*)aNotification;





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






