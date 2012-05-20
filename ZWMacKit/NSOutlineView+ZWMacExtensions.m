#import "NSOutlineView+ZWMacExtensions.h"

@implementation NSOutlineView (ZWMacExtensions)

- (NSArray *)itemsAtRowIndexes:(NSIndexSet *)pIndexes {
	if(pIndexes.count > 0) {
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:pIndexes.count];
		[pIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			id item = [self itemAtRow:idx];
			if(item != nil) {
				[items addObject:item];
			}
		}];
		return (items.count > 0) ? items : nil;
	}
	return nil;
}
- (NSSet *)selectedItems {
	NSIndexSet *indexes = self.selectedRowIndexes;
	if(indexes.count > 0) {
		NSMutableSet *selectedItems = [NSMutableSet setWithCapacity:indexes.count];
		[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			id item = [self itemAtRow:idx];
			if(item != nil) {
				[selectedItems addObject:item];
			}
		}];
		return (selectedItems.count > 0) ? selectedItems : nil;
	}
	return nil;
}
- (void)selectItems:(NSSet *)pItems byExtendingSelection:(BOOL)pExtendSelection {
	if(pItems.count > 0) {
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		[pItems enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			NSInteger index = [self rowForItem:obj];
			if(index >= 0) {
				[indexes addIndex:index];
			}
		}];
		[self selectRowIndexes:indexes byExtendingSelection:pExtendSelection];
	} else {
		[self deselectAll:nil];
	}
}
- (void)reloadData:(BOOL)pPreserveSelection {
	if(pPreserveSelection) {
		NSSet *selectedItems = self.selectedItems;
		[self reloadData];
		[self selectItems:selectedItems byExtendingSelection:NO];
		if(self.selectedRowIndexes.count == 0 && 
		   !self.allowsEmptySelection &&
		   self.numberOfRows > 0) {
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		}
	} else {
		[self reloadData];
		if(self.selectedRowIndexes.count == 0 && 
		   !self.allowsEmptySelection &&
		   self.numberOfRows > 0) {
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		}
	}
}

@end
