#import "ZWDocumentPositioningView.h"
#import "NSView+ZWMacExtensions.h"

@interface ZWDocumentPositioningView() {
	
}

- (void)positionDocumentView;

@end
@implementation ZWDocumentPositioningView

#pragma mark - Properties

@synthesize documentView;
@synthesize documentViewAlignment;

- (void)setDocumentView:(NSView *)pValue {
	if(pValue != documentView) {
		if(documentView != nil) {
			[[NSNotificationCenter defaultCenter] removeObserver:self 
															name:NSViewBoundsDidChangeNotification 
														  object:documentView];
			[[NSNotificationCenter defaultCenter] removeObserver:self 
															name:NSViewFrameDidChangeNotification 
														  object:documentView];
			[documentView removeFromSuperview];
		}
		documentView = pValue;
		if(documentView != nil) {
			[self addSubview:documentView];
			[self positionDocumentView];
			documentView.autoresizingMask = NSViewNotSizable;
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(documentViewBoundsDidChange:)
														 name:NSViewBoundsDidChangeNotification
													   object:documentView];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(documentViewFrameDidChange:)
														 name:NSViewFrameDidChangeNotification
													   object:documentView];
		}
	}
}
- (void)setDocumentViewAlignment:(ZWDocumentPositioningAlignment)pValue {
	documentViewAlignment = pValue;
	[self positionDocumentView];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)pCoder {
	if((self = [super initWithCoder:pCoder])) {
		self.wantsLayer = YES;
		self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		documentViewAlignment = ZWDocumentPositioningAlignCenter;
	}
	return self;
}
- (id)initWithFrame:(CGRect)pFrame {
	if((self = [super initWithFrame:pFrame])) {
		self.wantsLayer = YES;
		self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		documentViewAlignment = ZWDocumentPositioningAlignCenter;
	}
	return self;
}

#pragma mark - NSView

- (CALayer *)makeBackingLayer {
	CALayer *layer = [CALayer layer];
	layer.anchorPoint = CGPointZero;
	layer.frame = NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height);
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	layer.needsDisplayOnBoundsChange = NO;
	layer.masksToBounds = YES;
	return layer;
}
- (void)viewDidMoveToSuperview {
	[self positionDocumentView];
}
- (void)resizeSubviewsWithOldSize:(NSSize)pOldSize {
	[super resizeSubviewsWithOldSize:pOldSize];
	[self positionDocumentView];
}

#pragma mark - Actions

- (void)documentViewBoundsDidChange:(NSNotification *)pNotification {
	[self positionDocumentView];
	[self setNeedsDisplay:YES];
}
- (void)documentViewFrameDidChange:(NSNotification *)pNotification {
	[self positionDocumentView];
	[self setNeedsDisplay:YES];
}

#pragma mark - Private Actions

- (void)positionDocumentView {
	// no superview
	if(self.superview == nil) {
		return;
	}
	
	NSSize contentSize = self.superview.boundsSize;
	NSRect oldDocumentFrame = (documentView == nil) ? NSZeroRect : documentView.frame;
	NSRect oldFrame = self.frame;
	NSRect newFrame = oldFrame;
	
	newFrame.size.width = MAX(oldDocumentFrame.size.width, contentSize.width);
	newFrame.size.height = MAX(oldDocumentFrame.size.height, contentSize.height);
	if(!NSEqualRects(newFrame, oldFrame)) {
		self.frame = newFrame;
		[self.superview setNeedsDisplayInRect:NSUnionRect(oldFrame, newFrame)];
	}
	if(documentView != nil) {
		NSRect newDocumentFrame = oldDocumentFrame;
		
		switch(documentViewAlignment) {
			case ZWDocumentPositioningAlignCenter :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
				break;
				
			case ZWDocumentPositioningAlignTop :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
				break;

			case ZWDocumentPositioningAlignTopLeft :
				newDocumentFrame.origin.x = 0.0f;
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
				break;
				
			case ZWDocumentPositioningAlignTopRight :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
				break;
				
			case ZWDocumentPositioningAlignLeft :
				newDocumentFrame.origin.x = 0.0f;
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
				break;
				
			case ZWDocumentPositioningAlignBottom :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
				newDocumentFrame.origin.y = 0.0f;
				break;
				
			case ZWDocumentPositioningAlignBottomLeft :
				newDocumentFrame.origin.x = 0.0f;
				newDocumentFrame.origin.y = 0.0f;
				break;
				
			case ZWDocumentPositioningAlignBottomRight :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
				newDocumentFrame.origin.y = 0.0f;
				break;
				
			case ZWDocumentPositioningAlignRight :
				newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
				break;
				
			default :
				newDocumentFrame.origin.x = 0.0f;
				newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
				break;
		}
		
        newDocumentFrame.origin.x = round(newDocumentFrame.origin.x);
        newDocumentFrame.origin.y = round(newDocumentFrame.origin.y);
		
		if(!NSEqualPoints(newDocumentFrame.origin, oldDocumentFrame.origin)) {
			documentView.frameOrigin = newDocumentFrame.origin;
            [self setNeedsDisplayInRect:NSUnionRect(oldDocumentFrame, newDocumentFrame)];
        }
	}
}

#pragma mark - Dealloc

- (void)dealloc {
    self.documentView = nil;
}

@end
