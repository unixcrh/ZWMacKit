#import "ZWSheet.h"
#import "ZWSheetController.h"

@implementation ZWSheet

#pragma mark - Initialization

- (id)initWithWindowNibName:(NSString *)pWindowNibName owner:(id)pOwner {
	if((self = [super initWithWindowNibName:pWindowNibName owner:pOwner])) {
		[self window];
	}
	return self;
}
- (void)beginSheetModalForWindow:(NSWindow*)pWindow completionHandler:(void(^)(NSInteger result))pCompletionHandler {
	[ZWSheetController queueSheet:self modalForWindow:pWindow completionHandler:pCompletionHandler];
}
- (void)endSheetWithReturnCode:(NSInteger)pReturnCode {
	[NSApp endSheet:[self window] returnCode:pReturnCode];
}
- (IBAction)closeSheet:(id)pSender {
	[NSApp endSheet:[self window]];
}

@end
