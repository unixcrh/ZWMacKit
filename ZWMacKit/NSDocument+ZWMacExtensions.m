#import "NSDocument+ZWMacExtensions.h"
#import <ZWCoreKit/NSObject+ZWExtensions.h>

@implementation NSDocument (ZWMacExtensions)

#pragma mark - Properties

@dynamic identifier;

- (NSString *)identifier {
	static void *identifierKey;
	NSString *identifier = [self associatedObjectForKey:identifierKey];
	if(identifier == nil) {
		identifier = ZWGloballyUniqueIdentifier();
		[self setAssociatedObject:identifier forKey:identifierKey policy:OBJC_ASSOCIATION_RETAIN];
	}
	return identifier;
}

@end
