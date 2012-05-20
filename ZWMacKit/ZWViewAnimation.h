#import <Cocoa/Cocoa.h>


@interface ZWViewAnimation : NSAnimation {
    
}

#pragma mark - Initialization

+ (id)animationWithViewAnimations:(NSArray *)pViewAnimations;
- (id)initWithViewAnimations:(NSArray *)pViewAnimations;

@end
