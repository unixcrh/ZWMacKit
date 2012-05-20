#import "ZWPreferencesToolbarItem.h"


@implementation ZWPreferencesToolbarItem

#pragma mark - Properties

@synthesize preferencesView;
@synthesize initialFirstResponder;
@synthesize allowResizing;
@synthesize minSize;
@synthesize maxSize;

#pragma mark - Nib

- (void)awakeFromNib {
	[super awakeFromNib];
	self.minSize = NSZeroSize;
	self.maxSize = NSZeroSize;
}

@end
