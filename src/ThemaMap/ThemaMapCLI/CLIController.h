//
//  CLIController.h
//  ThemaMap
//
//  Created by Christian Kaiser on 04.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ThemaMap/ThemaMap.h>
#import <FScript/FScript.h>


@interface CLIController : NSObject
{
	IBOutlet TMPage * _page;
	IBOutlet FSInterpreterView * commandLineView;
}

@end
