//
//  TestController.h
//  ThemaMap
//
//  Created by Christian on 24.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>



@interface TestController : NSObject
{
	IBOutlet TMPage * _page;
}

-(IBAction)doTest:(id)sender;

@end
