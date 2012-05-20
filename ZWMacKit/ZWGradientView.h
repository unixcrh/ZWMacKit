#import <Cocoa/Cocoa.h>

@interface ZWGradientView : NSView

#pragma mark - Properties

@property (strong) NSGradient *gradient;
@property (strong) NSGradient *inactiveGradient;
@property (assign) CGFloat angle;

@end
