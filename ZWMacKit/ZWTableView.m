#import "ZWTableView.h"
#import "NSEvent+ZWMacExtensions.h"
#import "NSColor+ZWMacExtensions.h"
#import "NSGradient+ZWMacExtensions.h"
#import "NSRect+ZWMacExtensions.h"
#import <ZWCoreKit/NSNotificationCenter+ZWExtensions.h>


@interface ZWTableView() {
}

@property (assign) NSMapTable *gradientsLineColors;

- (NSColor *)lineColorForGradient:(NSGradient *)pGradient location:(CGFloat)pLocation;
- (void)updateColors;
- (void)initialize;
- (void)windowDidBecomeKeyNotification:(NSNotification *)pNotification;
- (void)windowDidResignKeyNotification:(NSNotification *)pNotification;
- (void)controlTintDidChangeNotification:(NSNotification *)pNotification;

@end
@implementation ZWTableView

#pragma mark - Properties

@synthesize gradientsLineColors;
@synthesize highlightGradient;
@synthesize groupGradient;

#pragma mark - Property Actions

- (NSColor *)lineColorForGradient:(NSGradient *)pGradient location:(CGFloat)pLocation {
	NSMutableDictionary *d = [self.gradientsLineColors objectForKey:pGradient];
	if(d == nil) {
		return [NSColor colorWithRGB:0xFF0000 alpha:0.0];
	}
	NSColor *color = [d objectForKey:[NSNumber numberWithDouble:pLocation]];
	if(color == nil) {
		NSColor *gradientLocationColor = [pGradient interpolatedColorAtLocation:pLocation];
		color = [gradientLocationColor colorByAdjustingHue:0.0 saturation:0.05 brightness:-0.05 alpha:0.0];
		color = [[NSColor colorWithRGB:(0x000000 + (0x333333 * pLocation)) alpha:1.0] blendedColorWithFraction:0.9
																									   ofColor:color];
		[d setObject:color forKey:[NSNumber numberWithDouble:pLocation]];
	}
	return color;
}
- (void)updateColors {	
	BOOL isMainWindow = [[self window] isMainWindow];
	BOOL isFirstResponder = ([[self window] firstResponder] == self);
	BOOL isGraphite = ([NSColor currentControlTint] == NSGraphiteControlTint);
	
	static NSArray *aquaColorsSet = nil;
	static NSArray *graphiteColorsSet = nil;
	static dispatch_once_t colorSetsOnce;
	dispatch_once(&colorSetsOnce, ^{
		aquaColorsSet = [NSArray arrayWithObjects:
						 [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSColor colorWithCalibratedRed:0.906 green:0.914 blue:0.945 alpha:1.0], @"groupTop",
						  [NSColor colorWithCalibratedRed:0.843 green:0.875 blue:0.910 alpha:1.0], @"groupBottom",
						  [NSColor colorWithCalibratedRed:0.612 green:0.706 blue:0.804 alpha:1.0], @"highlightTop",
						  [NSColor colorWithCalibratedRed:0.447 green:0.541 blue:0.698 alpha:1.0], @"highlightBottom",
						  [NSColor colorWithCalibratedRed:0.894 green:0.914 blue:0.933 alpha:1.0], @"backgroundColor",
						  nil],
						 [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSColor colorWithCalibratedRed:0.906 green:0.914 blue:0.945 alpha:1.0], @"groupTop",
						  [NSColor colorWithCalibratedRed:0.843 green:0.875 blue:0.910 alpha:1.0], @"groupBottom",
						  [NSColor colorWithCalibratedRed:0.694 green:0.745 blue:0.843 alpha:1.0], @"highlightTop",
						  [NSColor colorWithCalibratedRed:0.514 green:0.588 blue:0.718 alpha:1.0], @"highlightBottom",
						  [NSColor colorWithCalibratedRed:0.894 green:0.914 blue:0.933 alpha:1.0], @"backgroundColor",
						  nil],
						 [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSColor colorWithCalibratedRed:0.929 green:0.929 blue:0.929 alpha:1.0], @"groupTop",
						  [NSColor colorWithCalibratedRed:0.894 green:0.894 blue:0.894 alpha:1.0], @"groupBottom",
						  [NSColor colorWithCalibratedRed:0.761 green:0.761 blue:0.761 alpha:1.0], @"highlightTop",
						  [NSColor colorWithCalibratedRed:0.612 green:0.612 blue:0.612 alpha:1.0], @"highlightBottom",
						  [NSColor colorWithCalibratedRed:0.941 green:0.941 blue:0.941 alpha:1.0], @"backgroundColor",
						  nil],
						 nil];
		graphiteColorsSet = [NSArray arrayWithObjects:
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSColor colorWithCalibratedRed:0.906 green:0.914 blue:0.945 alpha:1.0], @"groupTop",
							  [NSColor colorWithCalibratedRed:0.847 green:0.875 blue:0.910 alpha:1.0], @"groupBottom",
							  [NSColor colorWithCalibratedRed:0.573 green:0.639 blue:0.702 alpha:1.0], @"highlightTop",
							  [NSColor colorWithCalibratedRed:0.310 green:0.408 blue:0.490 alpha:1.0], @"highlightBottom",
							  [NSColor colorWithCalibratedRed:0.894 green:0.914 blue:0.933 alpha:1.0], @"backgroundColor",
							  nil],
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSColor colorWithCalibratedRed:0.906 green:0.918 blue:0.945 alpha:1.0], @"groupTop",
							  [NSColor colorWithCalibratedRed:0.843 green:0.875 blue:0.910 alpha:1.0], @"groupBottom",
							  [NSColor colorWithCalibratedRed:0.722 green:0.769 blue:0.808 alpha:1.0], @"highlightTop",
							  [NSColor colorWithCalibratedRed:0.569 green:0.624 blue:0.686 alpha:1.0], @"highlightBottom",
							  [NSColor colorWithCalibratedRed:0.894 green:0.914 blue:0.933 alpha:1.0], @"backgroundColor",
							  nil],
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSColor colorWithCalibratedRed:0.929 green:0.929 blue:0.929 alpha:1.0], @"groupTop",
							  [NSColor colorWithCalibratedRed:0.898 green:0.898 blue:0.898 alpha:1.0], @"groupBottom",
							  [NSColor colorWithCalibratedRed:0.761 green:0.761 blue:0.761 alpha:1.0], @"highlightTop",
							  [NSColor colorWithCalibratedRed:0.612 green:0.612 blue:0.612 alpha:1.0], @"highlightBottom",
							  [NSColor colorWithCalibratedRed:0.941 green:0.941 blue:0.941 alpha:1.0], @"backgroundColor",
							  nil],
							 nil];
	});
	
	NSArray *useColorsSet = ((isGraphite) ? graphiteColorsSet : aquaColorsSet);
	NSDictionary *useColors = nil;
	if(isMainWindow) {
		if(isFirstResponder) {
			useColors = [useColorsSet objectAtIndex:0];
		} else {
			useColors = [useColorsSet objectAtIndex:1];
		}
	} else {
		useColors = [useColorsSet objectAtIndex:2];
	}
	
	highlightGradient = [NSGradient gradientWithStartingColor:[useColors objectForKey:@"highlightTop"]
												  endingColor:[useColors objectForKey:@"highlightBottom"]];
	groupGradient = [NSGradient gradientWithStartingColor:[useColors objectForKey:@"groupTop"]
											  endingColor:[useColors objectForKey:@"groupBottom"]];
	[self setBackgroundColor:[useColors objectForKey:@"backgroundColor"]];
	
	self.gradientsLineColors = [NSMapTable mapTableWithStrongToStrongObjects];
	NSArray *gradients = [NSArray arrayWithObjects:
						  self.highlightGradient,
						  self.groupGradient,
						  nil];
	for(NSGradient *gradient in gradients) {
		NSMutableDictionary *d = [NSMutableDictionary dictionary];
		[self.gradientsLineColors setObject:d forKey:gradient];
	}
	[self setNeedsDisplay];
}
- (BOOL)becomeFirstResponder {
	[self performSelector:@selector(updateColors) withObject:nil afterDelay:0.0];
	return [super becomeFirstResponder];
}
- (BOOL)resignFirstResponder {
	[self performSelector:@selector(updateColors) withObject:nil afterDelay:0.0];
	return [super resignFirstResponder];
}

#pragma mark - Initializations

- (void)initialize {
	[NSDefaultNotificationCenter addObserver:self selector:@selector(controlTintDidChangeNotification:) name:NSControlTintDidChangeNotification object:NSApp];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self updateColors];
	});
}
- (id)initWithCoder:(NSCoder *)pCoder {
	if((self = [super initWithCoder:pCoder])) {
		[self initialize];
	}
	return self;
}
- (id)initWithFrame:(NSRect)pFrame {
	if((self = [super initWithFrame:pFrame])) {
		[self initialize];
	}
	return self;
}

#pragma mark - Notifications & Observers

- (void)windowDidBecomeKeyNotification:(NSNotification *)pNotification {
	[self updateColors];
	[self setNeedsDisplay];
}
- (void)windowDidResignKeyNotification:(NSNotification *)pNotification {
	[self updateColors];
	[self setNeedsDisplay];
}
- (void)controlTintDidChangeNotification:(NSNotification *)pNotification {
	[self updateColors];
}

#pragma mark - NSView

- (void)viewWillMoveToWindow:(NSWindow *)pNewWindow {
	[super viewWillMoveToWindow:pNewWindow];
	if(self.window != nil) {
		[NSDefaultNotificationCenter removeObserver:self name:NSWindowDidBecomeMainNotification object:self.window];
		[NSDefaultNotificationCenter removeObserver:self name:NSWindowDidResignMainNotification object:self.window];
	}
	if(pNewWindow != nil) {
		[NSDefaultNotificationCenter addObserverForName:NSWindowDidBecomeMainNotification object:self.window usingBlock:^(NSNotification *notification) {
			[self setNeedsDisplay:YES];
		}];
		[NSDefaultNotificationCenter addObserverForName:NSWindowDidResignMainNotification object:self.window usingBlock:^(NSNotification *notification) {
			[self setNeedsDisplay:YES];
		}];
	}
}
- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	[self setNeedsDisplay];
}

- (void)mouseDown:(NSEvent *)pEvent {
	if([self allowsEmptySelection]) {
		NSPoint location = [pEvent locationInView:self];
		NSUInteger row = [self rowAtPoint:location];
		if(row == NSNotFound || row >= [self numberOfRows]) {
			[self deselectAll:nil];
		}
	}
	[super mouseDown:pEvent];
}
- (void)rightMouseDown:(NSEvent *)pEvent {
	NSPoint location = [pEvent locationInView:self];
	NSUInteger row = [self rowAtPoint:location];
	if(row != NSNotFound && row < [self numberOfRows] && ![self isRowSelected:row]) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	}
	[super rightMouseDown:pEvent];
}

#pragma mark - NSOutlineView

- (void)selectRowIndexes:(NSIndexSet *)pIndexes byExtendingSelection:(BOOL)pExtend {
	[super selectRowIndexes:pIndexes byExtendingSelection:pExtend];
	[self setNeedsDisplay:YES];
}
- (void)deselectRow:(NSInteger)pRow {
	[super deselectRow:pRow];
	[self setNeedsDisplay:YES];
}
- (void)editColumn:(NSInteger)pColumn row:(NSInteger)pRow withEvent:(NSEvent *)pEvent select:(BOOL)pSelect {
	[super editColumn:pColumn row:pRow withEvent:pEvent select:pSelect];
	[self setNeedsDisplay:YES];
}

#pragma mark - Drawing 

- (void)drawBackgroundInClipRect:(NSRect)pClipRect {
	[[self backgroundColor] drawSwatchInRect:pClipRect];
}
- (void)highlightSelectionInClipRect:(NSRect)pClipRect {
	NSIndexSet *selectedRows = [self selectedRowIndexes];
	
	void (^drawRange)(NSRange range) = ^(NSRange range){
		if(range.location == NSNotFound || range.length == 0) {
			return;
		}
		NSBezierPath *path = [NSBezierPath bezierPath];
		for(NSInteger i = range.location; i < range.location + range.length; ++i) {
			[path appendBezierPathWithRect:[self rectOfRow:i]];
			
		}
		NSRect r = [path bounds];
		r.origin.x -= 1.0;
		r.size.width += 2.0;
		[self drawHighlightGradientInRect:r strokeEdges:YES];
	};
	[selectedRows enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
		drawRange(range);
	}];
}
- (void)drawHighlightGradientInRect:(NSRect)pRect strokeEdges:(BOOL)pStrokeEdges {
	[self.highlightGradient drawInRect:pRect angle:90.0];
	if(pStrokeEdges) {
		if(pRect.origin.y != 0.0) {
			[[self lineColorForGradient:self.highlightGradient location:0.0] set];
			NSRectFillEdge(pRect, (([self isFlipped]) ? NSMinYEdge : NSMaxYEdge), 1.0);
		}
		[[self lineColorForGradient:self.highlightGradient location:1.0] set];
		NSRectFillEdge(pRect, (([self isFlipped]) ? NSMaxYEdge : NSMinYEdge), 1.0);
	}
}
- (void)drawGroupGradientInRect:(NSRect)pRect strokeEdges:(BOOL)pStrokeEdges {
	[self.groupGradient drawInRect:pRect angle:90.0];
	if(pStrokeEdges) {
		if(pRect.origin.y != 0.0) {
			[[self lineColorForGradient:self.groupGradient location:0.0] set];
			NSRectFillEdge(pRect, (([self isFlipped]) ? NSMinYEdge : NSMaxYEdge), 1.0);
		}
		[[self lineColorForGradient:self.groupGradient location:1.0] set];
		NSRectFillEdge(pRect, (([self isFlipped]) ? NSMaxYEdge : NSMinYEdge), 1.0);
	}
}

#pragma mark - Dealloc

- (void)dealloc {
	[NSDefaultNotificationCenter removeObserver:self];
}

@end

