/* FSNSValue.h Copyright (c) 2003-2006 Philippe Mougin.   */
/*   This software is open source. See the license.  */  

#import <Foundation/Foundation.h>


@interface NSValue (FSNSValue) 

///////////////////////////////// USER METHODS /////////////////////////

// Common

- (id)clone;
- (NSString *)printString;

// NSPoint

- (NSRect)corner:(NSPoint)operand;
- (NSRect)extent:(NSPoint)operand;
- (CGFloat)x;
- (CGFloat)y;

// NSRange

+ (NSRange)rangeWithLocation:(NSUInteger)location length:(NSUInteger)length;
- (NSUInteger)length;
- (NSUInteger)location;

// NSRect

- (NSPoint)corner;
- (NSPoint)extent;
- (NSPoint)origin;

// NSSize

+ (NSSize)sizeWithWidth:(CGFloat)width height:(CGFloat)height;
- (CGFloat)height;
- (CGFloat)width;


@end
