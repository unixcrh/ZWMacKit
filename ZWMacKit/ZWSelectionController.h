@interface ZWSelectionController : NSObject {
}

#pragma mark - Properties

@property (nonatomic, readonly) NSSet *selectedObjects;
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic, readonly) BOOL multiple;

#pragma mark - Intializaiton

+ (id)selectionController;

#pragma mark - Selection

- (void)addSelectedObject:(id)pObject byExtendingSelection:(BOOL)pByExtendingSelection;
- (void)addSelectedObjects:(NSSet *)pObjects byExtendingSelection:(BOOL)pByExtendingSelection;
- (void)removeSelectedObject:(id)pObject;
- (void)removeSelectedObjects:(NSSet *)pObjects;

@end
