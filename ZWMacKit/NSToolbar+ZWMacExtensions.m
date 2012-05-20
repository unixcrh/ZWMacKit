#import "NSToolbar+ZWMacExtensions.h"
#import <ZWCoreKit/NSArray+ZWExtensions.h>

@implementation NSToolbar (ZWMacExtensions)

- (NSToolbarItem *)itemWithIdentifier:(NSString *)pIdentifier {
	NSArray *items = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"itemIdentifier == %@", pIdentifier]];
	return [items firstObject];
}

@end
