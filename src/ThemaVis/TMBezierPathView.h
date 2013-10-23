//
//  TMBezierPathView.h
//  ThemaVis
//
//  Created by Christian on 07.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMBezierPathView : NSView
{
	NSBezierPath * _path;
}


-(NSBezierPath*)path;
-(void)setPath:(NSBezierPath*)path;

// Returns the NSBezierPath as FScript initialization string.
-(NSString*)pathAsFScriptString:(NSString*)variableName;

@end

