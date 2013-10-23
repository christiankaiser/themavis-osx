//
//  NSString+Explode.h
//  CH-Traveltime
//
//  Created by Christian Kaiser on 08.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (TMStringExplode)

-(NSArray*)explodeUsing:(NSString*)separator;

@end
