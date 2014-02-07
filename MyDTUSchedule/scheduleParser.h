//
//  scheduleParser.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"


@interface scheduleParser : NSObject{
    Schedule *currentSchedule;
}

@property (nonatomic, retain) NSString * class_ID;
@property (nonatomic, retain) NSString * class_Name;
@property (nonatomic, retain) NSString * course_Number;
@property (nonatomic, retain) NSString * course_Name;
@property (nonatomic, retain) NSString * facility_Id;
@property (nonatomic, retain) NSString * facility_Name;
@property (nonatomic, retain) NSString * facility_RootName;
@property (nonatomic, retain) NSString * facility_TypeName;
@property (nonatomic, retain) NSString * from_Date;
@property (nonatomic, retain) NSString * instructor_IdNumber;
@property (nonatomic, retain) NSString * instructor_Name;
@property (nonatomic, retain) NSString * thru_Date; 

@property (retain, nonatomic)  NSString *currentElement;
@property (retain, nonatomic)  NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain)  NSFetchedResultsController    *fetchedResultsController;
@property (retain, nonatomic)  NSMutableString *currentStringValue;

-(id) initWithContext: (NSManagedObjectContext *) managedObjContext;
-(BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;
-(void) emptyDataContext;
-(void) inserDatabase;
@end
