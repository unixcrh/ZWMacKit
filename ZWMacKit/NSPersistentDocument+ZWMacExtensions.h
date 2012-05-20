#import <CoreData/CoreData.h>

@interface NSPersistentDocument (ZWMacExtensions)

@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)migrateDocumentStoreAtURL:(NSURL *)pSourceStoreURL 
							 type:(NSString *)pSourceStoreType
							model:(NSManagedObjectModel *)pSourceStoreModel
						  options:(NSDictionary *)pSourceStoreOptions 
				 withMappingModel:(NSMappingModel *)pMappingModel 
				  destinationType:(NSString *)pDestinationStoreType 
				 destinationModel:(NSManagedObjectModel *)pDestinationStoreModel
			   destinationOptions:(NSDictionary *)pDestinationStoreOptions 
							error:(NSError **)pError;

- (void)disableUndo;
- (void)enableUndo:(NSDocumentChangeType)pChangeType;
- (void)disableUndoForBlock:(void (^)(NSDocumentChangeType *changeType))pBlock;
- (void)enableUndoForBlock:(void (^)(__autoreleasing NSString **actionName))pBlock;

- (void)restoreInterfaceStateWithCoder:(NSCoder *)pCoder;
- (void)encodeInterfaceStateWithCoder:(NSCoder *)pCoder;

@end
