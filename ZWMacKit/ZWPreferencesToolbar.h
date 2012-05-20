#import "ZWPreferencesToolbarItem.h"

@interface ZWPreferencesToolbar : NSToolbar <NSWindowDelegate, NSToolbarDelegate> {
}

#pragma mark - Properties

@property (strong) IBOutlet NSWindow *window;

#pragma mark - Actions

- (void)setSelectedToolbarItem:(ZWPreferencesToolbarItem *)pItem;

@end