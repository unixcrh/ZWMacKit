@interface NSWindow (ZWMacExtensions)

- (void)queueSheet:(NSWindow *)pSheet completionHandler:(void(^)(NSInteger pResult))pCompletionHandler;
- (NSTimeInterval)resizeToSize:(NSSize)pSize withAnimation:(BOOL)pAnimation;

- (NSPoint)convertPointToScreen:(NSPoint)pPoint;
- (NSPoint)convertPointFromScreen:(NSPoint)pPoint;

@end
