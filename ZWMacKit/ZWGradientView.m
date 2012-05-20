#import "ZWGradientView.h"
#import <ZWCoreKit/NSNotificationCenter+ZWExtensions.h>

@interface ZWGradientView() {
	
}

@end
@implementation ZWGradientView

#pragma mark - Properties

@synthesize gradient;
@synthesize inactiveGradient;
@synthesize angle;

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
- (void)drawRect:(NSRect)pRect {
	if(self.window.isMainWindow || self.inactiveGradient == nil) {
		[self.gradient drawInRect:pRect angle:angle];
	} else {
		[self.inactiveGradient drawInRect:pRect angle:angle];
	}
}

@end
