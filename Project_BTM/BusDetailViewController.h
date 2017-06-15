//
//  BusDetailViewController.h
//  Project_BTM
//


#import <UIKit/UIKit.h>

@interface BusDetailViewController : UIViewController

@property (strong, nonatomic) NSString *authorityID;
@property (strong, nonatomic) NSString *routeID;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSString *departureStopName;
@property (strong, nonatomic) NSString *destinationStopName;

@property (strong, nonatomic) NSString *selectedStopUID;

@end
