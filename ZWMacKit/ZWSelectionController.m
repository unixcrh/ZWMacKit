#import "ZWSelectionController.h"


@interface ZWSelectionController() {
	
}

@property (assign) NSMutableSet *mutableSelectedObjects;

@end
@implementation ZWSelectionController

#pragma mark - Class Methods

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)pKey {
	if([super automaticallyNotifiesObserversForKey:pKey]) {
		if([pKey isEqualToString:@"selectedObjects"] ||
		   [pKey isEqualToString:@"mutableSelectedObjects"]) {
			return NO;
		}
		return YES;
	}
	return NO;
}

#pragma mark - Properties

@dynamic selectedObjects;
@dynamic empty;
@dynamic multiple;
@synthesize mutableSelectedObjects;

- (NSSet *)selectedObjects {
	return [self.mutableSelectedObjects copy];
}
- (BOOL)empty {
	return ([self.mutableSelectedObjects count] == 0);
}
- (BOOL)multiple {
	return ([self.mutableSelectedObjects count] > 1);
}

#pragma mark - Initialization

+ (id)selectionController {
	return [[self alloc] init];
}
- (id)init {
	if((self = [super init])) {
		self.mutableSelectedObjects = [NSMutableSet set];
	}
	return self;
}

#pragma mark - Key Value Coding

- (id)valueForKey:(NSString *)pKey {
	if([pKey isEqualToString:@"empty"] || [pKey isEqualToString:@"multiple"]) {
		return [super valueForKey:pKey];
	}
	NSUInteger objectsCount = [self.mutableSelectedObjects count];
	if(objectsCount == 0) {
		return NSNoSelectionMarker;
	} else if(objectsCount == 1) {
		return [[self.mutableSelectedObjects anyObject] valueForKey:pKey];
	}  else {
		id value = nil;
		for(id object in self.mutableSelectedObjects) {
			if(value == nil) {
				value = [object valueForKey:pKey];
			} else {
				if(![value isEqual:[object valueForKey:pKey]]) {
					return NSMultipleValuesMarker;
				}
			}
		}
		return value;
	}
}
- (void)setValue:(id)pValue forKey:(NSString *)pKey {
	for(id object in self.mutableSelectedObjects) {
		[object setValue:pValue forKey:pKey];
	}
}

#pragma mark - Selection

- (void)addSelectedObject:(id)pObject byExtendingSelection:(BOOL)pByExtendingSelection {
	[self addSelectedObjects:[NSSet setWithObject:pObject] byExtendingSelection:pByExtendingSelection];
}
- (void)addSelectedObjects:(NSSet *)pObjects byExtendingSelection:(BOOL)pByExtendingSelection {
	if(pByExtendingSelection && ![pObjects isSubsetOfSet:self.mutableSelectedObjects]) {
		[self willChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:pObjects];
		[self.mutableSelectedObjects unionSet:pObjects];
		[self didChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueUnionSetMutation usingObjects:pObjects];
	} else if(!pByExtendingSelection && [pObjects isEqualToSet:self.mutableSelectedObjects]) {
		[self willChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueSetSetMutation usingObjects:pObjects];
		[self.mutableSelectedObjects setSet:pObjects];
		[self didChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueSetSetMutation usingObjects:pObjects];
	}
}
- (void)removeSelectedObject:(id)pObject {
	[self removeSelectedObjects:[NSSet setWithObject:pObject]];
}
- (void)removeSelectedObjects:(NSSet *)pObjects {
	if([pObjects intersectsSet:self.mutableSelectedObjects]) {
		[self willChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:pObjects];
		[self.mutableSelectedObjects minusSet:pObjects];
		[self didChangeValueForKey:@"selectedObjects" withSetMutation:NSKeyValueMinusSetMutation usingObjects:pObjects];
	}
}


@end
