//
//  CityBus.h
//  Project_BTM
//
//  Created by user36 on 2017/5/18.
//  Copyright © 2017年 user36. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityBus : NSObject

@property (strong, nonatomic) NSString *routeUID;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSString *estimateTime;

@end
