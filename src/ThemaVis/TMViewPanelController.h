//
//  TMViewPanelController.h
//  ThemaVis
//
//  Created by Christian on 03.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>


@interface TMViewPanelController : NSWindowController
{
	/*IBOutlet NSTabView * _tabView;

	IBOutlet NSTableView * _layerList;
	IBOutlet NSWindow * _addLayerSheet;
	IBOutlet NSPopUpButton * _addLayerPopUp;
	IBOutlet NSButton * _addLayerButton;
	IBOutlet NSButton* _removeLayerButton;
	
	IBOutlet NSTextField* _leftMapCoordinate;
	IBOutlet NSTextField* _bottomMapCoordinate;
	IBOutlet NSTextField* _widthMapCoordinate;
	IBOutlet NSTextField* _heightMapCoordinate;
	*/
	
	
	IBOutlet NSTableView *		_viewList;				// The list of all views.
	IBOutlet NSTextField *		_viewNameField;			// The text field for the view name.
	IBOutlet NSTextField *		_viewNameLabel;
	IBOutlet NSTextField *		_viewCoordsTopField;
	IBOutlet NSTextField *		_viewCoordsBottomField;
	IBOutlet NSTextField *		_viewCoordsLeftField;
	IBOutlet NSTextField *		_viewCoordsRightField;
	IBOutlet NSTextField *		_viewCoordsTopLabel;
	IBOutlet NSTextField *		_viewCoordsBottomLabel;
	IBOutlet NSTextField *		_viewCoordsLeftLabel;
	IBOutlet NSTextField *		_viewCoordsRightLabel;
	IBOutlet NSButton *			_viewPropertiesButton;
	
	IBOutlet NSButton *			_viewStyleDrawContourButton;
	IBOutlet NSTextField *		_viewStyleDrawContourLineWidthLabel;
	IBOutlet NSTextField *		_viewStyleDrawContourLineWidthField;
	IBOutlet NSTextField *		_viewStyleDrawContourLineColorLabel;
	IBOutlet NSColorWell *		_viewStyleDrawContourLineColorWell;
	IBOutlet NSButton *			_viewStyleFillBackgroundButton;
	IBOutlet NSTextField *		_viewStyleFillBackgroundColorLabel;
	IBOutlet NSColorWell *		_viewStyleFillBackgroundColorWell;
	
	IBOutlet NSPanel *			_addNewViewPanel;		// Panel to select the type of a new view.
	IBOutlet NSPopUpButton *	_addNewViewTypeMenu;	// The popup menu with the view type.
	
	IBOutlet NSButton *			_removeViewButton;
	IBOutlet NSButton *			_moveViewUpButton;
	IBOutlet NSButton *			_moveViewDownButton;
	
	IBOutlet NSPanel *			_mapViewPropertiesPanel;
	IBOutlet NSPanel *			_textViewPropertiesPanel;
	IBOutlet NSPanel *			_legendViewPropertiesPanel;
	IBOutlet NSPanel *			_scaleViewPropertiesPanel;
	
	
	// Outlets for the map view properties panel
	IBOutlet NSTableView *		_mapViewLayerList;
	IBOutlet NSTextField *		_mapViewCoordinateLeft;
	IBOutlet NSTextField *		_mapViewCoordinateRight;
	IBOutlet NSTextField *		_mapViewCoordinateTop;
	IBOutlet NSTextField *		_mapViewCoordinateBottom;
	IBOutlet NSTextField *		_mapViewCoordinateLeftLabel;
	IBOutlet NSTextField *		_mapViewCoordinateRightLabel;
	IBOutlet NSTextField *		_mapViewCoordinateTopLabel;
	IBOutlet NSTextField *		_mapViewCoordinateBottomLabel;
	IBOutlet NSTextField *		_mapViewCoordinateTitleLabel;
	IBOutlet NSWindow *			_mapViewAddLayerSheet;
	IBOutlet NSButton *			_mapViewMoveLayerUpButton;
	IBOutlet NSButton *			_mapViewMoveLayerDownButton;
	IBOutlet NSButton *			_mapViewAddLayerButton;
	IBOutlet NSButton *			_mapViewRemoveLayerButton;
	IBOutlet NSButton *			_mapViewFullExtentButton;
	IBOutlet NSPopUpButton *	_mapViewAddLayerMenu;
	
	
	// Outlets for the text view properties panel
	IBOutlet NSTextView *		_textViewEditorField;
	
	// Outlets for the legend view properties panel
	IBOutlet NSPopUpButton *	_legendViewLayerList;
	
	// Outlets for the scale view properties panel
	IBOutlet NSPopUpButton *	_scaleViewMapViewList;
	IBOutlet NSTextField *		_scaleViewScaleLengthTextField;
	IBOutlet NSTextField *		_scaleViewScaleUnitFactorTextField;
	IBOutlet NSTextField *		_scaleViewUnitTextField;
	IBOutlet NSTextField *		_scaleViewNumberOfDivisionsTextField;
	
	
}





#pragma mark --- Table View Data Source ---

// Get the number of rows for the table views of the layer panel.
-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView;

// Get the content for the specified cell in one of the table views of the
// layer panel.
-(id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

// Delegate method for the table views in the panel. This method is called after a selection change.
-(void)tableViewSelectionDidChange:(NSNotification*)aNotification;




#pragma mark --- Update the view data content ---

-(void)updateViewDataWithNoSelection;
-(void)updateViewDataWithMultipleSelection;
-(void)updateViewDataWithView:(TMView*)view;

// Notification sent when a text has changed.
-(void)controlTextDidChange:(NSNotification*)aNotification;	

// Actions for changing style settings
-(IBAction)drawContourHasChanged:(id)sender;
-(IBAction)borderColorHasChanged:(id)sender;
-(IBAction)fillBackgroundHasChanged:(id)sender;
-(IBAction)backgroundColorHasChanged:(id)sender;



#pragma mark --- Manage the view panel sheet ---

-(IBAction)endViewSheet:(id)sender;						// Closes the window.

// Method for terminating the view sheet dialog.
-(void)viewSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;



#pragma mark --- Managing the views ---

-(IBAction)addNewView:(id)sender;						// Adds a new panel (shows the dialog to select the view type).
-(IBAction)addNewViewTerminate:(id)sender;

-(IBAction)removeView:(id)sender;
-(IBAction)moveViewUp:(id)sender;
-(IBAction)moveViewDown:(id)sender;



#pragma mark --- Showing the view properties ---

-(IBAction)showViewProperties:(id)sender;
-(IBAction)showMapViewProperties:(id)sender;
-(IBAction)showMapViewPropertiesTerminate:(id)sender;
-(IBAction)showTextViewProperties:(id)sender;
-(IBAction)showTextViewPropertiesTerminate:(id)sender;
-(IBAction)showLegendViewProperties:(id)sender;
-(IBAction)showLegendViewPropertiesTerminate:(id)sender;
-(IBAction)showScaleViewProperties:(id)sender;
-(IBAction)showScaleViewPropertiesTerminate:(id)sender;


#pragma mark --- Map view properties actions ---

-(IBAction)addLayer:(id)sender;
-(IBAction)addLayerDidEnd:(id)sender;
-(IBAction)addLayerClose:(id)sender;

-(IBAction)removeLayer:(id)sender;
-(IBAction)moveLayerUp:(id)sender;
-(IBAction)moveLayerDown:(id)sender;
-(IBAction)computeFullExtent:(id)sender;


#pragma mark --- Map view layer list data management ---

-(void)updateLayerListWithNoSelection;
-(void)updateLayerListWithMultipleSelection;
-(void)updateLayerListWithLayer:(TMLayer*)layer;



/*

// Returns the view panel controller.
+(id)sharedViewPanelController;


// This method get called after a TMViewSelectionChanged notification has
// been posted.
-(void)viewSelectionChanged:(NSNotification*)aNotification;


// Updates the content of the view panel using the provided view.
-(void)updateWithView:(TMView*)view;


#pragma mark --- Layer Handling ---
-(IBAction)showAddLayerSheet:(id)sender;
-(IBAction)hideAddLayerSheet:(id)sender;

// Adds the selected layer in the popup button to the currently
// selected map view.
-(IBAction)addLayerToView:(id)sender;
-(IBAction)removeLayerFromView:(id)sender;
-(IBAction)moveLayerUp:(id)sender;
-(IBAction)moveLayerDown:(id)sender;


#pragma mark --- Map View Coordinates ---

// Zooms the currently selected map view to its full extent.
-(IBAction)zoomMapViewToFullExtent:(id)sender;

// Updates the four map coordinate text fields in the map view panel.
-(void)updateMapCoordinates;

// Get the number of rows for the table views of the layer panel.
-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView;

// Get the content for the specified cell in one of the table views of the
// layer panel.
-(id)tableView:(NSTableView*)tableView 
	objectValueForTableColumn:(NSTableColumn *)aTableColumn 
	row:(NSInteger)rowIndex;

// Returns the selected map view, if there is exactly one selected.
// Returns nil otherwise.
-(TMMapView*)selectedMapView;

// Delegate method for text fields.
-(void)controlTextDidChange:(NSNotification*)aNotification;

*/

@end
