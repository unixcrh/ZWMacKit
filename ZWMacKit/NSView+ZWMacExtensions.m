#import "NSView+ZWMacExtensions.h"
#import <ZWCoreKit/NSObject+ZWExtensions.h>
#import <ZWCoreKit/NSArray+ZWExtensions.h>
#import "NSColor+ZWMacExtensions.h"
#import <objc/runtime.h>

@implementation NSView (ZWMacExtensions)

+ (void)load {
	@autoreleasepool {
		[self exchangeInstanceMethodSelector:@selector(isFlipped) withSelector:@selector(zw_isFlipped)];
	}
}

+ (id)viewWithNibName:(NSString *)pNibNameOrNil nibBundle:(NSBundle *)pNibBundleOrNil {
	if(pNibNameOrNil == nil) {
		pNibNameOrNil = NSStringFromClass([self class]);
	}
	if(pNibBundleOrNil == nil) {
		pNibBundleOrNil = [NSBundle mainBundle];
	}
	NSNib *n = [[NSNib alloc] initWithNibNamed:pNibNameOrNil bundle:pNibBundleOrNil];
	NSArray *objects = nil;
	[n instantiateNibWithOwner:nil topLevelObjects:&objects];
	id object = [objects firstObjectWithKindOfClass:[self class]];
	NSAssert(object != nil, @"No object found with class: %@", NSStringFromClass([self class]));
	return object;
}
+ (id)viewWithFrame:(NSRect)pFrame {
	return [[self alloc] initWithFrame:pFrame];
}
+ (id)viewWithSize:(NSSize)pSize {
	return [self viewWithFrame:NSMakeRect(0, 0, pSize.width, pSize.height)];
}
+ (id)viewWithLayer:(CALayer *)pLayer {
	NSView *view = [self viewWithFrame:pLayer.frame];
	view.layer = pLayer;
	view.wantsLayer = YES;
	return view;
}

#pragma mark - Flipped

@dynamic flipped;
static char *flippedAssociatedObjectKey;
- (BOOL)zw_isFlipped {
	return [objc_getAssociatedObject(self, flippedAssociatedObjectKey) boolValue];
}
- (void)setFlipped:(BOOL)pValue {
	objc_setAssociatedObject(self, flippedAssociatedObjectKey, [NSNumber numberWithBool:pValue], OBJC_ASSOCIATION_RETAIN);
	[self setNeedsDisplay:YES];
}

#pragma mark - Frame

static inline
NSPoint ZWGetFrameOrigin(NSView *self, CGFloat anchorX, CGFloat anchorY) {
	if([[self superview] isFlipped]) {
		anchorY = 1.0 - anchorY;
	}
	NSRect f = self.frame;
	return NSMakePoint(f.origin.x + (f.size.width * anchorX), f.origin.y + (f.size.height * anchorY));
}
static inline
void ZWSetFrameOrigin(NSView *self, NSPoint value, CGFloat anchorX, CGFloat anchorY) {
	if([[self superview] isFlipped]) {
		anchorY = 1.0 - anchorY;
	}
	NSRect f = self.frame;
	f.origin.x = f.origin.x + (value.x - f.size.width * anchorX);
	f.origin.y = f.origin.y + (value.y - f.size.height * anchorY);
	self.frame = f;
}

@dynamic frame;
@dynamic frameOrigin;
@dynamic frameSize;

- (NSPoint)frameOrigin {
	return self.frame.origin;
}
- (NSSize)frameSize {
	return self.frame.size;
}

@dynamic frameWidth;
@dynamic frameHeight;

- (CGFloat)frameWidth {
	return self.frame.size.width;
}
- (void)setFrameWidth:(CGFloat)pValue {
	NSRect f = self.frame;
	f.size.width = pValue;
	self.frame = f;
}
- (CGFloat)frameHeight {
	return self.frame.size.height;
}
- (void)setFrameHeight:(CGFloat)pValue {
	NSRect f = self.frame;
	f.size.height = pValue;
	self.frame = f;
}

@dynamic frameMinX;
@dynamic frameCenterX;
@dynamic frameMaxX;

- (CGFloat)frameMinX {
	return self.frame.origin.x;
}
- (void)setFrameMinX:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.x = pValue;
	self.frame = f;
}
- (CGFloat)frameCenterX {
	NSRect f = self.frame;
	return f.origin.x + (f.size.width / 2.0);
}
- (void)setFrameCenterX:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.x = pValue - (f.size.width / 2.0);
	self.frame = f;
}
- (CGFloat)frameMaxX {
	NSRect f = self.frame;
	return f.origin.x + f.size.width;
}
- (void)setFrameMaxX:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.x = pValue - f.size.width;
	self.frame = f;
}

@dynamic frameMinY;
@dynamic frameCenterY;
@dynamic frameMaxY;

- (CGFloat)frameMinY {
	return self.frame.origin.y;
}
- (void)setFrameMinY:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.y = pValue;
	self.frame = f;
}
- (CGFloat)frameCenterY {
	NSRect f = self.frame;
	return f.origin.y + (f.size.height / 2.0);
}
- (void)setFrameCenterY:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.y = pValue - (f.size.height / 2.0);
	self.frame = f;
}
- (CGFloat)frameMaxY {
	NSRect f = self.frame;
	return f.origin.y + f.size.height;
}
- (void)setFrameMaxY:(CGFloat)pValue {
	NSRect f = self.frame;
	f.origin.y = pValue - f.size.height;
	self.frame = f;
}

@dynamic frameTopLeft;
@dynamic frameTopCenter;
@dynamic frameTopRight;

- (NSPoint)frameTopLeft {
	return ZWGetFrameOrigin(self, 0, 1);
}
- (void)setFrameTopLeft:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0, 1);
}
- (NSPoint)frameTopCenter {
	return ZWGetFrameOrigin(self, 0.5, 1);
}
- (void)setFrameTopCenter:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0.5, 1);
}
- (NSPoint)frameTopRight {
	return ZWGetFrameOrigin(self, 1, 1);
}
- (void)setFrameTopRight:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 1, 1);
}

@dynamic frameCenterLeft;
@dynamic frameCenter;
@dynamic frameCenterRight;

- (NSPoint)frameCenterLeft {
	return ZWGetFrameOrigin(self, 0, 0.5);
}
- (void)setFrameCenterLeft:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0.0, 0.5);
}
- (NSPoint)frameCenter {
	return ZWGetFrameOrigin(self, 0.5, 0.5);
}
- (void)setFrameCenter:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0.5, 0.5);
}
- (NSPoint)frameCenterRight {
	return ZWGetFrameOrigin(self, 1, 0.5);
}
- (void)setFrameCenterRight:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 1.0, 0.5);
}

@dynamic frameBottomLeft;
@dynamic frameBottomCenter;
@dynamic frameBottomRight;

- (NSPoint)frameBottomLeft {
	return ZWGetFrameOrigin(self, 0, 0);
}
- (void)setFrameBottomLeft:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0, 0);
}
- (NSPoint)frameBottomCenter {
	return ZWGetFrameOrigin(self, 0.5, 0);
}
- (void)setFrameBottomCenter:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 0.5, 0);
}
- (NSPoint)frameBottomRight {
	return ZWGetFrameOrigin(self, 1, 0);
}
- (void)setFrameBottomRight:(NSPoint)pValue {
	ZWSetFrameOrigin(self, pValue, 1, 0);
}

#pragma mark - Bounds

static inline
NSPoint ZWGetBoundsOrigin(NSView *self, CGFloat anchorX, CGFloat anchorY) {
	if([self isFlipped]) {
		anchorY = 1.0 - anchorY;
	}
	NSRect f = self.bounds;
	return NSMakePoint(f.origin.x + (f.size.width * anchorX), f.origin.y + (f.size.height * anchorY));
}
static inline
void ZWSetBoundsOrigin(NSView *self, NSPoint value, CGFloat anchorX, CGFloat anchorY) {
	if([self isFlipped]) {
		anchorY = 1.0 - anchorY;
	}
	NSRect f = self.bounds;
	f.origin.x = f.origin.x + (value.x - f.size.width * anchorX);
	f.origin.y = f.origin.y + (value.y - f.size.height * anchorY);
	self.bounds = f;
}

@dynamic bounds;
@dynamic boundsOrigin;
@dynamic boundsSize;

- (NSPoint)boundsOrigin {
	return self.bounds.origin;
}
- (NSSize)boundsSize {
	return self.bounds.size;
}

@dynamic boundsWidth;
@dynamic boundsHeight;

- (CGFloat)boundsWidth {
	return self.bounds.size.width;
}
- (void)setBoundsWidth:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.size.width = pValue;
	self.bounds = f;
}
- (CGFloat)boundsHeight {
	return self.bounds.size.height;
}
- (void)setBoundsHeight:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.size.height = pValue;
	self.bounds = f;
}

@dynamic boundsMinX;
@dynamic boundsCenterX;
@dynamic boundsMaxX;

- (CGFloat)boundsMinX {
	return self.bounds.origin.x;
}
- (void)setBoundsMinX:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.x = pValue;
	self.bounds = f;
}
- (CGFloat)boundsCenterX {
	NSRect f = self.bounds;
	return f.origin.x + (f.size.width / 2.0);
}
- (void)setBoundsCenterX:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.x = pValue - (f.size.width / 2.0);
	self.bounds = f;
}
- (CGFloat)boundsMaxX {
	NSRect f = self.bounds;
	return f.origin.x + f.size.width;
}
- (void)setBoundsMaxX:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.x = pValue - f.size.width;
	self.bounds = f;
}

@dynamic boundsMinY;
@dynamic boundsCenterY;
@dynamic boundsMaxY;

- (CGFloat)boundsMinY {
	return self.bounds.origin.y;
}
- (void)setBoundsMinY:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.y = pValue;
	self.bounds = f;
}
- (CGFloat)boundsCenterY {
	NSRect f = self.bounds;
	return f.origin.y + (f.size.height / 2.0);
}
- (void)setBoundsCenterY:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.y = pValue - (f.size.height / 2.0);
	self.bounds = f;
}
- (CGFloat)boundsMaxY {
	NSRect f = self.bounds;
	return f.origin.y + f.size.height;
}
- (void)setBoundsMaxY:(CGFloat)pValue {
	NSRect f = self.bounds;
	f.origin.y = pValue - f.size.height;
	self.bounds = f;
}

@dynamic boundsTopLeft;
@dynamic boundsTopCenter;
@dynamic boundsTopRight;

- (NSPoint)boundsTopLeft {
	return ZWGetBoundsOrigin(self, 0, 1);
}
- (void)setBoundsTopLeft:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0, 1);
}
- (NSPoint)boundsTopCenter {
	return ZWGetBoundsOrigin(self, 0.5, 1);
}
- (void)setBoundsTopCenter:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0.5, 1);
}
- (NSPoint)boundsTopRight {
	return ZWGetBoundsOrigin(self, 1, 1);
}
- (void)setBoundsTopRight:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 1, 1);
}

@dynamic boundsCenterLeft;
@dynamic boundsCenter;
@dynamic boundsCenterRight;

- (NSPoint)boundsCenterLeft {
	return ZWGetBoundsOrigin(self, 0, 0.5);
}
- (void)setBoundsCenterLeft:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0.0, 0.5);
}
- (NSPoint)boundsCenter {
	return ZWGetBoundsOrigin(self, 0.5, 0.5);
}
- (void)setBoundsCenter:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0.5, 0.5);
}
- (NSPoint)boundsCenterRight {
	return ZWGetBoundsOrigin(self, 1, 0.5);
}
- (void)setBoundsCenterRight:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 1.0, 0.5);
}

@dynamic boundsBottomLeft;
@dynamic boundsBottomCenter;
@dynamic boundsBottomRight;

- (NSPoint)boundsBottomLeft {
	return ZWGetBoundsOrigin(self, 0, 0);
}
- (void)setBoundsBottomLeft:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0, 0);
}
- (NSPoint)boundsBottomCenter {
	return ZWGetBoundsOrigin(self, 0.5, 0);
}
- (void)setBoundsBottomCenter:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 0.5, 0);
}
- (NSPoint)boundsBottomRight {
	return ZWGetBoundsOrigin(self, 1, 0);
}
- (void)setBoundsBottomRight:(NSPoint)pValue {
	ZWSetBoundsOrigin(self, pValue, 1, 0);
}

#pragma mark - Utility

- (void)moveFrameToWholePixelsByRounding {
	self.frame = NSMakeRect(round(self.frame.origin.x),
							round(self.frame.origin.y),
							self.frame.size.width,
							self.frame.size.height);
}
- (void)moveFrameToWholePixelsByFlooring {
	self.frame = NSMakeRect(floor(self.frame.origin.x),
							floor(self.frame.origin.y),
							self.frame.size.width,
							self.frame.size.height);
}
- (void)moveFrameToWholePixelsByCeiling {
	self.frame = NSMakeRect(ceil(self.frame.origin.x),
							ceil(self.frame.origin.y),
							self.frame.size.width,
							self.frame.size.height);
}

#pragma mark - Tree

- (void)insertSubview:(NSView *)pSubview atIndex:(NSUInteger)pIndex {
	if(pIndex == [[self subviews] count]) {
		[self addSubview:pSubview];
	} else if(pIndex == 0) {
		[self addSubview:pSubview positioned:NSWindowBelow relativeTo:[[self subviews] objectAtIndex:pIndex]];
	} else {
		[self addSubview:pSubview positioned:NSWindowAbove relativeTo:[[self subviews] objectAtIndex:pIndex]];
	}
}
- (void)insertSubview:(NSView *)pSubview atIndex:(NSUInteger)pIndex fitToBounds:(BOOL)pFitToBounds {
	if(pFitToBounds) {
		pSubview.frame = self.bounds;
	}
	[self insertSubview:pSubview atIndex:pIndex];
}

- (NSSplitView *)enclosingSplitView {
	NSView *superview = self;
	while((superview = superview.superview) != nil) {
		if([superview isKindOfClass:[NSSplitView class]]) {
			return (NSSplitView *)superview;
		}
	}
	return nil;
}

#pragma mark - Graphics

- (void)strokeEdges:(ZWEdges)pEdges size:(CGFloat)pSize color:(NSColor *)pColor {
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);
	CGContextSetFillColorWithColor(ctx, [pColor CGColor]);
	
	void (^strokeRect)(NSRect rect) = ^(NSRect rect) {
		CGContextFillRect(ctx, rect);
	};
	
	if(pEdges & ZWEdgeMinX) {
		strokeRect(NSMakeRect(self.boundsMinX, self.boundsMinY, pSize, self.boundsHeight));
	}
	if(pEdges & ZWEdgeMaxX) {
		strokeRect(NSMakeRect(self.boundsMaxX - pSize, self.boundsMinY, pSize, self.boundsHeight));
	}
	if(pEdges & ZWEdgeMinY) {
		strokeRect(NSMakeRect(self.boundsMinX, self.boundsMinY, self.boundsWidth, pSize));
	}
	if(pEdges & ZWEdgeMaxY) {
		strokeRect(NSMakeRect(self.boundsMinX, self.boundsMaxY - pSize, self.boundsWidth, pSize));
	}
	
	CGContextRestoreGState(ctx);
}

@end