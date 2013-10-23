//
//  TMAppDelegate.h
//  ThemaVis
//
//  Created by Christian Kaiser on 14.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMAppDelegate : NSObject
{
}


-(IBAction)showOrHideLayerPanel:(id)sender;		// Obsolète. Remplacé par showLayerPanel:
-(IBAction)showLayerPanel:(id)sender;


-(IBAction)showOrHideClassificationPanel:(id)sender;
-(IBAction)showOrHideColorTablePanel:(id)sender;
-(IBAction)showOrHideShellPanel:(id)sender;
-(IBAction)showOrHideCommandLogPanel:(id)sender;

-(IBAction)showOrHideViewPanel:(id)sender;		// Obsolète. Remplacé par showViewPanel:
-(IBAction)showViewPanel:(id)sender;

-(IBAction)insertMapView:(id)sender;			// Obsolète
-(IBAction)insertLegendView:(id)sender;			// Obsolète
-(IBAction)insertTextView:(id)sender;			// Obsolète



-(IBAction)showPagePropertiesPanel:(id)sender;

-(IBAction)exportToPDF:(id)sender;



@end
