//
//  CityBus.h
//  Project_BTM
//

#import <Foundation/Foundation.h>

@interface CityBus : NSObject

@property (strong, nonatomic) NSMutableArray<NSString *> *authorityID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeUID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeName;
@property (strong, nonatomic) NSMutableArray<NSString *> *keyPattern;
@property (strong, nonatomic) NSMutableArray<NSString *> *departureStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *destinationStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopUID;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameBack;
@property (strong, nonatomic) NSMutableArray<NSString *> *estimateTimeGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *estimateTimeBack;
@property (strong, nonatomic) NSMutableArray *stopStatus;

@end
