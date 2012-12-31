//
//  NSManagedObject+TMCDExporting.m
//  TMCoreData
//
//  Created by Tony Million on 04/12/2012.
//  Copyright (c) 2012 Omnityke. All rights reserved.
//

#import "NSManagedObject+TMCDExporting.h"
#import "NSDictionary+removeNull.h"
#import "NSDictionary+encodedDates.h"

#import "NSEntityDescription+TMCDPrimaryKey.h"
#import "TMCDLog.h"

#import "NSString+TMCDAdditions.h"

@implementation NSManagedObject (TMCDExporting)

-(NSDateFormatter*)defaultDateExporter
{
    static __strong NSDateFormatter * df = nil;
    
   	static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    
	return df;
}

-(NSDictionary*)exportToDictionary
{
    return [self exportToDictionaryWithSet:nil
                      includeRelationships:YES];
}

-(NSDictionary*)exportToDictionaryIncludingRelationships:(BOOL)includeRelationships
{
    return [self exportToDictionaryWithSet:nil
                      includeRelationships:includeRelationships];
}


-(NSDictionary*)exportToDictionaryWithSet:(NSMutableSet*)objectSet includeRelationships:(BOOL)includeRelationships
{
    if(!objectSet)
    {
        objectSet = [NSMutableSet setWithCapacity:10];
    }
    else
    {
        if ([objectSet containsObject:self]) {
            return nil;
        }
    }
    
    [objectSet addObject:self];
    
    NSArray *keys = [[[self entity] attributesByName] allKeys];
    NSDictionary *dict = [self dictionaryWithValuesForKeys:keys];
    dict = [[dict dictionaryByPruningNulls] dictionaryWithDatesEncodedWithFormatter:self.defaultDateExporter];
    
    //TODO: export relationahips
    
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    if(includeRelationships)
    {
        NSDictionary* relationships = [[self entity] relationshipsByName];
        
        for(NSString* relationship in relationships)
        {
            NSRelationshipDescription* description = [relationships objectForKey:relationship];
            __strong id finalvalue = nil;
            
            if(description.isToMany)
            {
                // this should output an NSArray
                TMCDLog(@"found to many for: %@", relationship);
                
                NSSet * allObjects = [self valueForKey:relationship];
                NSMutableArray * exportedObjects = [NSMutableArray arrayWithCapacity:allObjects.count];
                
                [allObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    NSManagedObject * manobj = obj;
                    
                    id subobj = [manobj exportToDictionaryWithSet:objectSet includeRelationships:includeRelationships];
                    if(subobj)
                        [exportedObjects addObject:subobj];
                }];
                
                finalvalue = exportedObjects;
            }
            else
            {
                // its 1:1
                TMCDLog(@"1:1 relationship found!");
                NSEntityDescription* destination = [description destinationEntity];
                Class class = NSClassFromString([destination managedObjectClassName]);
                
                finalvalue = [class exportToDictionaryWithSet:objectSet includeRelationships:includeRelationships];
                
            }
            
            [mutableDict setObject:finalvalue
                            forKey:relationship];
        }
    }
    
    return mutableDict;
}

@end
