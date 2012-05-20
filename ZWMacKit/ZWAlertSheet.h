@interface ZWAlertSheet : NSAlert {
}

#pragma mark - Initialization

+ (ZWAlertSheet *)alertSheetWithMessageText:(NSString *)pMessage 
				  defaultButton:(NSString *)pDefaultButton 
				alternateButton:(NSString *)pAlternateButton 
					otherButton:(NSString *)pOtherButton 
	  informativeTextWithFormat:(NSString *)pFormat;
+ (ZWAlertSheet *)alertSheetWithError:(NSError *)pError;

#pragma mark - Sheet

- (void)beginSheetModalForWindow:(NSWindow *)pWindow completionHandler:(void (^)(NSInteger result))pCompletionHandler;

@end
