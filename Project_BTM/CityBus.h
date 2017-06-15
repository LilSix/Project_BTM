//
//  CityBus.h
//  Project_BTM
//

#import <Foundation/Foundation.h>

@interface CityBus : NSObject


@property (strong, nonatomic) NSString *selectedRouteUID;
@property (strong, nonatomic) NSString *selectedStopUID;

@property (strong, nonatomic) NSMutableArray<NSString *> *authorityID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeUID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeName;
@property (strong, nonatomic) NSMutableArray<NSString *> *keyPattern;
@property (strong, nonatomic) NSMutableArray<NSString *> *departureStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *destinationStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopUIDGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopIDGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopUIDBack;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopIDBack;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameBack;
@property (strong, nonatomic) NSMutableDictionary *estimateTime;
@property (strong, nonatomic) NSMutableArray *estimateTimeGo;
@property (strong, nonatomic) NSMutableArray *estimateTimeBack;
@property (strong, nonatomic) NSMutableArray *stopStatus;

@end
