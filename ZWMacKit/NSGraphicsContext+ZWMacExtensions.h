#import <Cocoa/Cocoa.h>

@interface NSGraphicsContext (ZWMacExtensions)

- (void)performBlock:(void (^)(NSGraphicsContext *graphicsContext))pBlock;

@end
