//
//  CityBusData.h
//  Project_BTM
//

#import <CoreData/CoreData.h>

@import UIKit;

@interface CityBusData : NSManagedObject

@property (strong, nonatomic) NSString *routeID;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSString *stopID;
@property (strong, nonatomic) NSString *stopName;

@end
