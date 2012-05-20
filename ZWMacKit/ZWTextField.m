#import "ZWTextField.h"


@interface ZWTextField() {
	NSColor *normalTextColor;
	NSColor *disabledTextColor;
}
@end
@implementation ZWTextField

#pragma mark - Properties

@dynamic normalTextColor;
@dynamic disabledTextColor;

- (void)setNormalTextColor:(NSColor *)pValue {
	@synchronized(self) {
		normalTextColor = pValue;
	}
}
- (NSColor *)normalTextColor {
	@synchronized(self) {
		if(normalTextColor == nil) {
			self.normalTextColor = [NSColor textColor];
		}
		return normalTextColor;
	}
}
- (void)setDisabledTextColor:(NSColor *)pValue {
	@synchronized(self) {
		disabledTextColor = pValue;
	}
}
- (NSColor *)disabledTextColor {
	@synchronized(self) {
		if(disabledTextColor == nil) {
			self.disabledTextColor = [NSColor disabledControlTextColor];
		}
		return disabledTextColor;
	}
}
- (void)setEnabled:(BOOL)pValue {
	[super setEnabled:pValue];
	if(pValue) {
		[self setTextColor:self.normalTextColor];
	} else {
		[self setTextColor:self.disabledTextColor];
	}
}

@end
