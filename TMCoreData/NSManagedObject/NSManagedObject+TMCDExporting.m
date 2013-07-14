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

-(id)exportRelationshipWithName:(NSString*)name
{
    NSString *selectorString = [NSString stringWithFormat:@"export%@", [name tmcd_capitalizedFirstLetterString]];
    SEL selector = NSSelectorFromString(selectorString);
    if ([self respondsToSelector:selector])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        id exported = [self performSelector:selector];
#pragma clang diagnostic pop
        
        return exported;
    }
    
    return nil;
}

-(NSDictionary*)exportToDictionaryWithSet:(NSMutableSet*)objectSet includeRelationships:(BOOL)includeRelationships
{
    if(!objectSet)
    {
        objectSet = [NSMutableSet setWithCapacity:10];
    }
    else
    {
        if([objectSet containsObject:self]) {
            return nil;
        }
    }
    
    [objectSet addObject:self];

    if([self respondsToSelector:@selector(objectAsDictionary)])
    {
        NSDictionary * dict = [self performSelector:@selector(objectAsDictionary)];
        if(dict)
        {
            return dict;
        }
    }
    
    
    NSMutableArray *keys = [[[[self entity] attributesByName] allKeys] mutableCopy];
    
    //TODO: get NSEntityDescription & see if key has shouldExport = NO
    NSDictionary *attributes    = [[self entity] attributesByName];
    for(NSString * attributeName in attributes)
    {
        NSAttributeDescription * attributeDesc  = [attributes objectForKey:attributeName];
        NSString *attributeDescName             = [attributeDesc name];

        
        BOOL reallyShouldExport = YES;
        if([self respondsToSelector:@selector(shouldExport:)])
        {
            reallyShouldExport = (BOOL)[self performSelector:@selector(shouldExport:)
                                                  withObject:attributeName];
        }
        else
        {
            NSString * shouldExport                 = [attributeDesc userInfo][@"shouldExport"];
            if(shouldExport && (![shouldExport boolValue]))
                reallyShouldExport = NO;
        }
        
        // if we get a shouldExport and its NOT 1-9 Y,y,T,t (more digits are ignored)
        if(!reallyShouldExport)
        {
            [keys removeObject:attributeDescName];
        }
    }
    
    // see if the class has implemented -(id)exportProperty
    NSMutableDictionary *mdict = [[self dictionaryWithValuesForKeys:keys] mutableCopy];
    
    
    NSArray * dictkeys = [mdict allKeys];

    for (NSString * key in dictkeys) {
        NSString *selectorString = [NSString stringWithFormat:@"export%@", [key tmcd_capitalizedFirstLetterString]];
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            id exported = [self performSelector:selector];
#pragma clang diagnostic pop
            
            mdict[key] = exported;
        }
    }
    
    
    NSDictionary * dict = [[mdict dictionaryByPruningNulls] dictionaryWithDatesEncodedWithFormatter:self.defaultDateExporter];
    
    //TODO: export relationahips
    
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    if(includeRelationships)
    {
        NSDictionary* relationships = [[self entity] relationshipsByName];
        
        for(NSString* relationship in relationships)
        {
            __strong id finalvalue = nil;
            
            // first we check to see if the class has an exportRelationship method
            finalvalue = [self exportRelationshipWithName:relationship];
            
            // if not
            if(!finalvalue)
            {
                NSRelationshipDescription* description = [relationships objectForKey:relationship];


                BOOL reallyShouldExport = YES;
                if([self respondsToSelector:@selector(shouldExport:)])
                {
                    reallyShouldExport = (BOOL)[self performSelector:@selector(shouldExport:)
                                                          withObject:relationship];
                }
                else
                {
                    // check userinfo to see if we should export this relationship
                    NSString * shouldExport = [description userInfo][@"shouldExport"];
                    if(shouldExport && (![shouldExport boolValue]))
                        reallyShouldExport = NO;
                }
                
                // if we get a shouldExport and its NOT 1-9 Y,y,T,t (more digits are ignored)
                if(!reallyShouldExport)
                {
                    // if we get a shouldExport and its NOT 1-9 Y,y,T,t (more digits are ignored)
                    //if(shouldExport && (![shouldExport boolValue]))
                    //    continue;
                    continue;
                }

                
                //TODO: check if this relationship links back to our type of object and if so, skip it!
                
                
                if(description.isToMany)
                {
                    // this should output an NSArray
                    //TMCDLog(@"found to many for: %@", relationship);
                    NSSet * allObjects = [self valueForKey:relationship];
                    NSMutableArray * exportedObjects = [NSMutableArray arrayWithCapacity:allObjects.count];
                    
                    [allObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSManagedObject * manobj = obj;
                        
                        id subobj = [manobj exportToDictionaryWithSet:objectSet
                                                 includeRelationships:includeRelationships];
                        if(subobj)
                            [exportedObjects addObject:subobj];
                    }];
                    
                    finalvalue = exportedObjects;
                }
                else
                {
                    // its 1:1
                    //TMCDLog(@"1:1 relationship found!: %@", description);
                    //NSEntityDescription* destination = [description destinationEntity];
                    //TMCDLog(@"destination: %@", destination);
                    
                    //Class class = NSClassFromString([destination managedObjectClassName]);
                    
                    id relatedObject = [self valueForKey:relationship];
                    
                    finalvalue = [relatedObject exportToDictionaryWithSet:objectSet
                                                     includeRelationships:includeRelationships];
                    
                }
            }
            
            if(finalvalue)
            {
                [mutableDict setObject:finalvalue
                                forKey:relationship];
            }
        }
    }
    
    if([self respondsToSelector:@selector(finalizeExport:)])
    {
        NSString *selectorString = @"finalizeExport:";
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            [self performSelector:selector withObject:mutableDict];
#pragma clang diagnostic pop
        }
    }
    
    return mutableDict;
}

@end
