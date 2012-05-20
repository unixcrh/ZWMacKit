#import "ZWPreferencesToolbar.h"
#import "NSWindow+ZWMacExtensions.h"
#import <ZWCoreKit/NSArray+ZWExtensions.h>


@implementation ZWPreferencesToolbar

#pragma mark - Properties

@synthesize window;

#pragma mark - Nib

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setDelegate:self];
	for(ZWPreferencesToolbarItem *item in [self items]) {
		[item setAction:@selector(setSelectedToolbarItem:)];
		[item setTarget:self];
	}
	[self setSelectedToolbarItem:(ZWPreferencesToolbarItem *)[[self items] firstObject]];
}

#pragma mark - Actions

- (void)setSelectedToolbarItem:(ZWPreferencesToolbarItem *)pItem {
	if([pItem isKindOfClass:[ZWPreferencesToolbarItem class]]) {
		// set responder
		if(![window makeFirstResponder:window]) {
			return;
		}
		
		ZWPreferencesToolbarItem *toolbarItem = (ZWPreferencesToolbarItem *)pItem;
		NSString *title = [toolbarItem label];
		NSView *view = toolbarItem.preferencesView;
		NSResponder *firstResponder = toolbarItem.initialFirstResponder;
		
		// set title
		[window setTitle:title];
		
		// remove old views
		for(NSView *subview in [[window contentView] subviews]) {
			[subview removeFromSuperview];
		}
		
		// resize
		[window resizeToSize:NSMakeSize([view frame].size.width, [view frame].size.height + NSWindowToolbarHeight) withAnimation:YES];
		[(NSView *)[window contentView] setFrame:[view frame]];
		[(NSView *)[window contentView] addSubview:view];
		
		// resize indicator
		[window setShowsResizeIndicator:toolbarItem.allowResizing];
		if(toolbarItem.minSize.width > 0.0 && toolbarItem.minSize.height > 0.0) {
			[window setMinSize:toolbarItem.minSize];
		}
		if(toolbarItem.maxSize.width > 0.0 && toolbarItem.maxSize.height > 0.0) {
			[window setMaxSize:toolbarItem.maxSize];
		}
		
		// set first responder
		[window makeFirstResponder:firstResponder];
		
		// select toolbar
		[super setSelectedItemIdentifier:[toolbarItem itemIdentifier]];
	}
}
- (void)setSelectedItemIdentifier:(NSString *)pItemIdentifier {
	for(ZWPreferencesToolbarItem *item in [self items]) {
		if([[item itemIdentifier] isEqualToString:pItemIdentifier]) {
			[self setSelectedToolbarItem:item];
			break;
		}
	}
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)pWindow {
	return [pWindow makeFirstResponder:pWindow];
}
- (NSSize)windowWillResize:(NSWindow *)pWindow toSize:(NSSize)pSize {
	if(![pWindow showsResizeIndicator]) {
		return [pWindow frame].size;
	}
	return pSize;
}

@end
