//
//  TMTextView.m
//  ThemaMap
//
//  Created by Christian Kaiser on 12.03.08.
//  Copyright 2008 361degrÈes. All rights reserved.
//

#import "TMTextView.h"


@implementation TMTextView


-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		_textView = [[TMTextField alloc] initWithFrame:[self bounds]];
		[_textView insertText:@"New text view"];
		[_textView setSelectable:NO];
		
		[self addSubview:_textView];
		[self setAutoresizesSubviews:NO];
		[_textView setVerticallyResizable:NO];

		[self setIsSelected:NO];
    }
    return self;
}





-(id)initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	_textView = [decoder decodeObjectForKey:@"TMTextViewTextView"];
	return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:_textView forKey:@"TMTextViewTextView"];
}







-(void)drawRect:(NSRect)rect
{	
	if (_isSelected)
		[super drawSelectionInRect:rect];
}





-(TMTextField*)textView
{
	return _textView;
}




-(BOOL)viewHasInlineEditMode
{
	return YES;
}




-(void)startEditing
{
	[_textView setEditable:YES];
	[_textView selectAll:self];
	[[self window] makeFirstResponder:_textView];
}


-(void)endEditing
{
	[_textView setSelectedRange:NSMakeRange(0, 0)];
	[_textView setSelectable:NO];
}



-(void)deselect
{
	[self endEditing];
	[super deselect];
}



-(void)setFrame:(NSRect)frame
{
	//NSLog(@"TMTextView setFrame:");
	[super setFrame:frame];
	[_textView setFrame:[self bounds]];
}

-(void)setFrameSize:(NSSize)size
{
	//NSLog(@"TMTextView setFrameSize:");
	[super setFrameSize:size];
	[_textView setFrame:[self bounds]];
}


-(void)setFrameOrigin:(NSPoint)origin
{
	//NSLog(@"TMTextView setFrameOrigin:");
	[super setFrameOrigin:origin];
	[_textView setFrame:[self bounds]];
}




@end
