#import <Cocoa/Cocoa.h>


@interface ZWOutlineView : NSOutlineView {
}

#pragma mark - Properties

@property (strong, readonly) NSGradient *highlightGradient;
@property (strong, readonly) NSGradient *groupGradient;

#pragma mark - Drawing

- (void)drawHighlightGradientInRect:(NSRect)pRect strokeEdges:(ZWEdges)pStrokeEdges;
- (void)drawGroupGradientInRect:(NSRect)pRect strokeEdges:(ZWEdges)pStrokeEdges;

@end
