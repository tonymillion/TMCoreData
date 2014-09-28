//
//  TMCoreData.m
//  TMCoreData
//
//  Created by Tony Million on 02/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import "TMCoreData.h"

#import "TMCDLog.h"

#import "NSManagedObjectModel+KCOrderedAccessorFix.h"

#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


NSString *const kTMCoreDataiCloudIsAvailableNotification = @"kTMCoreDataiCloudIsAvailableNotification";


@interface TMCoreData ()

@property(strong) NSURL     *persistentStoreURL;
@property(strong, nonatomic) NSManagedObjectModel          *objectModel;
@property(strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@end

//TODO: make a variable to see wether iCloud is actually online or if we're using a local version because user doesn't have iCloud

@implementation TMCoreData

@synthesize primaryContext              = _primaryContext;
@synthesize mainThreadContext           = _mainThreadContext;

-(id)init
{
    //TODO: replace this with app name!
    NSString * name = [NSString stringWithFormat:@"%@.sqlite", [[NSBundle mainBundle] bundleIdentifier]];
    return [self initWithLocalStoreNamed:name];
}

-(id)initWithLocalStoreNamed:(NSString*)localStore
{
    return [self initWithLocalStoreNamed:localStore
                             objectModel:nil];
}

-(id)initWithLocalStoreNamed:(NSString*)localStore objectModel:(NSManagedObjectModel*)objectModel
{
    return [self initWithLocalStoreURL:[self.class persistentStoreURLForStoreNamed:localStore]
                           objectModel:objectModel];
}

-(id)initWithLocalStoreURL:(NSURL*)localStoreURL objectModel:(NSManagedObjectModel*)objectModel
{
    self = [super init];
    if(self)
    {
        _persistentStoreURL = localStoreURL;
        
        if(objectModel)
        {
            _objectModel = objectModel;
        }
        else
        {
            _objectModel = [self objectModelFromAppBundle];
        }
        
        [_objectModel kc_generateOrderedSetAccessors];
        
        // Define the Core Data version migration options
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption: @YES};
        
        // Attempt to load the persistent store
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_objectModel];
        
    tryagain:
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:[self persistentStoreURL]
                                                            options:options
                                                              error:&error])
        {
            TMCDLog(@"Fatal error while creating persistent store: %@", error);
            
            if ([error.domain isEqualToString:NSCocoaErrorDomain] && [error code] == NSMigrationMissingSourceModelError)
            {
                // Could not open the database, so... kill it!
                [[NSFileManager defaultManager] removeItemAtURL:[self persistentStoreURL]
                                                          error:nil];
                
                goto tryagain;
            }
        }
    }
    
    return self;
}

-(NSManagedObjectModel*)objectModelFromAppBundle
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    });
    
	return _objectModel;
}


#pragma mark - context getting stuff

-(NSManagedObjectContext*)primaryContext
{
    if(_primaryContext == nil)
    {
        @synchronized(self)
        {
            _primaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_primaryContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [_primaryContext setStalenessInterval:60];
        }
    }

    return _primaryContext;
}

-(NSManagedObjectContext*)mainThreadContext
{
    if(!_mainThreadContext)
    {
        @synchronized(self)
        {
            _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainThreadContext setParentContext:self.primaryContext];
            [_mainThreadContext setStalenessInterval:60];
            //[_mainThreadContext observeChangesFromParent:YES];
        }
    }

    return _mainThreadContext;
}

-(NSManagedObjectContext*)scratchContext
{
    NSManagedObjectContext * parentContext = [self mainThreadContext];
    if(!parentContext)
        return nil;
    
    NSManagedObjectContext * tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [tempContext setParentContext:parentContext];
    
    return tempContext;
}

#pragma mark - Helper stuff
// Returns the URL to the application's Documents directory.
+(NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+(NSURL *)persistentStoreURLForStoreNamed:(NSString *)name;
{
    return [[self applicationLibraryDirectory] URLByAppendingPathComponent:name];
}

#pragma mark - persistent store coordinator stuff


-(void)resetPersistentStore
{
	NSError *error = nil;
    
    if(!_persistentStoreCoordinator)
    {
        TMCDLog(@"NO PERSISTENT STORE ACTIVE - JUST DELETING FILE!!");
        NSError * fileError;
        
		if(![[NSFileManager defaultManager] removeItemAtURL:[self persistentStoreURL]
													  error:&fileError])
		{
			TMCDLog(@"ERROR DELETING STORE: %@", fileError);
		}
        
        return;
    }
    

    @synchronized(self)
    {
        [_mainThreadContext performBlockAndWait:^{
            [_mainThreadContext reset];
        }];

        [_primaryContext performBlockAndWait:^{
            [_primaryContext reset];
        }];

        // we can't handle scratch contexts in use using this :(
        // deallocate these please!
        _mainThreadContext = nil;
        _primaryContext = nil;


        for (NSPersistentStore *store in [_persistentStoreCoordinator persistentStores])
        {
            if (![_persistentStoreCoordinator removePersistentStore:store
                                                              error:&error])
            {
                TMCDLog(@"removePersistentStore error %@, %@", error, [error userInfo]);
            }
            
            TMCDLog(@"Deleting: %@", store.URL.absoluteString);
            
            if (![[NSFileManager defaultManager] removeItemAtURL:store.URL
                                                           error:&error])
            {
                TMCDLog(@" %@, %@", error, [error userInfo]);
            }
        }
        
        // Define the Core Data version migration options
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption: @YES};
        
    readdagain:
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:[self persistentStoreURL]
                                                             options:options
                                                               error:&error])
        {
            TMCDLog(@"addPersistentStoreWithType (%@) error %@, %@",[self persistentStoreURL], error, [error userInfo]);
            
            NSError * fileError;
            
            if(![[NSFileManager defaultManager] removeItemAtURL:[self persistentStoreURL]
                                                          error:&fileError])
            {
                TMCDLog(@"ERROR DELETING STORE: %@", fileError);
            }
            else
            {
                goto readdagain;
            }
        }
        
        
        [_mainThreadContext performBlockAndWait:^{
            [_mainThreadContext reset];
        }];
        
        [_primaryContext performBlockAndWait:^{
            [_primaryContext reset];
        }];
    }
}


@end

