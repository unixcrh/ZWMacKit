#import <Cocoa/Cocoa.h>

enum {
    ZWDocumentPositioningAlignCenter = 0,
    ZWDocumentPositioningAlignTop,
    ZWDocumentPositioningAlignTopLeft,
    ZWDocumentPositioningAlignTopRight,
    ZWDocumentPositioningAlignLeft,
    ZWDocumentPositioningAlignBottom,
    ZWDocumentPositioningAlignBottomLeft,
    ZWDocumentPositioningAlignBottomRight,
    ZWDocumentPositioningAlignRight
};
typedef NSUInteger ZWDocumentPositioningAlignment;

@interface ZWDocumentPositioningView : NSView

#pragma mark - Properties

@property (nonatomic, strong) NSView *documentView;
@property (nonatomic, assign) ZWDocumentPositioningAlignment documentViewAlignment;

#pragma mark - Actions

- (void)documentViewBoundsDidChange:(NSNotification *)pNotification;
- (void)documentViewFrameDidChange:(NSNotification *)pNotification;

@end
