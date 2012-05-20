#import <Foundation/Foundation.h>


@interface NSShadow (ZWMacExtensions)

+ (NSShadow *)shadowWithColor:(NSColor *)pColor offset:(NSSize)pOffset blurRadius:(CGFloat)pBlurRadius;
- (id)initWithColor:(NSColor *)pColor offset:(NSSize)pOffset blurRadius:(CGFloat)pBlurRadius;

@end
