#import "ZWAlertSheet.h"
#import "ZWSheetController.h"


@implementation ZWAlertSheet

#pragma mark - Initialization

+ (ZWAlertSheet *)alertSheetWithMessageText:(NSString *)pMessage 
				  defaultButton:(NSString *)pDefaultButton 
				alternateButton:(NSString *)pAlternateButton 
					otherButton:(NSString *)pOtherButton 
	  informativeTextWithFormat:(NSString *)pFormat {
	return (ZWAlertSheet *)[super alertWithMessageText:pMessage
										  defaultButton:pDefaultButton
										alternateButton:pAlternateButton
											otherButton:pOtherButton
							  informativeTextWithFormat:pFormat, nil];
}
+ (ZWAlertSheet *)alertSheetWithError:(NSError *)pError {
	return (ZWAlertSheet *)[super alertWithError:pError];
}

#pragma mark - Sheet

- (void)beginSheetModalForWindow:(NSWindow *)pWindow completionHandler:(void(^)(NSInteger result))pCompletionHandler {
	[ZWSheetController queueSheet:self modalForWindow:pWindow completionHandler:pCompletionHandler];
}

@end
