//
//  NSString+Explode.m
//  CH-Traveltime
//
//  Created by Christian Kaiser on 08.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+Explode.h"


@implementation NSString (TMStringExplode)

-(NSArray*)explodeUsing:(NSString*)separator
{

	NSMutableArray *strings = [NSMutableArray arrayWithCapacity:1];

	NSRange sepRange = NSMakeRange(0, 0);
	NSRange oldSepRange;
	BOOL allSubstringsFound = NO;
	
	NSUInteger strlen = [self length];
	
	while (!allSubstringsFound)
	{
		oldSepRange = sepRange;
	
		NSUInteger rangeStart = sepRange.location + sepRange.length;
	
		sepRange = [self rangeOfString:separator options:0
			range:NSMakeRange(rangeStart, (strlen - rangeStart))];
		
		
		// Extract the substring.
		
		if (sepRange.location == NSNotFound && sepRange.length == 0)
		{
			allSubstringsFound = YES;
			sepRange.location = strlen;
		}
		
		NSString *substring = [self substringWithRange:
			NSMakeRange(rangeStart, (sepRange.location - rangeStart))];
		
		[strings addObject:substring];
	
	}

	 // Make an immutable copy.
	return [[strings copy] autorelease];

}



@end
