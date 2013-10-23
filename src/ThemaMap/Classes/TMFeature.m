//
//  TMFeature.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMFeature.h"


@implementation TMFeature



-(id)init
{
	if ((self = [super init]))
	{
		_attributes = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}




-(id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init]))
	{
		_attributes = [decoder decodeObjectForKey:@"TMFeatureAttributes"];
	}
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:_attributes forKey:@"TMFeatureAttributes"];
}






-(NSMutableDictionary*)attributes
{
	return _attributes;
}



-(id)attributeForKey:(NSString*)key
{
	return [_attributes objectForKey:key];
}



-(void)setAttribute:(id)attribute forKey:(NSString*)key
{
	[_attributes setObject:attribute forKey:key];
}



@end
