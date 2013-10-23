/*
 *  TMUtilities.h
 *  ThemaVis
 *
 *  Created by Christian on 07.07.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>


NSRect TMProportionRect1WithRect2 (NSRect rect1, NSRect rect2);


// An easy function for displaying an error in one call.
void TMDisplayError(NSString *errorText, NSString *informativeText);
