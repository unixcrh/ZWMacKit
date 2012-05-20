#import <AppKit/AppKit.h>

@interface NSImage (ZWMacExtensions)

@property (readonly) CGImageRef CGImage;

- (void)drawStrechableInRect:(NSRect)pRect leftCapWidth:(CGFloat)pLeftCapWidth topCapWidth:(CGFloat)pTopCapWidth operation:(NSCompositingOperation)pOperation fraction:(CGFloat)pFraction;

@end
