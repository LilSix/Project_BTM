//
//  TaipeiSubwayData.h
//  Project_BTM
//
//  Created by user36 on 2017/6/20.
//  Copyright © 2017年 user36. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TaipeiSubwayData : NSManagedObject

@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSString *stopID;
@property (strong, nonatomic) NSString *stopName;

@end
