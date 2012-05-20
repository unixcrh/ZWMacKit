#import "ZWJumpBarLabel.h"
#import <ZWCoreKit/NSIndexPath+ZWExtensions.h>
#import <ZWCoreKit/CGImage+ZWExtensions.h>

const CGFloat ZWJumpBarLabelMargin = 5.0;
const NSInteger ZWJumpBarLabelAccessoryMenuLabelTag = -1;

@interface ZWJumpBarLabel ()

@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, retain) NSMenu *clickedMenu;

- (void)setPropretyOnMenu:(NSMenu *)menu;

@end

@implementation ZWJumpBarLabel

@synthesize image, text, lastLabel;
@synthesize indexInLevel, clickedMenu;
@synthesize delegate;

#pragma mark - View subclass

- (void)sizeToFit {
	[super sizeToFit];
	
	CGFloat width = (2 + (self.image != nil)) * ZWJumpBarLabelMargin;
	
	NSSize textSize = [self.text sizeWithAttributes:self.attributes];
	width += ceil(textSize.width);
	width += ceil(self.image.size.width);
	if(!self.lastLabel) width += 7;  // Separator image
	
	NSRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

#pragma mark - Getter/Setters

- (CGFloat)minimumWidth {
	return ZWJumpBarLabelMargin + self.image.size.width + (self.image != nil) * ZWJumpBarLabelMargin + (!self.lastLabel) * 7;
}

- (void)setImage:(NSImage *)newImage {
	if(image != newImage) {
		image = newImage;
		[self setNeedsDisplay];
	}
}

- (void)setText:(NSString *)newText {
	if(text != newText) {
		text = newText;
		[self setNeedsDisplay];
	}
}

- (NSUInteger)level {
	return self.tag;
}

- (void)setLevel:(NSUInteger)level {
	self.tag = level;
}

#pragma mark - Delegate

- (void)mouseDown:(NSEvent *)theEvent {
	if(self.isEnabled) {
		self.clickedMenu = [self.delegate menuToPresentWhenClickedForJumpBarLabel:self];
		[self setPropretyOnMenu:self.clickedMenu];
		
		CGFloat xPoint = (self.tag == ZWJumpBarLabelAccessoryMenuLabelTag ? -9 : -16);
		
		[self.clickedMenu popUpMenuPositioningItem:[self.clickedMenu itemAtIndex:self.indexInLevel]
										atLocation:NSMakePoint(xPoint, self.frame.size.height - 4) inView:self];
	}
}

- (void)menuClicked:(id)sender {
	NSMenuItem *item = sender;
	NSIndexPath *indexPath = [[NSIndexPath alloc] init];
	
	if(self.tag != ZWJumpBarLabelAccessoryMenuLabelTag) {
		while(![[self.clickedMenu itemArray] containsObject:item]) {
			indexPath = [indexPath indexPathByAddingIndexInFront:[[item menu] indexOfItem:item]];
			item = [item parentItem];
		}
	}
	indexPath = [indexPath indexPathByAddingIndexInFront:[[item menu] indexOfItem:item]];
	
	[self.delegate jumpBarLabel:self didReceivedClickOnItemAtIndexPath:indexPath];
	
	self.clickedMenu = nil;
}

#pragma mark - Dawing

- (void)drawRect:(NSRect)dirtyRect {
	CGFloat baseLeft = 0;
	
	static NSImage *separatorImage = nil;
	static dispatch_once_t seperatorImageOnce;
	dispatch_once(&seperatorImageOnce, ^{
		const unsigned int separatorImagePixels[91] = {
			0x00000000, 0x00000012, 0xFFFFFF10, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
			0x00000000, 0x00000016, 0x5E5E5E36, 0xFFFFFF19, 0x00000000, 0x00000000, 0x00000000, 
			0x00000000, 0x00000000, 0x00000051, 0xCECECE53, 0xFFFFFF0A, 0x00000000, 0x00000000, 
			0x00000000, 0x00000000, 0x00000009, 0x0C0C0C82, 0xFAFAFA6A, 0x00000000, 0x00000000, 
			0x00000000, 0x00000000, 0x00000000, 0x00000043, 0x46464692, 0xFFFFFF52, 0x00000000, 
			0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x02020293, 0x979797A5, 0xFFFFFF31, 
			0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000004A, 0x232323C0, 0xFFFFFF87, 
			0x00000000, 0x00000000, 0x00000000, 0x00000004, 0x050505A5, 0xB6B6B6A5, 0xFFFFFF21, 
			0x00000000, 0x00000000, 0x00000000, 0x0000005A, 0x68686890, 0xFFFFFF40, 0x00000000, 
			0x00000000, 0x00000000, 0x00000014, 0x18181881, 0xFFFFFF5E, 0x00000000, 0x00000000, 
			0x00000000, 0x00000000, 0x0000005A, 0xEAEAEA55, 0xFFFFFF04, 0x00000000, 0x00000000, 
			0x00000000, 0x00000022, 0x8888883A, 0xFFFFFF12, 0x00000000, 0x00000000, 0x00000000, 
			0x00000002, 0x00000014, 0xFFFFFF12, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
		};
		NSData *data = [NSData dataWithBytesNoCopy:(void *)separatorImagePixels length:91 freeWhenDone:NO];
		CGImageRef cgImage = CGImageCreateWithPixelData(data, 7, 13, 8, 32, sizeof(unsigned int) * 7, [[NSColorSpace deviceRGBColorSpace] CGColorSpace], kCGImageAlphaLast | kCGBitmapByteOrder32Little, NO, YES, kCGRenderingIntentDefault);
		separatorImage = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(7, 13)];
		CGImageRelease(cgImage);
	});
	
	if(self.tag == ZWJumpBarLabelAccessoryMenuLabelTag) {
		[separatorImage drawAtPoint:NSMakePoint(baseLeft + 1, self.frame.size.height / 2 - separatorImage.size.height / 2)
						   fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		baseLeft += separatorImage.size.width + ZWJumpBarLabelMargin;
	} else baseLeft = ZWJumpBarLabelMargin;
	
	if(self.image != nil) {
		[self.image drawAtPoint:NSMakePoint(baseLeft, floorf(self.frame.size.height / 2 - self.image.size.height / 2))
					   fromRect:NSZeroRect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
		baseLeft += ceil(self.image.size.width) + ZWJumpBarLabelMargin;
	}
	
	if(self.text != nil) {
		NSSize textSize = [self.text sizeWithAttributes:self.attributes];
		CGFloat width = self.frame.size.width - baseLeft - ZWJumpBarLabelMargin;
		if(!self.lastLabel && self.tag != ZWJumpBarLabelAccessoryMenuLabelTag) width -= 7;
		
		if(width > 0) {
			[self.text drawInRect:CGRectMake(baseLeft, self.frame.size.height / 2 - textSize.height / 2
											 , width, textSize.height)
				   withAttributes:self.attributes];
			baseLeft += width + ZWJumpBarLabelMargin;
		}
	}
	
	if(!self.lastLabel && self.tag != ZWJumpBarLabelAccessoryMenuLabelTag) {
		NSImage *separatorImage = [NSImage imageNamed:@"ZWJumpBarSeparator.png"];
		[separatorImage drawAtPoint:NSMakePoint(baseLeft, self.frame.size.height / 2 - separatorImage.size.height / 2)
						   fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

#pragma mark - Helper

- (NSDictionary *)attributes {
	NSShadow *highlightShadow = [[NSShadow alloc] init];
	
	highlightShadow.shadowOffset = CGSizeMake(0, -1.0);
	highlightShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.5];
	highlightShadow.shadowBlurRadius = 0.0;
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName,
								highlightShadow, NSShadowAttributeName,
								[NSFont systemFontOfSize:12.0], NSFontAttributeName,
								style, NSParagraphStyleAttributeName, nil];
	
	return attributes;
}

- (void)setPropretyOnMenu:(NSMenu *)menu {
	for(NSMenuItem *item in [menu itemArray]) {
		if(item.isEnabled) {
			[item setTarget:self];
			[item setAction:@selector(menuClicked:)];
			if([item hasSubmenu]) [self setPropretyOnMenu:item.submenu];
		}
	}
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
}

@end
