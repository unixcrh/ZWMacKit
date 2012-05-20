#import "ZWFirstResponderButton.h"


@implementation ZWFirstResponderButton

#pragma mark - NSResponder

- (void)mouseDown:(NSEvent *)pEvent {
	[[self window] makeFirstResponder:self];
	[super mouseDown:pEvent];
	[[self window] makeFirstResponder:nil];
}

@end
