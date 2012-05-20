#import <Cocoa/Cocoa.h>

@interface NSColor (ZWMacExtensions)

@property (nonatomic, readonly) CGColorRef CGColor;

+ (NSColor *)colorWithRGB:(NSUInteger)pRGB alpha:(CGFloat)pAlpha;
+ (NSColor *)colorWithRGB:(NSUInteger)pRGB;
+ (NSColor *)colorWithRGBA:(NSUInteger)pRGBA;
- (NSColor *)colorByAdjustingHue:(CGFloat)pHue saturation:(CGFloat)pSaturation brightness:(CGFloat)pBrightness alpha:(CGFloat)pAlpha;

- (void)compositeInRect:(NSRect)pRect;
- (void)compositeInRect:(NSRect)pRect operation:(NSCompositingOperation)pOperation;

@end
