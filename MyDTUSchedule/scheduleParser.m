//
//  scheduleParser.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "scheduleParser.h"

@implementation scheduleParser

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize currentElement;
@synthesize currentStringValue;

@synthesize class_ID;
@synthesize class_Name;
@synthesize course_Number;
@synthesize course_Name;
@synthesize facility_Id;
@synthesize facility_Name;
@synthesize facility_RootName;
@synthesize facility_TypeName;
@synthesize from_Date;
@synthesize instructor_IdNumber;
@synthesize instructor_Name;
@synthesize thru_Date; 

-(id) initWithContext: (NSManagedObjectContext *) managedObjContext
{
	self = [super init];
	[self setManagedObjectContext:managedObjContext];
    
    return self;
}

-(NSFetchedResultsController *) fetchedResult : (NSString *)entityName : (NSString *) sortby {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortby ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    return self.fetchedResultsController;
}

- (BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{
	BOOL result = YES;  
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		result = NO;
    }
	return result;
}

-(void) emptyDataContext
{
	// Get all counties, It's the top level object and the reference cascade deletion downward
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"class_Name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *mularray = [[NSMutableArray alloc]initWithArray:results];
    for (int i = 0; i < [mularray count]; i++) {
		[managedObjectContext deleteObject:[mularray objectAtIndex:i]];
		
	}
	if (![managedObjectContext save:&error]) {
		NSLog(@"%@", [error domain]);
	}
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
        
    }
    if ([elementName isEqualToString:@"diffgr:diffgram"]){
        [self emptyDataContext];
        return;
    }
	currentElement = elementName;
    if ([elementName isEqualToString:@"tblLich"]) 
	{
        if(class_ID)
        {            
        }
        return;
    }
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }    
	if ([elementName isEqualToString:@"tblLich"]) 
	{
		//if(currentFacility != nil)
		//{
			NSError *error;			
			if (![managedObjectContext save:&error]) {
				
				NSLog(@"%@", [error domain]);
			}
		//}        
        [self inserDatabase];        
        currentStringValue = nil;
    }
    currentStringValue = nil;
    currentElement = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if ([currentElement isEqualToString:@"CLASS_ID"]) {
        class_ID = string;
    }
    else if ([currentElement isEqualToString:@"COURSE_NUMBER"]) {
        
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            course_Number = [NSString stringWithString:currentStringValue];
            course_Number = string;
        }
        else {
            [currentStringValue appendString:string];
            course_Number = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    }  
    
    else if ([currentElement isEqualToString:@"COURSE_NAME"]) {
        
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            course_Name = [NSString stringWithString:currentStringValue];
            course_Name = string;
        }
        else {
            [currentStringValue appendString:string];
            course_Name = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    }  
    
    else if ([currentElement isEqualToString:@"CLASS_NAME"]) {
        
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            class_Name = [NSString stringWithString:currentStringValue];
            class_Name = string;
        }
        else {
            [currentStringValue appendString:string];
            class_Name = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    }  
    
    else if ([currentElement isEqualToString:@"FROM_DATE"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            from_Date = [NSString stringWithString:currentStringValue];
            from_Date = string;
        }
        else {
            [currentStringValue appendString:string];
            from_Date = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"THRU_DATE"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            thru_Date = [NSString stringWithString:currentStringValue];
            thru_Date = string;
        }
        else {
            [currentStringValue appendString:string];
            thru_Date = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"FACILITY_ID"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            facility_Id = [NSString stringWithString:currentStringValue];
            facility_Id = string;
        }
        else {
            [currentStringValue appendString:string];
            facility_Id = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"FACILITY_NAME"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            facility_Name = [NSString stringWithString:currentStringValue];
            facility_Name = string;
        }
        else {
            [currentStringValue appendString:string];
            facility_Name = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"FACILITY_TYPE_NAME"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            facility_TypeName = [NSString stringWithString:currentStringValue];
            facility_TypeName = string;
        }
        else {
            [currentStringValue appendString:string];
            facility_TypeName = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"FACILITY_ROOT_NAME"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            facility_RootName = [NSString stringWithString:currentStringValue];
            facility_RootName = string;
        }
        else {
            [currentStringValue appendString:string];
            facility_RootName = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"INSTRUCTOR_ID_NUMBER"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            instructor_IdNumber = [NSString stringWithString:currentStringValue];
            instructor_IdNumber = string;
        }
        else {
            [currentStringValue appendString:string];
            instructor_IdNumber = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    } 
    
    else if ([currentElement isEqualToString:@"INSTRUCTOR_NAME"]) { 
        if (!currentStringValue) {
            currentStringValue = [NSMutableString string];
            [currentStringValue appendString:string];
            instructor_Name = [NSString stringWithString:currentStringValue];
            instructor_Name = string;
        }
        else {
            [currentStringValue appendString:string];
            instructor_Name = [NSString stringWithString:currentStringValue];            
            currentStringValue = nil;
            
        }
    }   
	// Insert new user to Account table.
}

- (void) inserDatabase {
    [self fetchedResult:@"Schedule" :@"class_Name"];        
    NSError *error = nil;
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"class_Name  contains[cd] 1"];
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    currentSchedule = (Schedule *)[NSEntityDescription insertNewObjectForEntityForName:@"Schedule" inManagedObjectContext:managedObjectContext];    
    [currentSchedule setClass_ID:class_ID];
    [currentSchedule setClass_Name:class_Name];
    [currentSchedule setCourse_Number:course_Number];
    [currentSchedule setCourse_Name:course_Name];
    [currentSchedule setFacility_Id:facility_Id];
    [currentSchedule setFacility_Name:facility_Name];
    [currentSchedule setFacility_RootName:facility_RootName];
    [currentSchedule setFacility_TypeName:facility_TypeName];
    [currentSchedule setFrom_Date:from_Date];
    [currentSchedule setInstructor_IdNumber:instructor_IdNumber];
    [currentSchedule setInstructor_Name:instructor_Name];
    [currentSchedule setThru_Date:thru_Date];
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"Saved data to Details");
    }
    
}
@end
