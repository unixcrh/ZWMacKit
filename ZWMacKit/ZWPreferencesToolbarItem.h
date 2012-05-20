@interface ZWPreferencesToolbarItem : NSToolbarItem {
}

#pragma mark - Properties

@property (strong) IBOutlet NSView *preferencesView;
@property (strong) IBOutlet NSResponder *initialFirstResponder;
@property (assign) BOOL allowResizing;
@property (assign) NSSize minSize;
@property (assign) NSSize maxSize;

@end
