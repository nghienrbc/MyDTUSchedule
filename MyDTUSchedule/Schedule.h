//
//  Schedule.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/16/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Schedule : NSManagedObject

@property (nonatomic, retain) NSString * class_ID;
@property (nonatomic, retain) NSString * class_Name;
@property (nonatomic, retain) NSString * course_Name;
@property (nonatomic, retain) NSString * course_Number;
@property (nonatomic, retain) NSString * facility_Id;
@property (nonatomic, retain) NSString * facility_Name;
@property (nonatomic, retain) NSString * facility_RootName;
@property (nonatomic, retain) NSString * facility_TypeName;
@property (nonatomic, retain) NSString * from_Date;
@property (nonatomic, retain) NSString * instructor_IdNumber;
@property (nonatomic, retain) NSString * instructor_Name;
@property (nonatomic, retain) NSString * thru_Date;

@end
