#import "NSPersistentDocument+ZWMacExtensions.h"


@implementation NSPersistentDocument (ZWMacExtensions)

@dynamic persistentStoreCoordinator;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	@synchronized(self) {
		return self.managedObjectContext.persistentStoreCoordinator;
	}
	return nil;
}

- (BOOL)migrateDocumentStoreAtURL:(NSURL *)pSourceStoreURL 
							 type:(NSString *)pSourceStoreType
							model:(NSManagedObjectModel *)pSourceStoreModel
						  options:(NSDictionary *)pSourceStoreOptions 
				 withMappingModel:(NSMappingModel *)pMappingModel 
				  destinationType:(NSString *)pDestinationStoreType 
				 destinationModel:(NSManagedObjectModel *)pDestinationStoreModel
			   destinationOptions:(NSDictionary *)pDestinationStoreOptions 
							error:(NSError **)pError {
	// fileManager
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// tempURL
	NSString *tempName = [NSString stringWithFormat:@"ZWKit-Document-%@", [[NSProcessInfo processInfo] globallyUniqueString]];
	NSString *tempPath = [[[pSourceStoreURL path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:tempName];
	NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
	
	// migration manager
	NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:pSourceStoreModel
																		  destinationModel:pDestinationStoreModel];
	
	// migrate
	if(![migrationManager migrateStoreFromURL:pSourceStoreURL
										 type:pSourceStoreType
									  options:pSourceStoreOptions
							 withMappingModel:pMappingModel
							 toDestinationURL:tempURL
							  destinationType:pDestinationStoreType
						   destinationOptions:pDestinationStoreOptions
										error:pError]) {
		return NO;
	}
	
	// replace old store with migrated store
	NSURL *finalURL = nil;
	if(![fileManager replaceItemAtURL:pSourceStoreURL
						withItemAtURL:tempURL
					   backupItemName:nil
							  options:NSFileManagerItemReplacementUsingNewMetadataOnly
					 resultingItemURL:&finalURL
								error:pError]) {
		[fileManager removeItemAtURL:tempURL error:nil];
		return NO;
	}
	return YES;
}

- (void)disableUndo {
	@synchronized(self) {
		if([[self undoManager] isUndoRegistrationEnabled]) {
			[[self managedObjectContext] processPendingChanges];
			[[self undoManager] disableUndoRegistration];
		}
	}
}
- (void)enableUndo:(NSDocumentChangeType)pChangeType {
	@synchronized(self) {
		if(![[self undoManager] isUndoRegistrationEnabled]) {
			[[self managedObjectContext] processPendingChanges];
			[[self undoManager] enableUndoRegistration];
			if(pChangeType != NSNotFound) {
				[self updateChangeCount:pChangeType];
			}
		}
	}
}
- (void)disableUndoForBlock:(void (^)(NSDocumentChangeType *changeType))pBlock {
	@synchronized(self) {
		if([[self undoManager] isUndoRegistrationEnabled]) {
			[self disableUndo];
			NSDocumentChangeType changeType = NSNotFound;
			pBlock(&changeType);
			[self enableUndo:changeType];
		} else {
			NSDocumentChangeType changeType = NSNotFound;
			pBlock(&changeType);
			if(changeType != NSNotFound) {
				[self updateChangeCount:changeType];
			}
		}
	}
}
- (void)enableUndoForBlock:(void (^)(__autoreleasing NSString **actionName))pBlock {
	@synchronized(self) {
		[[self undoManager] beginUndoGrouping];
		NSString *actionName = nil;
		pBlock(&actionName);
		[[self managedObjectContext] processPendingChanges];
		[[self undoManager] setActionName:actionName];
		[[self undoManager] endUndoGrouping];
	}
}

- (void)defaultInterfaceStateWithCoder:(NSCoder *)pCoder {
	
}
- (void)restoreInterfaceStateWithCoder:(NSCoder *)pCoder {
	
}
- (void)encodeInterfaceStateWithCoder:(NSCoder *)pCoder {
	
}

@end
