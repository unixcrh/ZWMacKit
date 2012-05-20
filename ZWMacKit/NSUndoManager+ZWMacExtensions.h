#import <Foundation/Foundation.h>

@interface NSUndoManager (ZWMacExtensions)

- (void)registerUndoWithBlock:(void (^)(void))pBlock;

@end
