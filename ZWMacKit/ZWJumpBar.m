#import "ZWJumpBar.h"
#import "ZWJumpBarLabel.h"
#import "NSMenu+ZWMacExtensions.h"
#import <ZWCoreKit/NSNotificationCenter+ZWExtensions.h>
#import <ZWCoreKit/NSIndexPath+ZWExtensions.h>

const CGFloat ZWJumpBarNormalHeight = 23.0;
const CGFloat ZWJumpBarNormalImageSize = 16.0;

@interface ZWJumpBar () <ZWJumpBarLabelDelegate>

@property (nonatomic, assign, getter = isUnderIdealWidth) BOOL underIdealWidth;

- (void)performLayout;
- (void)lookForOverflowWidth;
- (void)placeLabelAndSetValue;
- (void)removeUnusedLabels;

- (void)performLayoutIfNeededWithNewSize:(CGSize)size;
- (ZWJumpBarLabel *)labelAtLevel:(NSUInteger)level;
- (void)changeFontAndImageInMenu:(NSMenu *)subMenu;

@end

@implementation ZWJumpBar

@synthesize underIdealWidth;

@synthesize delegate;
@synthesize menu;

@synthesize selectedIndexPath;
@synthesize changeFontAndImageInMenu;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(self) {
		NSRect frame = self.frame;
		frame.size.height = ZWJumpBarNormalHeight;
		self.frame = frame;
		
		self.changeFontAndImageInMenu = YES;
		self.underIdealWidth = NO;
	}
	
	return self;
}

+ (id)jumpBarWithFrame:(NSRect)pFrame menu:(NSMenu *)pMenu {
	return [[self alloc] initWithFrame:pFrame menu:pMenu];
}
- (id)initWithFrame:(NSRect)frameRect {
	return [self initWithFrame:frameRect menu:nil];
}

- (id)initWithFrame:(NSRect)frameRect menu:(NSMenu *)aMenu {
	frameRect.size.height = ZWJumpBarNormalHeight;
	
	self = [super initWithFrame:frameRect];
	if(self) {
		self.menu = aMenu;
		self.changeFontAndImageInMenu = YES;
	}
	
	return self;
}

#pragma mark - Subclass

- (NSMenu *)menuForEvent:(NSEvent *)event {
	return nil;
}

#pragma mark - Setters

- (void)setMenu:(NSMenu *)newMenu {
	if(newMenu != menu) {
		menu = newMenu;
		if(menu != nil && self.selectedIndexPath == nil) self.selectedIndexPath = [NSIndexPath indexPathWithIndex:0];
		if(self.changeFontAndImageInMenu) [self changeFontAndImageInMenu:self.menu];
		
		[self performLayout];
		
		if([self.delegate respondsToSelector:@selector(jumpBar:didSelectItemAtIndexPath:)]) {
			[self.delegate jumpBar:self didSelectItemAtIndexPath:self.selectedIndexPath];
		}
	}
}

- (void)setSelectedIndexPath:(NSIndexPath *)newSelectedIndexPath {
	if(newSelectedIndexPath != selectedIndexPath) {
		selectedIndexPath = newSelectedIndexPath;
		
		[self performLayout];
	}
	
	if([self.delegate respondsToSelector:@selector(jumpBar:didSelectItemAtIndexPath:)]) {
		[self.delegate jumpBar:self didSelectItemAtIndexPath:self.selectedIndexPath];
	}
}

- (void)setEnabled:(BOOL)flag {
	[super setEnabled:flag];
	
	for(NSControl *view in [self subviews]) {
		[view setEnabled:flag];
	}
	
	[self setNeedsDisplay];
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self performLayoutIfNeededWithNewSize:frameRect.size];
}

- (void)setBounds:(NSRect)aRect {
	[super setBounds:aRect];
	[self performLayoutIfNeededWithNewSize:aRect.size];
}

#pragma mark - Layout

- (void)performLayoutIfNeededWithNewSize:(CGSize)size {
	if(self.underIdealWidth) [self performLayout];
	else {
		ZWJumpBarLabel *lastLabel = [self viewWithTag:self.selectedIndexPath.length];
		CGFloat endFloat = lastLabel.frame.size.width + lastLabel.frame.origin.x;
		
		if(size.width < endFloat) {
			[self performLayout];
		}
	}
}

- (void)performLayout {
	self.underIdealWidth = NO;
	
	[self placeLabelAndSetValue];
	[self lookForOverflowWidth];
	[self removeUnusedLabels];
}

- (void)placeLabelAndSetValue {
	NSIndexPath *atThisPointIndexPath = [[NSIndexPath alloc] init];
	CGFloat baseX = 0;
	
	for(NSUInteger position = 0; position < self.selectedIndexPath.length; position++) {
		NSUInteger selectedIndex = [self.selectedIndexPath indexAtPosition:position];
		atThisPointIndexPath = [atThisPointIndexPath indexPathByAddingIndex:selectedIndex];
		
		ZWJumpBarLabel *label = [self labelAtLevel:atThisPointIndexPath.length];
		label.lastLabel = (position == (self.selectedIndexPath.length - 1));
		
		NSMenuItem *item = [self.menu itemAtIndexPath:atThisPointIndexPath];
		label.text = item.title;
		label.image = item.image;
		label.indexInLevel = selectedIndex;
		
		[label sizeToFit];
		NSRect frame = [label frame];
		frame.origin.x = baseX;
		baseX += frame.size.width;
		label.frame = frame;
	}
}

- (void)lookForOverflowWidth {
	ZWJumpBarLabel *lastLabel = [self viewWithTag:self.selectedIndexPath.length];
	CGFloat endFloat = lastLabel.frame.size.width + lastLabel.frame.origin.x;
	
	if(self.frame.size.width < endFloat) {
		self.underIdealWidth = YES;
		
		// Set new width for the overflow
		CGFloat overMargin = endFloat - self.frame.size.width;
		for(NSUInteger position = 0; position < self.selectedIndexPath.length; position++) {
			ZWJumpBarLabel *label = [self labelAtLevel:position + 1];
			if((overMargin + label.minimumWidth - label.frame.size.width) < 0) {
				CGRect frame = label.frame;
				frame.size.width -= overMargin;
				label.frame = frame;
				break;
			} else {
				overMargin -= (label.frame.size.width - label.minimumWidth);
				
				CGRect frame = label.frame;
				frame.size.width = label.minimumWidth;
				label.frame = frame;
			}
		}
		
		// Replace the labels at the right place
		CGFloat baseX = 0;
		for(NSUInteger position = 0; position < self.selectedIndexPath.length; position++) {
			ZWJumpBarLabel *label = [self labelAtLevel:position + 1];
			
			NSRect frame = [label frame];
			frame.origin.x = baseX;
			baseX += frame.size.width;
			label.frame = frame;
		}
	}
}

- (void)removeUnusedLabels {
	// Remove old views
	NSView *viewToRemove = nil;
	NSUInteger position = self.selectedIndexPath.length + 1;
	
	while((viewToRemove = [self viewWithTag:position])) {
		[viewToRemove removeFromSuperview];
		position++;
	}
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
	// Draw main gradient
	dirtyRect.size.height = self.bounds.size.height;
	dirtyRect.origin.y = 0;
	
	NSGradient *mainGradient = nil;
	if(!self.isEnabled || !self.window.isMainWindow) {
		mainGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.96 alpha:1.0]
													 endingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0]];
	} else mainGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0]
														endingColor:[NSColor colorWithCalibratedWhite:0.73 alpha:1.0]];
	[mainGradient drawInRect:dirtyRect angle:-90];
	
	// Draw both stroke lines
	if(!self.isEnabled || !self.window.isMainWindow) [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
	else [[NSColor colorWithCalibratedWhite:0.33 alpha:1.0] set];
	
	dirtyRect.size.height = 1;
	NSRectFill(dirtyRect);
	
	dirtyRect.origin.y = self.frame.size.height - 1;
	NSRectFill(dirtyRect);
}

- (void)viewWillMoveToWindow:(NSWindow *)pNewWindow {
	[super viewWillMoveToWindow:pNewWindow];
	if(self.window != nil) {
		[NSDefaultNotificationCenter removeObserver:self name:NSWindowDidBecomeMainNotification object:self.window];
		[NSDefaultNotificationCenter removeObserver:self name:NSWindowDidResignMainNotification object:self.window];
	}
	if(pNewWindow != nil) {
		[NSDefaultNotificationCenter addObserverForName:NSWindowDidBecomeMainNotification object:self.window usingBlock:^(NSNotification *notification) {
			[self setNeedsDisplay:YES];
		}];
		[NSDefaultNotificationCenter addObserverForName:NSWindowDidResignMainNotification object:self.window usingBlock:^(NSNotification *notification) {
			[self setNeedsDisplay:YES];
		}];
	}
}

#pragma mark - Helper

- (ZWJumpBarLabel *)labelAtLevel:(NSUInteger)level {
	ZWJumpBarLabel *label = [self viewWithTag:level];
	
	if(label == nil) {
		label = [[ZWJumpBarLabel alloc] init];
		label.level = level;
		label.frame = NSMakeRect(0, 0, 0, self.frame.size.height);
		label.delegate = self;
		label.enabled = self.isEnabled;
		
		[self addSubview:label];
	}
	
	return label;
}

- (void)changeFontAndImageInMenu:(NSMenu *)subMenu {
	for(NSMenuItem *item in [subMenu itemArray]) {
		NSMutableAttributedString *attributedString = [[item attributedTitle] mutableCopy];
		if(attributedString == nil) attributedString = [[NSMutableAttributedString alloc] initWithString:item.title];
		
		NSDictionary *attribues = (attributedString.length != 0) ? [attributedString attributesAtIndex:0 effectiveRange:nil] : nil;
		NSFont *font = [attribues objectForKey:NSFontAttributeName];
		NSString *fontDescrition = [font fontName];
		if(fontDescrition != nil) {
			if([fontDescrition rangeOfString:@"Bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				font = [NSFont boldSystemFontOfSize:12.0];
			} else font = [NSFont systemFontOfSize:12.0];
		} else font = [NSFont systemFontOfSize:12.0];
		
		[attributedString addAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]
								  range:NSMakeRange(0, attributedString.length)];
		[item setAttributedTitle:attributedString];
		
		[item.image setSize:NSMakeSize(ZWJumpBarNormalImageSize, ZWJumpBarNormalImageSize)];
		
		if([item hasSubmenu]) [self changeFontAndImageInMenu:[item submenu]];
	}
}

- (NSMenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self.menu itemAtIndexPath:indexPath];
}

- (NSMenuItem *)selectedMenuItem {
	return [self menuItemAtIndexPath:self.selectedIndexPath];
}

#pragma mark - ZWJumpBarLabelDelegate

- (NSMenu *)menuToPresentWhenClickedForJumpBarLabel:(ZWJumpBarLabel *)label {
	NSIndexPath *subIndexPath = [self.selectedIndexPath subIndexPathToPosition:label.level];
	return [[self.menu itemAtIndexPath:subIndexPath] menu];
}

- (void)jumpBarLabel:(ZWJumpBarLabel *)label didReceivedClickOnItemAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *subIndexPath = [self.selectedIndexPath subIndexPathToPosition:label.level - 1];
	self.selectedIndexPath = [subIndexPath indexPathByAddingIndexPath:indexPath];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
}

@end
