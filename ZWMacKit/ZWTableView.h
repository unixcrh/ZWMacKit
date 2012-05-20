#import <Cocoa/Cocoa.h>


@interface ZWTableView : NSTableView {
}

#pragma mark - Properties

@property (strong, readonly) NSGradient *highlightGradient;
@property (strong, readonly) NSGradient *groupGradient;

#pragma mark - Drawing

- (void)drawHighlightGradientInRect:(NSRect)pRect strokeEdges:(BOOL)pStrokeEdges;
- (void)drawGroupGradientInRect:(NSRect)pRect strokeEdges:(BOOL)pStrokeEdges;

@end
