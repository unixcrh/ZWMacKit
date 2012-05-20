#import <Cocoa/Cocoa.h>

@interface NSGradient (ZWMacExtensions)

+ (id)gradientWithHexColorsAndLocations:(NSUInteger)firstColor, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)gradientWithStartingColor:(NSColor *)pStartingColor endingColor:(NSColor *)pEndingColor;
- (void)getColors:(NSArray **)pColors locations:(NSArray **)pLocations;
- (NSGradient *)gradientByAdjustingColorsHue:(CGFloat)pHue 
								  saturation:(CGFloat)pStaturation 
								  brightness:(CGFloat)pBrightness 
									   alpha:(CGFloat)pAlpha;
- (NSGradient *)gradientByBlendingIntoColor:(NSColor *)pColor fraction:(CGFloat)pFraction;

@end
