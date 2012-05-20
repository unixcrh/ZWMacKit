#import "NSColor+ZWMacExtensions.h"
#import <ZWCoreKit/NSObject+ZWExtensions.h>
#import <ZWCoreKit/CGImage+ZWExtensions.h>
#import <ZWCoreKit/CGColor+ZWExtensions.h>

@interface NSColorCGColorStorage : NSObject

@property (nonatomic, assign) CGColorRef color;

@end
@implementation NSColorCGColorStorage

@synthesize color;

- (void)setColor:(CGColorRef)pValue {
	if(color != nil) {
		CGColorRelease(color);
	}
	color = nil;
	if(pValue != nil) {
		color = CGColorRetain(pValue);
	}
}

- (void)dealloc {
	CGColorRelease(color);
}

@end

@implementation NSColor (ZWMacExtensions)

+ (void)load {
	@autoreleasepool {
		[self swizzleInstanceMethodsWithPrefix:@"zw_"];
	}
}

@dynamic CGColor;

- (CGColorRef)zw_CGColor {
	static void *cgColorStorageKey;
	NSColorCGColorStorage *storage = [self associatedObjectForKey:cgColorStorageKey];
	if(storage == nil) {
		storage = [[NSColorCGColorStorage alloc] init];
		
		CGColorRef color = nil;
		if([[self colorSpaceName] isEqualToString:NSPatternColorSpace]) {
			CGImageRef image = CGImageCreateWithData([[self patternImage] TIFFRepresentation]);
			color = CGColorCreateWithPatternImage(image);
			CGImageRelease(image);
			
		} else {
			NSColor *convertColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
			color = CGColorCreate([[convertColor colorSpace] CGColorSpace], 
								  (const CGFloat[]){
									  [convertColor redComponent], 
									  [convertColor greenComponent], 
									  [convertColor blueComponent], 
									  [convertColor alphaComponent]});
		}
		storage.color = color;
		CGColorRelease(color);
		[self setAssociatedObject:storage forKey:cgColorStorageKey policy:OBJC_ASSOCIATION_RETAIN];
	}
	return storage.color;
}

+ (NSColor *)colorWithRGB:(NSUInteger)pRGB {
	return [self colorWithRGB:pRGB alpha:1.0];
}
+ (NSColor *)colorWithRGB:(NSUInteger)pRGB alpha:(CGFloat)pAlpha {
	return [NSColor colorWithCalibratedRed:(((pRGB >> 16) & 0xFF) / 255.0) 
									 green:(((pRGB >> 8) & 0xFF) / 255.0)
									  blue:(((pRGB >> 0) & 0xFF) / 255.0)
									 alpha:pAlpha];
}
+ (NSColor *)colorWithRGBA:(NSUInteger)pRGBA {
	return [NSColor colorWithCalibratedRed:(((pRGBA >> 24) & 0xFF) / 255.0) 
									 green:(((pRGBA >> 16) & 0xFF) / 255.0)
									  blue:(((pRGBA >> 8) & 0xFF) / 255.0)
									 alpha:(((pRGBA >> 0) & 0xFF) / 255.0)];
}

- (NSColor *)colorByAdjustingHue:(CGFloat)pHue saturation:(CGFloat)pSaturation brightness:(CGFloat)pBrightness alpha:(CGFloat)pAlpha {
	CGFloat h,s,b,a;
	NSColor *c = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[c getHue:&h saturation:&s brightness:&b alpha:&a];
	return [NSColor colorWithCalibratedHue:h + pHue saturation:s + pSaturation brightness:b + pBrightness alpha:a + pAlpha];
}

- (void)compositeInRect:(NSRect)pRect {
	[[NSGraphicsContext currentContext] saveGraphicsState];
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetFillColorWithColor(ctx, self.CGColor);
	CGContextFillRect(ctx, pRect);
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}
- (void)compositeInRect:(NSRect)pRect operation:(NSCompositingOperation)pOperation {
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSGraphicsContext currentContext] setCompositingOperation:pOperation];
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetFillColorWithColor(ctx, self.CGColor);
	CGContextFillRect(ctx, pRect);
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
