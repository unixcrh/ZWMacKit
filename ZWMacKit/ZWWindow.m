#import "ZWWindow.h"


@implementation ZWWindow

- (BOOL)makeFirstResponder:(NSResponder *)pResponder {	
	NSResponder *currentResponder = [self firstResponder];
	NSResponder *queuedResponder = pResponder;
	BOOL result = [super makeFirstResponder:pResponder];
	if(result) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NSDidResignFirstResponderNotification object:currentResponder];
		[[NSNotificationCenter defaultCenter] postNotificationName:NSDidBecomeFirstResponderNotification object:queuedResponder];
	}
	return result;
}

@end
