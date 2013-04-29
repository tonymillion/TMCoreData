//
//  TMCoreData.h
//  TMCoreData
//
//  Created by Tony Million on 02/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSManagedObjectContext+TMCDSaving.h"

#import "NSManagedObject+TMCDCreation.h"
#import "NSManagedObject+TMCDFetching.h"

#import "NSManagedObject+TMCDFinding.h"
#import "NSManagedObject+TMCDFetchedResults.h"

#import "NSManagedObject+TMCDDeleting.h"

#import "NSManagedObject+TMCDExporting.h"
#import "NSManagedObject+TMCDImporting.h"

extern NSString *const kTMCoreDataiCloudIsAvailableNotification;


@interface TMCoreData : NSObject

@property(readonly, nonatomic) NSManagedObjectContext       *primaryContext;
@property(readonly, nonatomic) NSManagedObjectContext       *mainThreadContext;

+(NSURL *)persistentStoreURLForStoreNamed:(NSString *)name;

-(id)initWithLocalStoreNamed:(NSString*)name;
-(id)initWithLocalStoreNamed:(NSString*)localStore objectModel:(NSManagedObjectModel*)objectModel;
-(id)initWithLocalStoreURL:(NSURL*)localStoreURL objectModel:(NSManagedObjectModel*)objectModel;

-(id)initWithiCloudContainer:(NSString *)iCloudEnabledAppID
             localStoreNamed:(NSString *)localStore
                 objectModel:(NSManagedObjectModel*)objectModel
           icloudActiveBlock:(void(^)(void))iCloudActiveBlock;

-(id)initWithiCloudContainer:(NSString *)iCloudEnabledAppID
               localStoreURL:(NSURL *)localStoreURL
                 objectModel:(NSManagedObjectModel*)objectModel
           icloudActiveBlock:(void(^)(void))iCloudActiveBlock;

-(NSManagedObjectContext*)scratchContext;

-(void)saveOnMainThreadWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
-(void)saveOnMainThreadWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(void(^)(void))completion;

-(void)saveInBackgroundWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
-(void)saveInBackgroundWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(void(^)(void))completion;


-(void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
-(void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(void(^)(void))completion;


-(void)resetPersistentStore;

@end
