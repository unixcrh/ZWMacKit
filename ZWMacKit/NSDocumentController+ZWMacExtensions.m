#import "NSDocumentController+ZWMacExtensions.h"
#import "NSDocument+ZWMacExtensions.h"

@implementation NSDocumentController (ZWMacExtensions)

- (NSDocument *)documentWithIdentifier:(NSString *)pIdentifier {
	NSArray *documents = [self.documents copy];
	for(NSDocument *document in documents) {
		if([document.identifier isEqualToString:pIdentifier]) {
			return document;
		}
	}
	return nil;
}

@end
