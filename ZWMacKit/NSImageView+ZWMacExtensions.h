#import <Cocoa/Cocoa.h>


@interface NSImageView (ZWMacExtensions)

+ (id)imageViewWithImage:(NSImage *)pImage;
- (id)initWithImage:(NSImage *)pImage;
+ (id)imageViewWithImageNamed:(NSString *)pImageName;
- (id)initWithImageNamed:(NSString *)pImageName;

@end
