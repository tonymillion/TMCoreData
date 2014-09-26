//
//  NSManagedObjectContext+TMCDSaving.m
//  TMCoreData
//
//  Created by Tony Million on 03/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import "NSManagedObjectContext+TMCDSaving.h"

#import "TMCDLog.h"


@implementation NSManagedObjectContext (TMCDSaving)



#pragma mark - Saving Helpers
-(BOOL)save
{
    __block BOOL result = YES;

    [self performBlockAndWait:^{
        NSError* error = nil;

        if(![self save:&error])
        {

#ifdef DEBUG
            //ERROR
            TMCDLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    TMCDLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                TMCDLog(@"  %@", [error userInfo]);
            }
#endif

            result = NO;
        }

    }];

    return result;
}

-(void)recursiveSave
{
    [self performBlockAndWait:^{

        if([self hasChanges])
        {
            if(![self save])
            {
                //An error happened :(
            }
            else
            {
                if(self.parentContext)
                {
                    [self.parentContext recursiveSave];
                }
            }
        }
    }];
}

#pragma mark - update helpers

-(void)performBlockAndSave:(void (^)(NSManagedObjectContext *context))block
{
    __block UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }];

    [self performBlock:^{
        block(self);
        [self recursiveSave];

        [[UIApplication sharedApplication] endBackgroundTask:taskID];

    }];
}

-(void)performBlockAndWaitAndSave:(void (^)(NSManagedObjectContext *context))block
{
    __block UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }];

    [self performBlockAndWait:^{
        block(self);
        [self recursiveSave];

        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }];
}

#pragma mark - changes helpers

-(void)observeChangesFromParent:(BOOL)observe
{
    if(observe)
    {
        // This will pull down changes made into the primary context into our UI context.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.parentContext];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)contextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext * notificationContext = notification.object;

    if(notificationContext == self)
    {
        // we dont need to run on ourselves
        return;
    }

    // only do this if the notification came from our direct parent please
    // we need this as if you have more than one ADCoreDataStack instance it will
    // seriously mess up trying to import from another store!
    if( notification.object == self.parentContext )
    {
        [self performBlock:^{
            //CDLog(@"Merging changes from parent: %@", notification);
            [self mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}



@end
