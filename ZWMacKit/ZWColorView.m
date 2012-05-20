#import "ZWColorView.h"
#import "NSColor+ZWMacExtensions.h"

@implementation ZWColorView

#pragma mark - Properties

@synthesize backgroundColor;

- (void)setBackgroundColor:(NSColor *)pValue {
	if(pValue != backgroundColor) {
		backgroundColor = pValue;
		[self setNeedsDisplay:YES];
	}
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)pRect {
	[self.backgroundColor compositeInRect:pRect];
}

@end
