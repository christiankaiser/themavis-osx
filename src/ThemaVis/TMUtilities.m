/*
 *  TMUtilities.c
 *  ThemaVis
 *
 *  Created by Christian on 07.07.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import "TMUtilities.h"


NSRect TMProportionRect1WithRect2 (NSRect rect1, NSRect rect2)
{
	float widthHeight1 = rect1.size.width / rect1.size.height;
	float widthHeight2 = rect2.size.width / rect2.size.height;
	
	if (widthHeight1 == widthHeight2)
		return rect1;
	
	if (widthHeight1 > widthHeight2)
	{
		// Adapt the height.
		float oldHeight = rect1.size.height;
		rect1.size.height = 
			rect1.size.width / rect2.size.width * rect2.size.height;
		
		float heightDiff = (rect1.size.height - oldHeight);
		rect1.origin.y -= heightDiff / 2;
		
		return rect1;
	}
	
	if (widthHeight1 < widthHeight2)
	{
		// Adapt the width.
		float oldWidth = rect1.size.width;
		rect1.size.width = 
			rect1.size.height * rect2.size.width / rect2.size.height;
		
		float widthDiff = (rect1.size.width - oldWidth);
		rect1.origin.x -= widthDiff / 2;
	}
	
	return rect1;
}





void TMDisplayError(NSString *errorText, NSString *informativeText)
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:errorText];
	[alert setInformativeText:informativeText];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
}


