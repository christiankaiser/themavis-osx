/**
 * ThemaMap/TMFeature
 *
 * @version 1.0, 24.3.2008
 * @author Christian Kaiser
 * @copyright 2008 361degres
 *
 * @description This class represents a feature with all its attributes.
 * The feature can be spatial or not. An eventually present geometry is stored
 * in the attribute "geom". If the geometry is not a point, it can have 
 * another attribute "center" containing a point geometry and defining the
 * center of the geometry contained in the "geom" attribute. The "center"
 * attribute is used by some styles like TMSymbolStyle, 
 * TMProportionalSymbolStyle or TMColoredProportionalSymbolStyle.
 */
 
 

#import <Cocoa/Cocoa.h>


@interface TMFeature : NSObject <NSCoding>
{
	NSMutableDictionary * _attributes;
}



-(NSMutableDictionary*)attributes;
-(id)attributeForKey:(NSString*)key;
-(void)setAttribute:(id)attribute forKey:(NSString*)key;



@end
