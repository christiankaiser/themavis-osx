//
//  TMMapView.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMMapView.h"





@implementation TMMapView



-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        _layers = [[NSMutableArray alloc] initWithCapacity:1];
		_envelope = [[TMEnvelope alloc] init];
		
		_needsDisplay = NO;
		_displayUpdateInterval = 4.0f;
		
		_displayTimer = 
			[NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
				target:self 
				selector:@selector(displayNow) 
				userInfo:nil 
				repeats:YES];
				
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_layers = [decoder decodeObjectForKey:@"TMMapViewLayers"];
	_envelope = [decoder decodeObjectForKey:@"TMMapViewEnvelope"];
	_displayUpdateInterval = (NSTimeInterval)[decoder decodeDoubleForKey:@"TMMapViewDisplayUpdateInterval"];

	_needsDisplay = NO;
	_displayTimer = [NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
													 target:self 
												   selector:@selector(displayNow) 
												   userInfo:nil 
													repeats:YES];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_layers forKey:@"TMMapViewLayers"];
	[encoder encodeObject:_envelope forKey:@"TMMapViewEnvelope"];
	[encoder encodeDouble:(double)_displayUpdateInterval forKey:@"TMMapViewDisplayUpdateInterval"];
}









-(void)drawRect:(NSRect)rect
{
	
	// Draw super class settings
	[super drawRect:rect];
	
	// If there are no layers defined, do nothing.
	if ([_layers count] > 0)
	{
	
		// If there is no envelope defined, zoom to full extent.
		if (_envelope == nil)
			[self zoomToFullExtent];
	
	
		// Adjust the envelope to be proportional to the view.
		TMEnvelope *adjustedEnvelope = [self adjustedEnvelope];
	
	
		// Draw each layer: first the features, then the symbols and finally the labels.
		for (TMLayer *layer in _layers)
		{
			[layer drawFeaturesToRect:[self bounds] withEnvelope:adjustedEnvelope];
		}
		//NSLog(@"Features drawn.");
		
		for (TMLayer *layer in _layers)
		{
			[layer drawSymbolsToRect:[self bounds] withEnvelope:adjustedEnvelope];
		}
		//NSLog(@"Symbols drawn.");
		
		for (TMLayer *layer in _layers)
		{
			[layer drawLabelsToRect:[self bounds] withEnvelope:adjustedEnvelope];
		}
		//NSLog(@"Labels drawn.");
		
		
		
	}
	
	if (_isSelected)
		[super drawSelectionInRect:rect];
		
}






-(NSMutableArray*)layers
{
	return _layers;
}



-(NSUInteger)countOfLayers
{
	return [_layers count];
}




-(TMLayer*)objectInLayersAtIndex:(NSUInteger)index
{
	TMLayer *layer = [_layers objectAtIndex:index];
	return layer;
}



-(void)addObjectToLayers:(TMLayer*)layer
{
	[_layers addObject:layer];
}




-(void)insertObject:(TMLayer*)layer inLayersAtIndex:(NSUInteger)index
{
	[_layers insertObject:layer atIndex:index];
}



-(void)removeObjectFromLayersAtIndex:(NSUInteger)index
{
	[_layers removeObjectAtIndex:index];
}






-(TMEnvelope*)envelope
{
	return _envelope;
}



-(void)setEnvelope:(TMEnvelope*)envelope
{
	_envelope = envelope;
}




-(TMEnvelope*)adjustedEnvelope
{
	TMEnvelope *env = [[TMEnvelope alloc] initWithEnvelope:_envelope];
	
	double envWidthHeightRatio = [env width] / [env height];
	
	NSRect viewFrame = [self frame];
	double viewWidthHeightRatio = viewFrame.size.width / viewFrame.size.height;
	
	if (envWidthHeightRatio == viewWidthHeightRatio)
		return env;
		
	if (envWidthHeightRatio > viewWidthHeightRatio)
	{
		// Adjust the envelope's height.
		double envHeight = [env width] / viewWidthHeightRatio;
		double heightDiff = (envHeight - [env height]) / 2;
		[env setNorth:([env north] + heightDiff)];
		[env setSouth:([env south] - heightDiff)];
	}
	else
	{
		// Adjust the envelope's width.
		double envWidth = [env height] * viewWidthHeightRatio;
		double widthDiff = (envWidth - [env width]) / 2;
		[env setWest:([env west] - widthDiff)];
		[env setEast:([env east] + widthDiff)];
	}
	
	return env;
}



-(void)zoomToFullExtent
{
	NSUInteger nlyrs = [_layers count];
	if (nlyrs == 0) return;
	
	TMLayer *layer = [_layers objectAtIndex:0];
	_envelope = [[TMEnvelope alloc] initWithEnvelope:[layer envelope]];
	
	NSUInteger lyrcnt;
	for (lyrcnt = 1; lyrcnt < nlyrs; lyrcnt++)
	{
		layer = [_layers objectAtIndex:lyrcnt];
		[_envelope expandToIncludeEnvelope:[layer envelope]];
	}
	
}




#pragma mark --- Drawing the page ---


-(void)displaySoon
{
	_needsDisplay = YES;
}



-(void)displayNow
{
	if (_needsDisplay)
		[super setNeedsDisplay:YES];
	
	_needsDisplay = NO;
}


-(NSTimeInterval)displayUpdateInterval
{
	return _displayUpdateInterval;
}


-(void)setDisplayUpdateInterval:(NSTimeInterval)seconds
{
	_displayUpdateInterval = seconds;
	
	[_displayTimer invalidate];
	
	_displayTimer = 
		[NSTimer scheduledTimerWithTimeInterval:_displayUpdateInterval 
			target:self 
			selector:@selector(displayNow) 
			userInfo:nil 
			repeats:YES];
}



@end
