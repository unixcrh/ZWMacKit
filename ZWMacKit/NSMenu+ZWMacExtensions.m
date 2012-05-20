#import "NSMenu+ZWMacExtensions.h"

@implementation NSMenu (ZWMacExtensions)

- (NSMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
	NSMenu *menu = self;
	for(NSUInteger position = 0; position < indexPath.length - 1; position++) {
		menu = [[menu itemAtIndex:[indexPath indexAtPosition:position]] submenu];
	}
	return [menu itemAtIndex:[indexPath indexAtPosition:indexPath.length - 1]];
}

@end
