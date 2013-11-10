//
//  NSManagedObject+TMCDFetchedResults.h
//  TMCoreData
//
//  Created by Tony Million on 04/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SSFetchedResultsController.h"

@interface NSManagedObject (TMCDFetchedResults)

+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context;

+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
                                                            batchSize:(NSUInteger)batchSize;

+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context
                                                            batchSize:(NSUInteger)batchSize
                                                            cacheName:(NSString*)cachename;

+(SSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
                                                                limit:(NSUInteger)limit
                                                             sortedBy:(NSString *)sortTerm
                                                            ascending:(BOOL)ascending
                                                              groupBy:(NSString *)groupingKeyPath
                                                             delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                                            inContext:(NSManagedObjectContext *)context;

@end
