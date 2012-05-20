#import <AppKit/AppKit.h>

@class ZWJumpBarLabel;

@protocol ZWJumpBarLabelDelegate <NSObject>

@required

- (NSMenu *)menuToPresentWhenClickedForJumpBarLabel:(ZWJumpBarLabel *)pLabel;
- (void)jumpBarLabel:(ZWJumpBarLabel *)pLabel didReceivedClickOnItemAtIndexPath:(NSIndexPath *)pIndexPath;

@end

@interface ZWJumpBarLabel : NSControl

#pragma mark - Properties

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign, getter = isLastLabel) BOOL lastLabel;
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) NSUInteger indexInLevel;
@property (nonatomic, readonly) CGFloat minimumWidth;
#if OBJC_ARC_WEAK
@property (nonatomic, weak) id <ZWJumpBarLabelDelegate> delegate;
#else
@property (nonatomic, assign) id <ZWJumpBarLabelDelegate> delegate;
#endif

@end
