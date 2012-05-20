#import <Cocoa/Cocoa.h>

@interface ZWBlockAnimation : NSAnimation {
    
}

#pragma mark - Initialization

+ (id)animationWithBlock:(void (^)(NSAnimationProgress progress, BOOL *stop))pBlock;
- (id)initWithBlock:(void (^)(NSAnimationProgress progress, BOOL *stop))pBlock;

@end
