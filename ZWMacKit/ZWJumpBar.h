#import <AppKit/AppKit.h>

@class ZWJumpBar;

@protocol ZWJumpBarDelegate <NSObject>

@optional
- (void)jumpBar:(ZWJumpBar *)pJumpBar didSelectItemAtIndexPath:(NSIndexPath *)pIndexPath;

@end

@interface ZWJumpBar : NSControl

#pragma mark - Properties

#if OBJC_ARC_WEAK
@property (nonatomic, weak) IBOutlet id <ZWJumpBarDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id <ZWJumpBarDelegate> delegate;
#endif
@property (nonatomic, strong) IBOutlet NSMenu *menu;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong, readonly) NSMenuItem *selectedMenuItem;
@property (nonatomic, assign) BOOL changeFontAndImageInMenu;

#pragma mark - Initialization

+ (id)jumpBarWithFrame:(NSRect)pFrame menu:(NSMenu *)pMenu;
- (id)initWithFrame:(NSRect)pFrame menu:(NSMenu *)pMenu;

@end
