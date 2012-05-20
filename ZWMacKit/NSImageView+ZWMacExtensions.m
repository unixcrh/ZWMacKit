#import "NSImageView+ZWMacExtensions.h"


@implementation NSImageView (ZWMacExtensions)

+ (id)imageViewWithImage:(NSImage *)pImage {
	return [(NSImageView *)[self alloc] initWithImage:pImage];
}
- (id)initWithImage:(NSImage *)pImage {
	if((self = [super initWithFrame:NSMakeRect(0, 0, [pImage size].width, [pImage size].height)])) {
		[self setImage:pImage];
	}
	return self;
}
+ (id)imageViewWithImageNamed:(NSString *)pImageName {
	return [[self alloc] initWithImageNamed:pImageName];
}
- (id)initWithImageNamed:(NSString *)pImageName {
	return [self initWithImage:[NSImage imageNamed:pImageName]];
}

@end
