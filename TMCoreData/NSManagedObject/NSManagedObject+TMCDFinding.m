//
//  NSManagedObject+TMCDFinding.m
//  TMCoreData
//
//  Created by Tony Million on 03/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import "NSManagedObject+TMCDFinding.h"
#import "NSManagedObject+TMCDFetching.h"
#import "TMCDLog.h"

@implementation NSManagedObject (TMCDFinding)


+(NSArray *)findAllInContext:(NSManagedObjectContext *)context
{
	return [self executeFetchRequest:[self createFetchRequestInContext:context]
                           inContext:context];
}

+(NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self requestAllSortedBy:sortTerm ascending:ascending inContext:context];
	return [self executeFetchRequest:request inContext:context];
}

+(NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllWithPredicate:searchTerm inContext:context];
	return [self executeFetchRequest:request inContext:context];
}

+(NSArray *)findAllWhereProperty:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllWhere:property isEqualTo:value inContext:context];
	return [self executeFetchRequest:request inContext:context];
}


+(id)findFirstWhereProperty:(NSString *)property isEqualTo:(id)value inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self requestAllWhere:property
                                          isEqualTo:value
                                          inContext:context];
    
	return [self executeFetchRequestAndReturnFirstObject:request
                                               inContext:context];
}

+(id)findFirstSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self requestAllSortedBy:sortTerm
                                             ascending:ascending
                                             inContext:context];
    
	return [self executeFetchRequestAndReturnFirstObject:request
                                               inContext:context];
}


+(id)findFirstWithPredicate:(NSPredicate*)predicate sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestWithPredicate:predicate
                                                sortedBy:sortTerm
                                               ascending:ascending
                                               inContext:context];
    
	return [self executeFetchRequestAndReturnFirstObject:request
                                               inContext:context];
}

+(id)findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestAllWithPredicate:searchTerm inContext:context];
	return [self executeFetchRequestAndReturnFirstObject:request
                                               inContext:context];
}

@end
