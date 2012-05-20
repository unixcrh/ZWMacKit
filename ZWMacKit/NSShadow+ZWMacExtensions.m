#import "NSShadow+ZWMacExtensions.h"


@implementation NSShadow (ZWMacExtensions)

+ (NSShadow *)shadowWithColor:(NSColor *)pColor offset:(NSSize)pOffset blurRadius:(CGFloat)pBlurRadius {
	return [[self alloc] initWithColor:pColor offset:pOffset blurRadius:pBlurRadius];
}
- (id)initWithColor:(NSColor *)pColor offset:(NSSize)pOffset blurRadius:(CGFloat)pBlurRadius {
	if((self = [super init])) {
		[self setShadowColor:pColor];
		[self setShadowOffset:pOffset];
		[self setShadowBlurRadius:pBlurRadius];
	}
	return self;
}

@end
