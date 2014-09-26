//
//  NSManagedObjectContext+TMCDSaving.h
//  TMCoreData
//
//  Created by Tony Million on 03/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (TMCDSaving)

-(void)recursiveSave;

-(void)observeChangesFromParent:(BOOL)observe;

-(void)performBlockAndSave:(void (^)(NSManagedObjectContext *context))block;
-(void)performBlockAndWaitAndSave:(void (^)(NSManagedObjectContext *context))block;


@end
