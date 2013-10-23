//
//  TMLayerPanelController.h
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>
#import "TMBezierPathView.h"


@interface TMLayerPanelController : NSWindowController
{
	IBOutlet NSTableView * _layerList;

	IBOutlet TMMapView * _mapView;
	IBOutlet NSTextField * _mapViewLabel;

	IBOutlet NSTableView * _attributeTable;
	IBOutlet NSScrollView * _attributeTableScrollView;
	
	/**
	 * The no attributes label is only visible if there is no
	 * selection or a multiple selection.
	 */
	IBOutlet NSTextField * _noAttributesLabel;
	
	IBOutlet NSTextField * _aliasTextField;
	
	
	
	// The pop-up menu for choosing the mapping style,
	// and the associated mapping style properties button.
	IBOutlet NSPopUpButton * _mappingStyleMenu;
	IBOutlet NSTextField * _mappingStyleMenuLabel;
	IBOutlet NSButton * _mappingStylePropertiesButton;
	
	
	
	// Labels
	IBOutlet NSButton *			_showLabelsButton;
	IBOutlet NSTextField *		_showLabelsAttributeLabel;
	IBOutlet NSPopUpButton *	_showLabelsAttributeMenu;
	
	
	
	/**
	 * The different style panels.
	 */
	IBOutlet NSPanel * _simpleFillStylePanel;
	IBOutlet NSPanel * _simpleSymbolPanel;
	IBOutlet NSPanel * _choroplethMapPanel;
	IBOutlet NSPanel * _proportionalSymbolPanel;
	IBOutlet NSPanel * _coloredProportionalSymbolPanel;
	
	
	/**
	 * The different style definition views.
	 */
	IBOutlet NSView * _simpleFillStyleView;
	IBOutlet NSView * _simpleSymbolView;
	IBOutlet NSView * _choroplethMapView;
	IBOutlet NSView * _proportionalSymbolView;
	IBOutlet NSView * _coloredProportionalSymbolView;
	
	IBOutlet NSScrollView * _styleScrollView;
	
	
	/**
	 * Outlets for the simple fill style view.
	 */
	IBOutlet NSButton * _fillStyleDrawContourButton;
	IBOutlet NSTextField * _fillStyleLineWidthLabel;
	IBOutlet NSTextField * _fillStyleLineWidthField;
	IBOutlet NSTextField * _fillStyleLineColorLabel;
	IBOutlet NSColorWell * _fillStyleLineColorWell;
	IBOutlet NSButton * _fillStyleFillFeatureButton;
	IBOutlet NSTextField * _fillStyleFillColorLabel;
	IBOutlet NSColorWell * _fillStyleFillColorWell;

	/**
	 * Outlets for the simple symbol style view.
	 */
	IBOutlet TMBezierPathView * _simpleSymbolTypeView;
	IBOutlet NSWindow * _simpleSymbolChooseWindow;
	IBOutlet NSTextField * _simpleSymbolWidth;
	IBOutlet NSTextField * _simpleSymbolHeight;
	
	IBOutlet NSButton * _simpleSymbolStyleDrawContourButton;
	IBOutlet NSTextField * _simpleSymbolStyleLineWidthLabel;
	IBOutlet NSTextField * _simpleSymbolStyleLineWidthField;
	IBOutlet NSTextField * _simpleSymbolStyleLineColorLabel;
	IBOutlet NSColorWell * _simpleSymbolStyleLineColorWell;
	
	IBOutlet NSButton * _simpleSymbolStyleFillFeatureButton;
	IBOutlet NSTextField * _simpleSymbolStyleFillColorLabel;
	IBOutlet NSColorWell * _simpleSymbolStyleFillColorWell;

	IBOutlet NSButton * _simpleSymbolFeatureDrawContourButton;
	IBOutlet NSTextField * _simpleSymbolFeatureLineWidthLabel;
	IBOutlet NSTextField * _simpleSymbolFeatureLineWidthField;
	IBOutlet NSTextField * _simpleSymbolFeatureLineColorLabel;
	IBOutlet NSColorWell * _simpleSymbolFeatureLineColorWell;
	
	IBOutlet NSButton * _simpleSymbolFeatureFillFeatureButton;
	IBOutlet NSTextField * _simpleSymbolFeatureFillColorLabel;
	IBOutlet NSColorWell * _simpleSymbolFeatureFillColorWell;
	
	IBOutlet NSMatrix * _symbolTypeMatrix;
	
	/**
	 * Outlets for the choropleth map style.
	 */
	IBOutlet NSPopUpButton * _choroplethAttributeMenu;
	IBOutlet NSPopUpButton * _choroplethClassificationMenu;
	IBOutlet NSButton * _choroplethDrawContourButton;
	IBOutlet NSTextField * _choroplethLineWidthLabel;
	IBOutlet NSTextField * _choroplethLineWidthField;
	IBOutlet NSTextField * _choroplethLineColorLabel;
	IBOutlet NSColorWell * _choroplethLineColorWell;
	
	/**
	 * Outlets for the proportional symbol map style.
	 */
	IBOutlet TMBezierPathView * _propSymbolTypeView;
	IBOutlet NSWindow * _propSymbolChooseWindow;
	IBOutlet NSMatrix * _propSymbolTypeMatrix;
	
	IBOutlet NSPopUpButton * _propSymbolAttributeMenu;
	IBOutlet NSTextField * _propSymbolCalibrationSizeField;
	IBOutlet NSTextField * _propSymbolCalibrationValueField;
	IBOutlet NSTextField * _propSymbolBiasField;
	
	IBOutlet NSButton * _propSymbolStyleDrawContourButton;
	IBOutlet NSTextField * _propSymbolStyleLineWidthLabel;
	IBOutlet NSTextField * _propSymbolStyleLineWidthField;
	IBOutlet NSTextField * _propSymbolStyleLineColorLabel;
	IBOutlet NSColorWell * _propSymbolStyleLineColorWell;
	
	IBOutlet NSButton * _propSymbolStyleFillFeatureButton;
	IBOutlet NSTextField * _propSymbolStyleFillColorLabel;
	IBOutlet NSColorWell * _propSymbolStyleFillColorWell;
	
	IBOutlet NSButton * _propSymbolFeatureDrawContourButton;
	IBOutlet NSTextField * _propSymbolFeatureLineWidthLabel;
	IBOutlet NSTextField * _propSymbolFeatureLineWidthField;
	IBOutlet NSTextField * _propSymbolFeatureLineColorLabel;
	IBOutlet NSColorWell * _propSymbolFeatureLineColorWell;
	
	IBOutlet NSButton * _propSymbolFeatureFillFeatureButton;
	IBOutlet NSTextField * _propSymbolFeatureFillColorLabel;
	IBOutlet NSColorWell * _propSymbolFeatureFillColorWell;
	
	
	/**
	 * Outlets for the colored proportional symbol map style.
	 */
	IBOutlet TMBezierPathView * _colPropSymbolTypeView;
	IBOutlet NSWindow * _colPropSymbolChooseWindow;
	IBOutlet NSMatrix * _colPropSymbolTypeMatrix;
	
	IBOutlet NSPopUpButton * _colPropSymbolAttributeMenu;
	IBOutlet NSTextField * _colPropSymbolCalibrationSizeField;
	IBOutlet NSTextField * _colPropSymbolCalibrationValueField;
	IBOutlet NSTextField * _colPropSymbolBiasField;
	
	IBOutlet NSButton * _colPropSymbolStyleDrawContourButton;
	IBOutlet NSTextField * _colPropSymbolStyleLineWidthLabel;
	IBOutlet NSTextField * _colPropSymbolStyleLineWidthField;
	IBOutlet NSTextField * _colPropSymbolStyleLineColorLabel;
	IBOutlet NSColorWell * _colPropSymbolStyleLineColorWell;
	
	IBOutlet NSButton * _colPropSymbolFeatureDrawContourButton;
	IBOutlet NSTextField * _colPropSymbolFeatureLineWidthLabel;
	IBOutlet NSTextField * _colPropSymbolFeatureLineWidthField;
	IBOutlet NSTextField * _colPropSymbolFeatureLineColorLabel;
	IBOutlet NSColorWell * _colPropSymbolFeatureLineColorWell;
	
	IBOutlet NSButton * _colPropSymbolFeatureFillFeatureButton;
	IBOutlet NSTextField * _colPropSymbolFeatureFillColorLabel;
	IBOutlet NSColorWell * _colPropSymbolFeatureFillColorWell;

	IBOutlet NSPopUpButton * _colPropSymbolFillAttributeMenu;
	IBOutlet NSPopUpButton * _colPropSymbolFillClassificationMenu;
	
	
	
	// Outlets for the joining data file dialog.
	IBOutlet NSWindow *			_joinDataFileDialog;
	IBOutlet NSPopUpButton *	_joinDataFileCSVFieldMenu;
	IBOutlet NSPopUpButton *	_joinDataFileAttributeMenu;
	IBOutlet NSTextField *		_joinDataFilePath;
	
}







/**
 * Returns the layer panel controller.
 */
+(id)sharedLayerPanelController;




/**
 * Closes the window.
 */
-(IBAction)endLayerSheet:(id)sender;



/**
 * Method for terminating the layer sheet dialog.
 */
-(void)layerSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;




/**
 * Retrieves and returns the layer array from the main document.
 */
-(NSMutableArray*)layers;


/**
 * Sets the layer array in the main document.
 */
-(void)setLayers:(NSMutableArray*)layers;





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





/**
 * Action for adding a new layer. A layer can be read as a Shape file
 * or a BNA file.
 */
-(IBAction)addLayer:(id)sender;




/**
 * Removes the selected layer(s) in the layer list.
 */
-(IBAction)removeLayer:(id)sender;




/**
 * Action called after an open file dialog. This method reads Shape and
 * BNA files.
 */
-(void)openPanelDidEnd:(NSOpenPanel*)panel 
	returnCode:(int)returnCode  
	contextInfo:(void*)contextInfo;




/**
 * Delegate method for the table views in the panel.
 * This method is called after a selection change.
 */
-(void)tableViewSelectionDidChange:(NSNotification*)aNotification;




/**
 * Updates the panel.
 */
-(void)updatePanel;



/**
 * Updates the panel content with no selected layer.
 */
-(void)updatePanelWithNoSelection;



/**
 * Updates the panel using a single selected layer.
 */
-(void)updatePanelWithLayer:(TMLayer*)layer;


/**
 * Updates the panel content for a multiple selection case.
 */
-(void)updatePanelWithMultipleSelection;


-(void)updateStyleSettingsWithLayer:(TMLayer*)layer;		// Updates the style settings using the provided layer.
-(void)updateLabelSettingsWithLayer:(TMLayer*)layer;		// Updates the label settings using the provided layer.




/**
 * Delegate method for text fields.
 */
-(void)controlTextDidChange:(NSNotification*)aNotification;





// Returns the selected layer, or nil if there is none.
-(TMLayer*)selectedLayer;

// Returns the index of the selected layer, or -1 if there is none.
-(NSInteger)indexOfSelectedLayer;




// This action is called if the type of style should be changed.
-(IBAction)styleTypeChanged:(id)sender;

//Shows the appropriate style properties for the currently selected layer.
-(IBAction)showStyleProperties:(id)sender;

// The actions for preparing the style properties dialogs.
-(void)choroplethMapStylePrepareDialog;
-(void)proportionalSymbolStylePrepareDialog;
-(void)coloredProportionalSymbolStylePrepareDialog;

// The different actions to undertake when a style property dialog has finished.
-(IBAction)simpleFillStyleTerminate:(id)sender;
-(IBAction)simpleSymbolStyleTerminate:(id)sender;
-(IBAction)choroplethMapStyleTerminate:(id)sender;
-(IBAction)proportionalSymbolStyleTerminate:(id)sender;
-(IBAction)coloredProportionalSymbolStyleTerminate:(id)sender;

-(IBAction)showLabelHasChanged:(id)sender;
-(IBAction)showLabelAttributeHasChanged:(id)sender;



#pragma mark --- Simple Fill Style Panel ---

/**
 * Actions for the simple fill style panel.
 */
-(IBAction)fillStyleDrawContourChanged:(id)sender;
-(IBAction)fillStyleLineColorChanged:(id)sender;
-(IBAction)fillStyleFillFeatureChanged:(id)sender;
-(IBAction)fillStyleFillColorChanged:(id)sender;



#pragma mark --- Simple Symbol Style Panel ---

/**
 * Actions for the simple symbol style panel.
 */
-(IBAction)chooseSymbol:(id)sender;
-(IBAction)chooseSymbolDidEnd:(id)sender;
-(IBAction)chooseSymbolClose:(id)sender;

-(IBAction)simpleSymbolStyleDrawContourChanged:(id)sender;
-(IBAction)simpleSymbolStyleLineColorChanged:(id)sender;
-(IBAction)simpleSymbolStyleFillFeatureChanged:(id)sender;
-(IBAction)simpleSymbolStyleFillColorChanged:(id)sender;

-(IBAction)simpleSymbolFeatureDrawContourChanged:(id)sender;
-(IBAction)simpleSymbolFeatureLineColorChanged:(id)sender;
-(IBAction)simpleSymbolFeatureFillFeatureChanged:(id)sender;
-(IBAction)simpleSymbolFeatureFillColorChanged:(id)sender;



#pragma mark --- Choropleth Map Style Panel ---

/**
 * Actions for the choropleth map style panel.
 */
-(IBAction)choroplethAttributeChanged:(id)sender;
-(IBAction)choroplethClassificationChanged:(id)sender;
-(IBAction)choroplethDrawContourChanged:(id)sender;
-(IBAction)choroplethLineColorChanged:(id)sender;



#pragma mark --- Proportional Symbol Style Panel ---

/**
 * Actions for the proportional symbol style panel.
 */
-(IBAction)choosePropSymbol:(id)sender;
-(IBAction)choosePropSymbolDidEnd:(id)sender;
-(IBAction)choosePropSymbolClose:(id)sender;

-(IBAction)propSymbolAttributeChanged:(id)sender;

-(IBAction)propSymbolStyleDrawContourChanged:(id)sender;
-(IBAction)propSymbolStyleLineColorChanged:(id)sender;
-(IBAction)propSymbolStyleFillFeatureChanged:(id)sender;
-(IBAction)propSymbolStyleFillColorChanged:(id)sender;

-(IBAction)propSymbolFeatureDrawContourChanged:(id)sender;
-(IBAction)propSymbolFeatureLineColorChanged:(id)sender;
-(IBAction)propSymbolFeatureFillFeatureChanged:(id)sender;
-(IBAction)propSymbolFeatureFillColorChanged:(id)sender;




#pragma mark --- Colored Proportional Symbol Style ---

/**
 * Actions for the colored proportional symbol style panel.
 */
-(IBAction)chooseColPropSymbol:(id)sender;
-(IBAction)chooseColPropSymbolDidEnd:(id)sender;
-(IBAction)chooseColPropSymbolClose:(id)sender;




#pragma mark --- Attribute handling ---

-(IBAction)joinDataFile:(id)sender;

-(void)joinDataFileOpenDialogDidEnd:(NSOpenPanel*)panel 
						 returnCode:(int)returnCode  
						contextInfo:(void*)contextInfo;

-(IBAction)joinDataFileTerminate:(id)sender;


@end
