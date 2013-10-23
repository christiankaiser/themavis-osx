//
//  TMTextView.h
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361DEGRES. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMView.h"
#import "TMTextField.h"




@interface TMTextView : TMView
{
	TMTextField * _textView;
//	NSString * _text;
//	NSMutableDictionary * _attributes;
}



-(TMTextField*)textView;



//-(NSString*)text;
//-(void)setText:(NSString*)text;
//
//-(NSMutableDictionary*)textAttributes;
//-(void)setTextAttributes:(NSMutableDictionary*)textAttributes;




@end
