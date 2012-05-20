#import "NSUndoManager+ZWMacExtensions.h"

@implementation NSUndoManager (ZWMacExtensions)


- (void)performRegisteredUndoWithBlock:(void (^)(void))pBlock {
	if(pBlock != nil) {
		pBlock();
	}
}
- (void)registerUndoWithBlock:(void (^)(void))pBlock {
	[self registerUndoWithTarget:self selector:@selector(performRegisteredUndoWithBlock:) object:pBlock];
}

@end
