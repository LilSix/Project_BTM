//
//  CityBus.h
//  Project_BTM
//

#import <Foundation/Foundation.h>

@interface CityBus : NSObject

@property (strong, nonatomic) NSString *routeUID;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSString *estimateTime;

@end
