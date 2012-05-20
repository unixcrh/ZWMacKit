#import <Foundation/Foundation.h>


@interface ZWSheetController : NSObject {
}

#pragma mark - Actions

+ (void)queueSheet:(id)pSheet modalForWindow:(NSWindow *)pWindow completionHandler:(void (^)(NSInteger result))pCompletionHandler;

@end
