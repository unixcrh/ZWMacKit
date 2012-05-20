#import "NSImage+ZWMacExtensions.h"
#import <ZWCoreKit/NSObject+ZWExtensions.h>
#import <ZWCoreKit/CGImage+ZWExtensions.h>
#import "ZWCGImageValue.h"

@implementation NSImage (ZWMacExtensions)

@dynamic CGImage;

- (CGImageRef)CGImage {
	@synchronized(self) {
		static void *CGImageKey;
		
		ZWCGImageValue *value = [self associatedObjectForKey:CGImageKey];
		if(value == nil) {
			NSData *tiffData = [self TIFFRepresentation];
			CGImageRef img = CGImageCreateWithData(tiffData);
			
			value = [[ZWCGImageValue alloc] init];
			value.CGImage = img;
			[self setAssociatedObject:value forKey:CGImageKey policy:OBJC_ASSOCIATION_RETAIN];
			
			CGImageRelease(img);
			
		}
		return value.CGImage;
	}
	return nil;
}



#define SWAP(x, y) { typeof(x) tmp = x; x = y; y = tmp; }

- (void)drawStrechableInRect:(NSRect)pRect leftCapWidth:(CGFloat)pLeftCapWidth topCapWidth:(CGFloat)pTopCapWidth operation:(NSCompositingOperation)pOperation fraction:(CGFloat)pFraction {
	CGFloat drawX = pRect.origin.x;
	CGFloat drawY = pRect.origin.y;
	CGFloat drawWidth = pRect.size.width;
	CGFloat drawHeight = pRect.size.height;
	CGFloat fromWidth = self.size.width;
	CGFloat fromHeight = self.size.height;
	BOOL hasLeftCap = (pLeftCapWidth > 0.0);
	BOOL hasTopCap = (pTopCapWidth > 0.0);
	
	NSUInteger count = 0;
	NSRect *drawRects;
	NSRect *fromRects;
	
	// 3 part left to right
	if(hasLeftCap && !hasTopCap) {
		
		
		drawRects = (NSRect []) {
			NSMakeRect(drawX, drawY, pLeftCapWidth, drawHeight),
			NSMakeRect(drawX + pLeftCapWidth, drawY, drawWidth - pLeftCapWidth * 2.0, drawHeight),
			NSMakeRect(drawX + drawWidth - pLeftCapWidth, drawY, pLeftCapWidth, drawHeight),
		};
		fromRects = (NSRect []) {
			NSMakeRect(0.0, 0.0, pLeftCapWidth, fromHeight),
			NSMakeRect(pLeftCapWidth, 0.0, fromWidth - pLeftCapWidth * 2.0, fromHeight),
			NSMakeRect(fromWidth - pLeftCapWidth, 0.0, pLeftCapWidth, fromHeight),
		};
		count = 3;
		
	}
	// 3 part top to bottom
	else if(hasTopCap && !hasLeftCap) {
		drawRects = (NSRect []) {
			NSMakeRect(drawX, drawY, drawWidth, pTopCapWidth),
			NSMakeRect(drawX, drawY + pTopCapWidth, drawWidth, drawHeight - pTopCapWidth * 2.0),
			NSMakeRect(drawX, drawY + drawWidth - pTopCapWidth, drawWidth, pTopCapWidth),
		};
		fromRects = (NSRect []) {
			NSMakeRect(0.0, 0.0, fromWidth, pTopCapWidth),
			NSMakeRect(0.0, pTopCapWidth, fromWidth, fromHeight - pTopCapWidth * 2.0),
			NSMakeRect(0.0, fromHeight - pTopCapWidth, fromWidth, pTopCapWidth),
		};
		count = 3;
		if([[NSGraphicsContext currentContext] isFlipped]) {
			SWAP(fromRects[0], fromRects[2]);
		}
	}
	// 9 part
	else if(hasLeftCap && hasTopCap) {
		drawRects = (NSRect []) {
			NSMakeRect(drawX, drawY, pLeftCapWidth, pTopCapWidth),
			NSMakeRect(drawX + pLeftCapWidth, drawY, drawWidth - pLeftCapWidth * 2.0, pTopCapWidth),
			NSMakeRect(drawX + drawWidth - pLeftCapWidth, drawY, pLeftCapWidth, pTopCapWidth),
			
			NSMakeRect(drawX, pTopCapWidth, drawY + pLeftCapWidth, drawHeight - pTopCapWidth * 2.0),
			NSMakeRect(drawX + pLeftCapWidth, drawY + pTopCapWidth, drawWidth - pLeftCapWidth * 2.0, drawHeight - pTopCapWidth * 2.0),
			NSMakeRect(drawX + drawWidth - pLeftCapWidth, drawY + pTopCapWidth, pLeftCapWidth, drawHeight - pTopCapWidth * 2.0),
			
			NSMakeRect(drawX, drawY + drawHeight - pTopCapWidth, pLeftCapWidth, pTopCapWidth),
			NSMakeRect(drawX + pLeftCapWidth, drawY + drawHeight - pTopCapWidth, drawWidth - pLeftCapWidth * 2.0, pTopCapWidth),
			NSMakeRect(drawX + drawWidth - pLeftCapWidth, drawY + drawHeight - pTopCapWidth, pLeftCapWidth, pTopCapWidth),
		};
		fromRects = (NSRect []) {
			NSMakeRect(0.0, 0.0, pLeftCapWidth, pTopCapWidth),
			NSMakeRect(pLeftCapWidth, 0.0, fromWidth - pLeftCapWidth * 2.0, pTopCapWidth),
			NSMakeRect(fromWidth - pLeftCapWidth, 0.0, pLeftCapWidth, pTopCapWidth),
			
			NSMakeRect(0.0, pTopCapWidth, pLeftCapWidth, fromHeight - pTopCapWidth * 2.0),
			NSMakeRect(pLeftCapWidth, pTopCapWidth, fromWidth - pLeftCapWidth * 2.0, fromHeight - pTopCapWidth * 2.0),
			NSMakeRect(fromWidth - pLeftCapWidth, pTopCapWidth, pLeftCapWidth, fromHeight - pTopCapWidth * 2.0),
			
			NSMakeRect(0.0, fromHeight - pTopCapWidth, pLeftCapWidth, pTopCapWidth),
			NSMakeRect(pLeftCapWidth, fromHeight - pTopCapWidth, fromWidth - pLeftCapWidth * 2.0, pTopCapWidth),
			NSMakeRect(fromWidth - pLeftCapWidth, fromHeight - pTopCapWidth, pLeftCapWidth, pTopCapWidth),
			
			
		};
		count = 9;
		
		if([[NSGraphicsContext currentContext] isFlipped]) {
			SWAP(fromRects[0], fromRects[6]);
			SWAP(fromRects[1], fromRects[7]);
			SWAP(fromRects[2], fromRects[8]);
		}
	}
	// regular
	else {
		[self drawInRect:pRect
				fromRect:NSZeroRect
			   operation:pOperation
				fraction:pFraction
		  respectFlipped:YES
				   hints:nil];
		return;
	}
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);
	CGContextSetAllowsAntialiasing(ctx, NO);
	
	for(NSInteger i = 0; i < count; ++i) {
		[self drawInRect:drawRects[i]
				fromRect:fromRects[i]
			   operation:pOperation
				fraction:pFraction
		  respectFlipped:YES
				   hints:nil];
	}
	
	CGContextSetAllowsAntialiasing(ctx, YES);
	CGContextRestoreGState(ctx);
}

@end
