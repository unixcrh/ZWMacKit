#import <AppKit/AppKit.h>

@interface NSOutlineView (ZWMacExtensions)

- (NSArray *)itemsAtRowIndexes:(NSIndexSet *)pIndexes;
- (NSSet *)selectedItems;
- (void)selectItems:(NSSet *)pItems byExtendingSelection:(BOOL)pExtendSelection;
- (void)reloadData:(BOOL)pPreserveSelection;

@end
