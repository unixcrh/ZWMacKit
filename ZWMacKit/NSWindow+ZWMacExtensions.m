#import "NSWindow+ZWMacExtensions.h"
#import "ZWSheetController.h"


@implementation NSWindow (ZWMacExtensions)

- (void)queueSheet:(NSWindow *)pSheet completionHandler:(void(^)(NSInteger pResult))pCompletionHandler {
	[ZWSheetController queueSheet:pSheet modalForWindow:self completionHandler:pCompletionHandler];
}
- (NSTimeInterval)resizeToSize:(NSSize)pSize withAnimation:(BOOL)pAnimation {
	NSRect windowFrame;
	windowFrame.origin.x = [self frame].origin.x;
	
	if([self isSheet]) {
		CGFloat oldWidth = [self frame].size.width;
		CGFloat newWidth = pSize.width;
		CGFloat difference = oldWidth - newWidth;
		windowFrame.origin.x += difference * 0.5;
	}
	
	windowFrame.origin.x = [self frame].origin.x - ((pSize.width - [self frame].size.width) * 0.5);
	windowFrame.origin.y = [self frame].origin.y + [self frame].size.height - pSize.height;
	windowFrame.size.width = pSize.width;
	windowFrame.size.height = pSize.height;
	
	
	if(!NSIsEmptyRect(windowFrame)) {
		NSTimeInterval resizeTime = [self animationResizeTime:windowFrame];
		[self setFrame:windowFrame display:YES animate:pAnimation];
		return resizeTime;
	}
	return 0.0;
}

- (NSPoint)convertPointToScreen:(NSPoint)pPoint {
	NSRect r = (NSRect){pPoint,NSZeroSize};
	r = [self convertRectToScreen:r];
	return r.origin;
}
- (NSPoint)convertPointFromScreen:(NSPoint)pPoint {
	NSRect r = (NSRect){pPoint,NSZeroSize};
	r = [self convertRectFromScreen:r];
	return r.origin;
}

@end
