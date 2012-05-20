#import "ZWObjectsController.h"
#import "ZWSelectionController.h"


@interface ZWObjectsController (PRIVATE)

- (void)_notifyDelegatesDidInsertObjects:(NSSet *)pObjects;
- (void)_notifyDelegatesDidRemoveObjects:(NSSet *)pObjects;
- (void)_notifyDelegatesObjectsDidChange;
- (void)_notifyDelegatesSelectionDidChange;

@end
@implementation ZWObjectsController (PRIVATE)

- (void)_notifyDelegatesDidInsertObjects:(NSSet *)pObjects {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsController:insertedObjects:)]) {
			[delegate objectsController:self insertedObjects:pObjects];
		}
	}
}
- (void)_notifyDelegatesDidRemoveObjects:(NSSet *)pObjects {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsController:removedObjects:)]) {
			[delegate objectsController:self removedObjects:pObjects];
		}
	}
}
- (void)_notifyDelegatesObjectsDidChange {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsControllerObjectsDidChange:)]) {
			[delegate objectsControllerObjectsDidChange:self];
		}
	}
}
- (void)_notifyDelegatesDidSelectObjects:(NSSet *)pObjects {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsController:selectedObjects:)]) {
			[delegate objectsController:self selectedObjects:pObjects];
		}
	}
}
- (void)_notifyDelegatesDidDeselectObjects:(NSSet *)pObjects {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsController:deselectedObjects:)]) {
			[delegate objectsController:self deselectedObjects:pObjects];
		}
	}
}
- (void)_notifyDelegatesSelectionDidChange {
	for(id <ZWObjectsControllerDelegate> delegate in delegates) {
		if([delegate respondsToSelector:@selector(objectsControllerSelectionDidChange:)]) {
			[delegate objectsControllerSelectionDidChange:self];
		}
	}
}

@end



@implementation ZWObjectsController

#pragma mark - Properties

@synthesize objects;
@synthesize selection;
@dynamic selectedObjects;
@synthesize delegates;

- (NSSet *)selectedObjects {
	return selection.selectedObjects;
}

#pragma mark - Initialization

+ (id)objectsController {
	return [[self alloc] init];
}
- (id)init {
	if((self = [super init])) {
		objects = [NSMutableSet set];
		selection = [ZWSelectionController selectionController];
		delegates = [NSMutableSet set];
	}
	return self;
}

#pragma mark - Delegates

- (void)addDelegate:(id)pDelegate {
	[delegates addObject:pDelegate];
}
- (void)removeDelegate:(id)pDelegate {
	[delegates removeObject:pDelegate];
}

#pragma mark - Objects

- (void)addObject:(id)pObject {
	[self addObjects:[NSSet setWithObject:pObject]];
}
- (void)addObjects:(NSSet *)pObjects {
	if(![pObjects isSubsetOfSet:objects]) {
		NSMutableSet *addObjects = [pObjects mutableCopy];
		[addObjects minusSet:objects];
		if([addObjects count] > 0) {
			[self willChangeValueForKey:@"objects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:addObjects];
			[objects unionSet:addObjects];
			[self didChangeValueForKey:@"objects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:addObjects];
			[self _notifyDelegatesDidInsertObjects:objects];
			[self _notifyDelegatesObjectsDidChange];
			[self selectObjects:addObjects byExtendingSelection:NO];
		}
	}
}
- (void)removeObject:(id)pObject {
	[self removeObjects:[NSSet setWithObject:pObject]];
}
- (void)removeObjects:(NSSet *)pObjects {
	if(![pObjects intersectsSet:objects]) {
		NSMutableSet *removeObjects = [pObjects mutableCopy];
		[removeObjects intersectsSet:objects];
		if([removeObjects count] > 0) {
			[self deselectObjects:removeObjects];
			[self willChangeValueForKey:@"objects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:removeObjects];
			[objects minusSet:removeObjects];
			[self didChangeValueForKey:@"objects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:removeObjects];
			[self _notifyDelegatesDidRemoveObjects:objects];
			[self _notifyDelegatesObjectsDidChange];
		}
	}
}

#pragma mark - Selection Helpers

- (void)selectObject:(id)pObject byExtendingSelection:(BOOL)pByExtendingSelection {
	if(![selection.selectedObjects containsObject:pObject]) {
		[self willChangeValueForKey:@"selection"];
		[selection addSelectedObject:pObject byExtendingSelection:pByExtendingSelection];
		[self didChangeValueForKey:@"selection"];
		[self _notifyDelegatesDidSelectObjects:[NSSet setWithObject:pObject]];
		[self _notifyDelegatesSelectionDidChange];
	}
}
- (void)selectObjects:(NSSet *)pObjects byExtendingSelection:(BOOL)pByExtendingSelection {
	if((pByExtendingSelection && ![pObjects isSubsetOfSet:selection.selectedObjects]) ||
	   (!pByExtendingSelection && ![pObjects isEqualToSet:selection.selectedObjects])) {
		[self willChangeValueForKey:@"selection"];
		[selection addSelectedObjects:pObjects byExtendingSelection:pByExtendingSelection];
		[self didChangeValueForKey:@"selection"];
		[self _notifyDelegatesDidSelectObjects:pObjects];
		[self _notifyDelegatesSelectionDidChange];
	}
}
- (void)deselectObject:(id)pObject {
	if([selection.selectedObjects containsObject:pObject]) {
		[self willChangeValueForKey:@"selection"];
		[selection removeSelectedObject:pObject];
		[self didChangeValueForKey:@"selection"];
		[self _notifyDelegatesDidDeselectObjects:[NSSet setWithObject:pObject]];
		[self _notifyDelegatesSelectionDidChange];
	}
}
- (void)deselectObjects:(NSSet *)pObjects {
	if([selection.selectedObjects intersectsSet:pObjects]) {
		[self willChangeValueForKey:@"selection"];
		[selection removeSelectedObjects:pObjects];
		[self didChangeValueForKey:@"selection"];
		[self _notifyDelegatesDidDeselectObjects:pObjects];
		[self _notifyDelegatesSelectionDidChange];
	}
}

#pragma mark - Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	objects = nil;
	selection = nil;
	delegates = nil;
}

@end
