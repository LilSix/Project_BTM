//
//  CityBus.h
//  Project_BTM
//


#pragma mark - .h Files

#import <Foundation/Foundation.h>


#pragma mark - Frameworks

@import CoreData;
@import UIKit;


#pragma mark -

@interface CityBus : NSObject

@property (strong, nonatomic) NSMutableArray<NSString *> *authorityID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeID;
@property (strong, nonatomic) NSMutableArray<NSString *> *routeName;
@property (strong, nonatomic) NSMutableArray<NSString *> *departureStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *destinationStopName;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopIDGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopIDBack;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameGo;
@property (strong, nonatomic) NSMutableArray<NSString *> *stopNameBack;
@property (strong, nonatomic) NSMutableDictionary *estimateTime;
@property (strong, nonatomic) NSMutableArray *estimateTimeGo;
@property (strong, nonatomic) NSMutableArray *estimateTimeBack;

@end
