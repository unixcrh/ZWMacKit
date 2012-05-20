@class ZWSelectionController;
@class ZWObjectsController;


@protocol ZWObjectsControllerDelegate <NSObject>

@optional

- (void)objectsController:(ZWObjectsController *)pObjectsController insertedObjects:(NSSet *)pObjects;
- (void)objectsController:(ZWObjectsController *)pObjectsController removedObjects:(NSSet *)pObjects;
- (void)objectsControllerObjectsDidChange:(ZWObjectsController *)pObjectsController;
- (void)objectsController:(ZWObjectsController *)pObjectsController selectedObjects:(NSSet *)pObjects;
- (void)objectsController:(ZWObjectsController *)pObjectsController deselectedObjects:(NSSet *)pObjects;
- (void)objectsControllerSelectionDidChange:(ZWObjectsController *)pObjectsController;

@end


@interface ZWObjectsController : NSObject {
	NSEntityDescription *entity;
	NSManagedObjectContext *managedObjectContext;
	NSMutableSet *objects;
	ZWSelectionController *selection;
	NSMutableSet *delegates;
}

#pragma mark - Properties

@property (strong, nonatomic, readonly) NSSet *objects;
@property (strong, nonatomic, readonly) ZWSelectionController *selection;
@property (strong, nonatomic, readonly) NSSet *selectedObjects;
@property (strong, nonatomic, readonly) NSSet *delegates;

#pragma mark - Initialization

+ (id)objectsController;

#pragma mark - Delegates

- (void)addDelegate:(id <ZWObjectsControllerDelegate>)pDelegate;
- (void)removeDelegate:(id <ZWObjectsControllerDelegate>)pDelegate;

#pragma mark - Objects

- (void)addObject:(id)pObject;
- (void)addObjects:(NSSet *)pObjects;
- (void)removeObject:(id)pObject;
- (void)removeObjects:(NSSet *)pObjects;

#pragma mark - Selection Helpers

- (void)selectObject:(id)pObject byExtendingSelection:(BOOL)pByExtendingSelection;
- (void)selectObjects:(NSSet *)pObjects byExtendingSelection:(BOOL)pByExtendingSelection;
- (void)deselectObject:(id)pObject;
- (void)deselectObjects:(NSSet *)pObjects;

@end
