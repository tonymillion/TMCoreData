//
//  NSManagedObject+FetchedResults.m
//  TMCoreData
//
//  Created by Tony Million on 04/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import "NSManagedObject+TMCDFetchedResults.h"

#import "NSManagedObject+TMCDFetching.h"

#import "TMCDLog.h"

@implementation NSManagedObject (TMCDFetchedResults)


+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<SSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestWithPredicate:predicate
                                                sortedBy:sortTerm
                                               ascending:ascending
                                               inContext:context];
    
    if(!request)
        return nil;
    
    SSFetchedResultsController *controller = [[SSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:groupingKeyPath
                                                                                            cacheName:nil];
    controller.safeDelegate = delegate;
    
	NSError *error = nil;
	if(![controller performFetch:&error])
	{
        TMCDLog(@"performFetch ERROR: %@", error);
	}
    
    return controller;
}

+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<SSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
                                                            batchSize:(NSUInteger)batchSize
{
    NSFetchRequest *request = [self requestWithPredicate:predicate
                                                sortedBy:sortTerm
                                               ascending:ascending
                                               inContext:context];
    
    if(!request)
        return nil;
    
    [request setFetchBatchSize:batchSize];
    
    SSFetchedResultsController *controller = [[SSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:groupingKeyPath
                                                                                            cacheName:nil];
    controller.safeDelegate = delegate;
    
	NSError *error = nil;
	if(![controller performFetch:&error])
	{
        TMCDLog(@"performFetch ERROR: %@", error);
	}
    
    return controller;
}


+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<SSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
                                                            batchSize:(NSUInteger)batchSize
                                                            cacheName:(NSString*)cachename

{
    NSFetchRequest *request = [self requestWithPredicate:predicate
                                                sortedBy:sortTerm
                                               ascending:ascending
                                               inContext:context];
    
    if(!request)
        return nil;
    
    [request setFetchBatchSize:batchSize];
    
    SSFetchedResultsController *controller = [[SSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:groupingKeyPath
                                                                                            cacheName:cachename];
    controller.safeDelegate = delegate;

	NSError *error = nil;
	if(![controller performFetch:&error])
	{
        TMCDLog(@"performFetch ERROR: %@", error);
	}
    
    return controller;
}


+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                                limit:(NSUInteger)limit
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<SSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestWithPredicate:predicate
                                                sortedBy:sortTerm
                                               ascending:ascending
                                               inContext:context];

    if(!request)
        return nil;
    
    [request setFetchLimit:limit];
    
    SSFetchedResultsController *controller = [[SSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:groupingKeyPath
                                                                                            cacheName:nil];
    controller.delegate = delegate;
    
	NSError *error = nil;
	if(![controller performFetch:&error])
	{
        TMCDLog(@"performFetch ERROR: %@", error);
	}
    
    return controller;
}


@end
