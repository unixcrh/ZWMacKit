#import "NSGradient+ZWMacExtensions.h"
#import "NSColor+ZWMacExtensions.h"

@implementation NSGradient (ZWMacExtensions)

+ (id)gradientWithHexColorsAndLocations:(NSUInteger)firstColor, ... {
	BOOL stop = NO;
	va_list ap;
	va_start(ap, firstColor);
	NSUInteger colorUnsignedInteger = firstColor;
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:10];
	CGFloat *locations = malloc(sizeof(CGFloat) * 10);
	NSUInteger locationsLength = 10;
	NSUInteger locationsIndex = 0;
	while(!stop) {
		if(colorUnsignedInteger > 0) {
			NSColor *color = nil;
			if(colorUnsignedInteger < 0xFFFFFF00) {
				color = [NSColor colorWithRGB:colorUnsignedInteger];
			} else {
				color = [NSColor colorWithRGBA:colorUnsignedInteger];
			}
			[colors addObject:color];
			CGFloat location = va_arg(ap, CGFloat);
			if(locationsIndex >= locationsLength) {
				locationsLength += 5;
				locations = realloc(locations, locationsLength);
			}
			locations[locationsIndex++] = location;
		} else {
			stop = YES;
		}
		colorUnsignedInteger = va_arg(ap, NSUInteger);
	}
	NSGradient *gradient = [[NSGradient alloc] initWithColors:colors
												  atLocations:(const CGFloat *)locations
												   colorSpace:[NSColorSpace genericRGBColorSpace]];
	free(locations);
	return gradient;
}
+ (id)gradientWithStartingColor:(NSColor *)pStartingColor endingColor:(NSColor *)pEndingColor {
	return [[self alloc] initWithStartingColor:pStartingColor endingColor:pEndingColor];
}
- (void)getColors:(NSArray **)pColors locations:(NSArray **)pLocations {
	if(pColors == nil || pLocations == nil) {
		return;
	}
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[self numberOfColorStops]];
	NSMutableArray *locations = [NSMutableArray arrayWithCapacity:[self numberOfColorStops]];
	for(NSInteger i = 0; i < [self numberOfColorStops]; ++i) {
		NSColor *color;
		CGFloat location;
		[self getColor:&color location:&location atIndex:i];
		[colors addObject:color];
		[locations addObject:[NSNumber numberWithFloat:location]];
	}
	*pColors = colors;
	*pLocations = locations;
}
- (NSGradient *)gradientByAdjustingColorsHue:(CGFloat)pHue 
								  saturation:(CGFloat)pStaturation 
								  brightness:(CGFloat)pBrightness 
									   alpha:(CGFloat)pAlpha {
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[self numberOfColorStops]];
	CGFloat *locations = (CGFloat *)malloc(sizeof(CGFloat) * [self numberOfColorStops]);
	for(NSInteger i = 0; i < [self numberOfColorStops]; ++i) {
		NSColor *color;
		CGFloat location;
		[self getColor:&color location:&location atIndex:i];
		[colors addObject:[color colorByAdjustingHue:pHue saturation:pStaturation brightness:pBrightness alpha:pAlpha]];
		locations[i] = location;
	}
	NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[self colorSpace]];
	free(locations);
	return gradient;
}
- (NSGradient *)gradientByBlendingIntoColor:(NSColor *)pColor fraction:(CGFloat)pFraction {
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[self numberOfColorStops]];
	CGFloat *locations = (CGFloat *)malloc(sizeof(CGFloat) * [self numberOfColorStops]);
	for(NSInteger i = 0; i < [self numberOfColorStops]; ++i) {
		NSColor *color;
		CGFloat location;
		[self getColor:&color location:&location atIndex:i];
		[colors addObject:[pColor blendedColorWithFraction:pFraction ofColor:color]];
		locations[i] = location;
	}
	NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[self colorSpace]];
	free(locations);
	return gradient;
}

@end
