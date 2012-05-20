@interface ZWSheet : NSWindowController {
}

#pragma mark - Initialization

- (void)beginSheetModalForWindow:(NSWindow *)pWindow completionHandler:(void(^)(NSInteger result))pCompletionHandler;
- (void)endSheetWithReturnCode:(NSInteger)pReturnCode;
- (IBAction)closeSheet:(id)pSender;

@end
