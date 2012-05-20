#import "NSGraphicsContext+ZWMacExtensions.h"

@implementation NSGraphicsContext (ZWMacExtensions)


- (void)performBlock:(void (^)(NSGraphicsContext *graphicsContext))pBlock {
	if(pBlock == nil) {
		return;
	}
	[self saveGraphicsState];
	pBlock(self);
	[self restoreGraphicsState];
}

@end
