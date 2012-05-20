#import "ZWCGImageValue.h"

@implementation ZWCGImageValue

#pragma mark - Properties

@synthesize CGImage;

- (void)setCGImage:(CGImageRef)pValue {
	if(pValue != CGImage) {
		if(CGImage != nil) {
			CGImageRelease(CGImage);
			CGImage = nil;
		}
		CGImage = CGImageRetain(pValue);
	}
}

#pragma mark - Dealloc

- (void)dealloc {
    self.CGImage = nil;
}

@end
