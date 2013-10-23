//
//  TMStyle.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMFeature.h"
#import "TMEnvelope.h"


//#import "TMLegendView.h"
@class TMLayer;
@class TMLegendView;




@interface TMStyle : NSObject
{
}


-(void)orderFeaturesBeforeDrawing:(NSMutableArray*)features;
-(void)orderFeaturesBeforeDrawingSymbols:(NSMutableArray*)features;
-(void)orderFeaturesBeforeDrawingLabels:(NSMutableArray*)features;

-(void)drawFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;
-(void)drawSymbolForFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;
-(void)drawLabelForFeature:(TMFeature*)feat inRect:(NSRect)rect withEnvelope:(TMEnvelope*)envelope;

-(void)drawLegendForLayer:(TMLayer*)lyr inView:(TMLegendView*)legend;

@end
