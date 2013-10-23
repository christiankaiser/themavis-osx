/*   FSPointer.h Copyright (c) 2004-2006 Philippe Mougin.   */
/*   This software is open source. See the license.         */  

#import <Foundation/Foundation.h>
#import <stddef.h>

@class FSGenericPointer; 
@class FSObjectPointer;
 
@interface FSPointer : NSObject
{
  NSUInteger retainCount;
  __strong void *cPointer;
}
  

/////////////////////////// USER METHODS ////////////////////////////

+ (FSGenericPointer *) allocateCollectable:(NSUInteger)size;
+ (FSGenericPointer *) allocateCollectable:(NSUInteger)size options:(NSUInteger)options;
+ (FSGenericPointer *) malloc:(size_t)size;
+ (FSObjectPointer *)  objectPointer;
+ (FSObjectPointer *)  objectPointer:(size_t)count;

- (void *) cPointer;

@end
