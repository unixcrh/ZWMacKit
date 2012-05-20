#import "NSEvent+ZWMacExtensions.h"


@implementation NSEvent (ZWMacExtensions)

- (NSPoint)locationInView:(NSView *)pView {
	return [pView convertPoint:[self locationInWindow] fromView:nil];
}

@end
