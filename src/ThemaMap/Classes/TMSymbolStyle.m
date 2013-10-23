//
//  TMSymbolStyle.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degres. All rights reserved.
//

#import "TMSymbolStyle.h"

#import "TMLegendView.h"



@implementation TMSymbolStyle



-(id)init
{
    if ((self = [super init]))
	{
		_symbol = [NSBezierPath bezierPathWithRect:NSMakeRect(0,0,10,10)];
		_symbolHeight = 10;
		_symbolWidth = 10;
		_symbolStyle = [[TMFillStyle alloc] init];
		_featureStyle = [[TMFillStyle alloc] init];
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_symbol = [decoder decodeObjectForKey:@"TMSymbolStyleSymbol"];
	_symbolWidth = [decoder decodeIntegerForKey:@"TMSymbolStyleSymbolWidth"];
	_symbolHeight = [decoder decodeIntegerForKey:@"TMSymbolStyleSymbolHeight"];
	_symbolStyle = [decoder decodeObjectForKey:@"TMSymbolStyleSymbolStyle"];
	_featureStyle = [decoder decodeObjectForKey:@"TMSymbolStyleFeatureStyle"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_symbol forKey:@"TMSymbolStyleSymbol"];
	[encoder encodeInteger:_symbolWidth forKey:@"TMSymbolStyleSymbolWidth"];
	[encoder encodeInteger:_symbolHeight forKey:@"TMSymbolStyleSymbolHeight"];
	[encoder encodeObject:_symbolStyle forKey:@"TMSymbolStyleSymbolStyle"];
	[encoder encodeObject:_featureStyle forKey:@"TMSymbolStyleFeatureStyle"];
}










-(id)initWithRectOfWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
	if ((self = [super init]))
	{
		_symbolWidth = width;
		_symbolHeight = height;
	
		NSRect rect;
		rect.origin.x = 0;
		rect.origin.y = 0;
		rect.size.width = width;
		rect.size.height = height;
	
		_symbol = [NSBezierPath bezierPathWithRect:rect];
	}
	return self;
}





-(id)initWithOvalOfWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
	if ((self = [super init]))
	{
		_symbolWidth = width;
		_symbolHeight = height;
	
		NSRect rect;
		rect.origin.x = 0;
		rect.origin.y = 0;
		rect.size.width = width;
		rect.size.height = height;
	
		_symbol = [NSBezierPath bezierPathWithOvalInRect:rect];
	}
	return self;
}




-(id)initWithCircleOfSize:(NSUInteger)size
{
	if ((self = [super init]))
	{
		_symbolWidth = size;
		_symbolHeight = size;
	
		NSRect rect;
		rect.origin.x = 0;
		rect.origin.y = 0;
		rect.size.width = size;
		rect.size.height = size;
	
		_symbol = [NSBezierPath bezierPathWithOvalInRect:rect];
	}
	return self;
}





-(void)drawFeature:(TMFeature*)feat 
	inRect:(NSRect)rect 
	withEnvelope:(TMEnvelope*)envelope
{
	[_featureStyle drawFeature:feat inRect:rect withEnvelope:envelope];
}




-(void)drawSymbolForFeature:(TMFeature*)feat 
	inRect:(NSRect)rect 
	withEnvelope:(TMEnvelope*)envelope
{
	
	// Get the geometry from the feature.
	id geom = [feat attributeForKey:@"geom"];
	BOOL isPointFeature = YES;
	if (geom == nil) return;
	
	
	// If the geometry is not a TMPoint or does not inherit from TMPoint,
	// we try to retrieve the "center" attribute which may contain a TMPoint
	// representing the geometry's center.
	TMPoint *center;
	if ([geom isKindOfClass:[TMPoint class]] == NO)
	{
		isPointFeature = NO;
		center = [feat attributeForKey:@"center"];
	}
	else
	{
		center = (TMPoint*)geom;
	}
	
	if (center == nil)
	{
		center = [geom centroid];
		if (center == nil) return;
	}
	
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	NSBezierPath *symbolCopy = [_symbol copyWithZone:nil];
	if (symbolCopy == nil)
	{
		NSLog(@"[TMSymbolStyle] Unable to copy symbol.");
		return;
	}
	
	// Scale the symbol's bezier path to fit the width and height attributes.
	NSRect symbolBounds = [_symbol bounds];
	if (symbolBounds.size.width != _symbolWidth ||
		symbolBounds.size.height != _symbolHeight)
	{
		CGFloat scaleFactorX = _symbolWidth / symbolBounds.size.width;
		CGFloat scaleFactorY = _symbolHeight / symbolBounds.size.height;
		CGFloat scaleFactor = MIN(scaleFactorX, scaleFactorY);
		[transform scaleXBy:scaleFactor yBy:scaleFactor];
		
		[symbolCopy transformUsingAffineTransform:transform];
	}
	
	
	// Place the symbol's bezier path to the center of the feature.
	
	double symbolX = [center x] - [envelope west];
	symbolX *= rect.size.width / [envelope width];
	symbolX += rect.origin.x;
	symbolX -= _symbolWidth;
	
	double symbolY = [center y] - [envelope south];
	symbolY *= rect.size.height / [envelope height];
	symbolY += rect.origin.y;
	symbolY -= _symbolHeight;
	
	symbolBounds = [symbolCopy bounds];
	
	transform = [NSAffineTransform transform];
	[transform translateXBy:(symbolX - symbolBounds.origin.x + 
							 (symbolBounds.size.width / 2))
						yBy:(symbolY - symbolBounds.origin.y +
							 (symbolBounds.size.height / 2))];
	[symbolCopy transformUsingAffineTransform:transform];

	
	// Draw the symbol.
	if ([_symbolStyle fillFeature] && [_symbolStyle fillColor] != nil)
	{
		[[_symbolStyle fillColor] set];
		[symbolCopy fill];
	}
	
	if ([_symbolStyle drawBorder] && 
		[_symbolStyle borderColor] != nil && [_symbolStyle borderWidth] > 0.0)
	{
		[[_symbolStyle borderColor] set];
		[symbolCopy setLineWidth:[_symbolStyle borderWidth]];
		[symbolCopy stroke];
	}
	
}
	




-(NSBezierPath*)symbol
{
	return _symbol;
}



-(void)setSymbol:(NSBezierPath*)symbol
{
	_symbol = symbol;
}



-(NSUInteger)symbolWidth
{
	return _symbolWidth;
}



-(void)setSymbolWidth:(NSUInteger)width
{
	_symbolWidth = width;
}




-(NSUInteger)symbolHeight
{
	return _symbolHeight;
}



-(void)setSymbolHeight:(NSUInteger)height
{
	_symbolHeight = height;
}



-(TMFillStyle*)symbolStyle
{
	return _symbolStyle;
}



-(void)setSymbolStyle:(TMFillStyle*)symbolStyle
{
	_symbolStyle = symbolStyle;
}



-(TMFillStyle*)featureStyle
{
	return _featureStyle;
}



-(void)setFeatureStyle:(TMFillStyle*)featureStyle
{
	_featureStyle = featureStyle;
}







-(NSBezierPath*)symbolOfSize:(NSUInteger)size
{
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	NSBezierPath *symbolCopy = [_symbol copyWithZone:nil];
	if (symbolCopy == nil)
	{
		NSLog(@"[TMSymbolStyle symbolOfSize:] Unable to copy symbol.");
		return nil;
	}
	
	// Scale the symbol's bezier path to fit the inside the provided size.
	NSRect symbolBounds = [_symbol bounds];
	CGFloat scaleFactorX = size / symbolBounds.size.width;
	CGFloat scaleFactorY = size / symbolBounds.size.height;
	CGFloat scaleFactor = MIN(scaleFactorX, scaleFactorY);
	
	if (scaleFactor != 1.0f)
	{
		[transform scaleBy:scaleFactor];
		[symbolCopy transformUsingAffineTransform:transform];
	}
	
	return symbolCopy;
	
}







-(void)drawLegendForLayer:(TMLayer*)lyr inView:(TMLegendView*)legend
{
	
	// Draw from top to bottom all the required elements.
	CGFloat currentTop = [legend bounds].origin.y + [legend bounds].size.height;
	CGFloat left = [legend bounds].origin.x + 10;
	
	// Insert a margin of 10 pixels.
	currentTop -= 10;
	
	// Define an attributes dictionary for drawing the text.
	NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	
	// Define the size of the box, and set the cursor to the top of the drawing region.
	CGFloat fontSize = [[legend layerNameFont] pointSize];
	currentTop -= MAX(fontSize, _symbolHeight);
	
	
	// Define the layer name (use the alias if possible)
	NSString *layerName = [lyr name];
	if ([lyr alias] != nil && [[lyr alias] compare:@""] != NSOrderedSame)
	{
		layerName = [lyr alias];
	}
	
	
	// Set the font attributes.
	if ([legend layerNameFont] != nil)
		[attrs setObject:[legend layerNameFont] forKey:NSFontAttributeName];
	else
		[attrs setObject:[NSFont userFontOfSize:10] forKey:NSFontAttributeName];
	
	
	if ([legend layerNameColor] != nil)
		[attrs setObject:[legend layerNameColor] forKey:NSForegroundColorAttributeName];
	else
		[attrs setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	
	
	// Draw the symbol.
	CGFloat symbolBottom = currentTop;
	if (fontSize > _symbolHeight) symbolBottom += (fontSize - _symbolHeight) / 2.0f;
	//NSRect symbolRect = NSMakeRect(left, symbolBottom, _symbolWidth, _symbolHeight);
	
	// Scale the symbol's bezier path to fit the width and height attributes.
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	NSBezierPath *symbolCopy = [_symbol copyWithZone:nil];
	if (symbolCopy == nil)
	{
		NSLog(@"[TMSymbolStyle] Unable to copy symbol.");
		return;
	}
	
	NSRect symbolBounds = [_symbol bounds];
	if (symbolBounds.size.width != _symbolWidth || symbolBounds.size.height != _symbolHeight)
	{
		CGFloat scaleFactorX = _symbolWidth / symbolBounds.size.width;
		CGFloat scaleFactorY = _symbolHeight / symbolBounds.size.height;
		[transform scaleXBy:scaleFactorX yBy:scaleFactorY];
		[symbolCopy transformUsingAffineTransform:transform];
	}
	
	
	// Place the symbol at the right place
	transform = [NSAffineTransform transform];
	[transform translateXBy:(left - symbolBounds.origin.x)
						yBy:(symbolBottom - symbolBounds.origin.y)];
	[symbolCopy transformUsingAffineTransform:transform];
	
	
	
	// Draw the symbol.
	if ([_symbolStyle fillFeature] && [_symbolStyle fillColor] != nil)
	{
		[[_symbolStyle fillColor] set];
		[symbolCopy fill];
	}
	
	if ([_symbolStyle drawBorder] && 
		[_symbolStyle borderColor] != nil && [_symbolStyle borderWidth] > 0.0)
	{
		[[_symbolStyle borderColor] set];
		[symbolCopy setLineWidth:[_symbolStyle borderWidth]];
		[symbolCopy stroke];
	}
	
	
	
	// Write the layer name.
	CGFloat textBottom = currentTop;
	if (_symbolHeight > fontSize) textBottom += (_symbolHeight - fontSize) / 2.0f - 5.0f;
	
	
	[layerName drawAtPoint:NSMakePoint(left + _symbolWidth + 10.0f, textBottom)  withAttributes:attrs];
	
}

	
@end
