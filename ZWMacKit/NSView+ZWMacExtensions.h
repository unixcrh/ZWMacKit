#import <Foundation/Foundation.h>
#import <ZWCoreKit/ZWGeometry.h>
#import <AppKit/AppKit.h>

@interface NSView (ZWMacExtensions)

+ (id)viewWithNibName:(NSString *)pNibNameOrNil nibBundle:(NSBundle *)pNibBundleOrNil;
+ (id)viewWithFrame:(NSRect)pFrame;
+ (id)viewWithSize:(NSSize)pSize;
+ (id)viewWithLayer:(CALayer *)pLayer;

#pragma mark - Flipped

@property (nonatomic, assign, getter = isFlipped) BOOL flipped;

#pragma mark - Frame

@property (nonatomic, assign) NSRect frame;
@property (nonatomic, assign) NSPoint frameOrigin;
@property (nonatomic, assign) NSSize frameSize;

@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;

@property (nonatomic, assign) CGFloat frameMinX;
@property (nonatomic, assign) CGFloat frameCenterX;
@property (nonatomic, assign) CGFloat frameMaxX;
@property (nonatomic, assign) CGFloat frameMinY;
@property (nonatomic, assign) CGFloat frameCenterY;
@property (nonatomic, assign) CGFloat frameMaxY;

@property (nonatomic, assign) NSPoint frameTopLeft;
@property (nonatomic, assign) NSPoint frameTopCenter;
@property (nonatomic, assign) NSPoint frameTopRight;

@property (nonatomic, assign) NSPoint frameCenterLeft;
@property (nonatomic, assign) NSPoint frameCenter;
@property (nonatomic, assign) NSPoint frameCenterRight;

@property (nonatomic, assign) NSPoint frameBottomLeft;
@property (nonatomic, assign) NSPoint frameBottomCenter;
@property (nonatomic, assign) NSPoint frameBottomRight;

#pragma mark - Bounds

@property (nonatomic, assign) NSRect bounds;
@property (nonatomic, assign) NSPoint boundsOrigin;
@property (nonatomic, assign) NSSize boundsSize;

@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

@property (nonatomic, assign) CGFloat boundsMinX;
@property (nonatomic, assign) CGFloat boundsCenterX;
@property (nonatomic, assign) CGFloat boundsMaxX;
@property (nonatomic, assign) CGFloat boundsMinY;
@property (nonatomic, assign) CGFloat boundsCenterY;
@property (nonatomic, assign) CGFloat boundsMaxY;

@property (nonatomic, assign) NSPoint boundsTopLeft;
@property (nonatomic, assign) NSPoint boundsTopCenter;
@property (nonatomic, assign) NSPoint boundsTopRight;

@property (nonatomic, assign) NSPoint boundsCenterLeft;
@property (nonatomic, assign) NSPoint boundsCenter;
@property (nonatomic, assign) NSPoint boundsCenterRight;

@property (nonatomic, assign) NSPoint boundsBottomLeft;
@property (nonatomic, assign) NSPoint boundsBottomCenter;
@property (nonatomic, assign) NSPoint boundsBottomRight;

#pragma mark - Utility

- (void)moveFrameToWholePixelsByRounding;
- (void)moveFrameToWholePixelsByFlooring;
- (void)moveFrameToWholePixelsByCeiling;

#pragma mark - Tree

- (void)insertSubview:(NSView *)pSubview atIndex:(NSUInteger)pIndex;
- (void)insertSubview:(NSView *)pSubview atIndex:(NSUInteger)pIndex fitToBounds:(BOOL)pFitToBounds;

- (NSSplitView *)enclosingSplitView;

#pragma mark - Graphics

- (void)strokeEdges:(ZWEdges)pEdges size:(CGFloat)pSize color:(NSColor *)pColor;

@end