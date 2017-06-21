//
//  BusDetailViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "AppDelegate.h"
#import "BusDetailViewController.h"
#import "CityBus.h"
#import "MBProgressHUD.h"
#import "CityBusData.h"


#pragma mark - Frameworks

@import SystemConfiguration;
@import Foundation;
@import UIKit;
@import CoreGraphics;
@import CoreData;


#pragma mark -

@interface BusDetailViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate,
NSURLSessionTaskDelegate, NSURLSessionDataDelegate> {
    
    
    NSURLSessionDataTask *fetchEstimateGo;
    NSURLSessionDataTask *fetchEstimateBack;
    
    NSCharacterSet *characterSet;
    NSURLSessionConfiguration *configuration;
    NSURLSession *session;
    int updateTime;
    NSTimer *timerWithEstimateTime;
}

@property (strong, nonatomic) CityBus *cityBus;
@property (weak, nonatomic) IBOutlet UITableView *tableViewBusDetailList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goBackControl;
@property (weak, nonatomic) IBOutlet UILabel *labelUpdateTime;

@end


#pragma mark -

@implementation BusDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Segue Parameter
    NSLog(@"viewDidload: %@, %@, %@", _authorityID, _routeName, _routeID);
    NSLog(@"_selectedStopUID: %@", _selectedStopUID);
    NSLog(@"[[cityBus stopIDGo] count]: %ld", [[_cityBus stopIDGo] count]);
    
    // Segmented Control
    [_goBackControl setSelectedSegmentIndex:0];
    
    // Table View
    [_tableViewBusDetailList setDataSource:self];
    [_tableViewBusDetailList setDelegate:self];
    
    // Navigationbar Title
    [[self navigationItem] setTitle:[self editStringFromHalfWidthToFullWidth:_routeName]];
    NSString *go = [NSString stringWithFormat:@"去程（%@）", _destinationStopName];
    NSString *back = [NSString stringWithFormat:@"返程（%@）", _departureStopName];
    [_goBackControl setTitle:go forSegmentAtIndex:0];
    [_goBackControl setTitle:back forSegmentAtIndex:1];
    
    // Fetch JSON Data
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [self fetchBusStopsGoWithAuthorityID:_authorityID routeID:_routeID];
    [self fetchBusStopsBackWithAuthorityID:_authorityID routeID:_routeID];
    
    if ([_authorityID isEqualToString:@"Taipei"]) {
     
        [self fetchTaipeiEstimateTimeWithrouteID:_routeID];
    } else {
    
        [self fetchNewTaipeiEstimateTimeWithrouteID:_routeID];
    }
    
    // Auto Refresh Data
    timerWithEstimateTime = [NSTimer scheduledTimerWithTimeInterval:1
                                                            repeats:YES
                                                              block:^(NSTimer *timer) {
                                                                  
                                                                  updateTime--;
                                                                  if (updateTime < 1) {
                                                                      
                                                                      [_labelUpdateTime setText:@"更新中⋯⋯"];
                                                                      updateTime = 21;
                                                                      [self updateEstimateTime];
                                                                  } else {
                                                                      
                                                                      [_labelUpdateTime setText:[NSString stringWithFormat:@"%d 秒後更新", updateTime]];
                                                                  }
                                                              }];
    [timerWithEstimateTime isValid];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [_tableViewBusDetailList reloadData];
    NSLog(@"viewWillAppear.");
}


- (void)viewDidAppear:(BOOL)animated {
    
    [_tableViewBusDetailList reloadData];
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
    NSLog(@"viewDidAppear.");
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [timerWithEstimateTime invalidate];
    NSLog(@"viewDidDisappear.");
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)updateEstimateTime {
    
    if ([_authorityID isEqualToString:@"Taipei"]) {
        
        [self fetchTaipeiEstimateTimeWithrouteID:_routeID];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [_tableViewBusDetailList reloadData];
        }];
    } else {
        
        [self fetchNewTaipeiEstimateTimeWithrouteID:_routeID];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [_tableViewBusDetailList reloadData];
        }];
    }
    
}
*/

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        
        
        _cityBus = [[CityBus alloc] init];
        [_cityBus setStopIDGo:[NSMutableArray array]];
        [_cityBus setStopIDBack:[NSMutableArray array]];
        [_cityBus setStopNameGo:[NSMutableArray array]];
        [_cityBus setStopNameBack:[NSMutableArray array]];
        [_cityBus setEstimateTimeGo:[NSMutableArray array]];
        [_cityBus setEstimateTimeBack:[NSMutableArray array]];
        [_cityBus setEstimateTime:[NSMutableDictionary dictionary]];
        
        characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
        
//        timerWithEstimateTime = [[NSTimer alloc] init];
        updateTime = 21;
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        return [[_cityBus stopNameGo] count];
    }
    
    return [[_cityBus stopNameBack] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Right Detail Cell"
                                                                     forIndexPath:indexPath];
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[_cityBus stopNameGo]
                                                                                objectAtIndex:[indexPath row]]];
        for (id key in [_cityBus stopIDGo]) {
            
            NSString *string = [[_cityBus estimateTime] objectForKey:key];
            if (string == nil) {
                
                string = @"尚未發車";
            }
            [[_cityBus estimateTimeGo] addObject:string];
        }
        [[tableViewCell textLabel] setText:cellTextLabel];
        [[tableViewCell detailTextLabel] setText:[[_cityBus estimateTimeGo] objectAtIndex:[indexPath row]]];
    } else {
        
        NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[_cityBus stopNameBack]
                                                                                objectAtIndex:[indexPath row]]];
        for (id key in [_cityBus stopIDBack]) {
            
            NSString *string = [[_cityBus estimateTime] objectForKey:key];
            if (string == nil) {
                
                string = @"尚未發車";
            }
            [[_cityBus estimateTimeBack] addObject:string];
        }
        [[tableViewCell textLabel] setText:cellTextLabel];
        [[tableViewCell detailTextLabel] setText:[[_cityBus estimateTimeBack] objectAtIndex:[indexPath row]]];
    }
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        NSString *stringWithStopID = [[_cityBus stopIDGo] objectAtIndex:[indexPath row]];
        NSString *stringWithStopName = [[_cityBus stopNameGo] objectAtIndex:[indexPath row]];
        stringWithStopName = [self editStringFromHalfWidthToFullWidth:stringWithStopName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:stringWithStopName
                                                                                 message:@"確定將此車站加入至常用車站中嗎？"
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                      style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction *action) {

                                                                        CityBusData *cityBusData;
                                                                        cityBusData = [NSEntityDescription insertNewObjectForEntityForName:@"CityBus" inManagedObjectContext:managedObjectContext];
                                                                        
                                                                        [cityBusData setAuthorityID:_authorityID];
                                                                        [cityBusData setRouteID:_routeID];
                                                                        [cityBusData setRouteName:_routeName];
                                                                        [cityBusData setStopName:stringWithStopName];
                                                                        [cityBusData setStopID:stringWithStopID];
                                                                        [cityBusData setDepartureStopName:_departureStopName];
                                                                        [cityBusData setDestinationStopName:_destinationStopName];
                                                                        
                                                                        [managedObjectContext save:nil];
                                                                        
                                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                                                        
                                                                        // Set the custom view mode to show any view.
                                                                        hud.mode = MBProgressHUDModeCustomView;
                                                                        // Set an image view with a checkmark.
                                                                        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                                                        hud.customView = [[UIImageView alloc] initWithImage:image];
                                                                        // Looks a bit nicer if we make it square.
                                                                        hud.square = YES;
                                                                        // Optional label text.
                                                                        hud.label.text = NSLocalizedString(@"完成", @"HUD done title");
                                                                        
                                                                        [hud hideAnimated:YES afterDelay:.8f];
                                                                    }];
        UIAlertAction *alertActionWithCancel = [UIAlertAction actionWithTitle:@"取消"
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:nil];
        [alertController addAction:alertActionWithDone];
        [alertController addAction:alertActionWithCancel];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        NSString *stringWithStopID = [[_cityBus stopIDBack] objectAtIndex:[indexPath row]];
        NSString *stringWithStopName = [[_cityBus stopNameBack] objectAtIndex:[indexPath row]];
        stringWithStopName = [self editStringFromHalfWidthToFullWidth:stringWithStopName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:stringWithStopName
                                                                                 message:@"確定將此車站加入至常用車站中嗎？"
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                      style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction *action) {
                                                                        
                                                                        CityBusData *cityBusData;
                                                                        cityBusData = [NSEntityDescription insertNewObjectForEntityForName:@"CityBus" inManagedObjectContext:managedObjectContext];
                                                                        
                                                                        [cityBusData setRouteID:_routeID];
                                                                        [cityBusData setRouteName:_routeName];
                                                                        [cityBusData setStopName:stringWithStopName];
                                                                        [cityBusData setStopID:stringWithStopID];
                                                                        
                                                                        [managedObjectContext save:nil];
                                                                        
                                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                                                        
                                                                        // Set the custom view mode to show any view.
                                                                        hud.mode = MBProgressHUDModeCustomView;
                                                                        // Set an image view with a checkmark.
                                                                        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                                                        hud.customView = [[UIImageView alloc] initWithImage:image];
                                                                        // Looks a bit nicer if we make it square.
                                                                        hud.square = YES;
                                                                        // Optional label text.
                                                                        hud.label.text = NSLocalizedString(@"完成", @"HUD done title");
                                                                        
                                                                        [hud hideAnimated:YES afterDelay:.8f];
                                                                    }];
        UIAlertAction *alertActionWithCancel = [UIAlertAction actionWithTitle:@"取消"
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:nil];
        [alertController addAction:alertActionWithDone];
        [alertController addAction:alertActionWithCancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    

}


#pragma mark - IBACtion

- (IBAction)segmentedControlGoBackTouch:(UISegmentedControl *)sender {
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        [_tableViewBusDetailList reloadData];
    } else {
        
        [_tableViewBusDetailList reloadData];
    }
}

- (IBAction)barButtonItemRefreshTouch:(UIBarButtonItem *)sender {
    
    [[_cityBus stopNameGo] removeAllObjects];
    [[_cityBus stopNameBack] removeAllObjects];
    [[_cityBus stopIDGo] removeAllObjects];
    [[_cityBus stopIDBack] removeAllObjects];
    [[_cityBus estimateTime] removeAllObjects];
    [[_cityBus estimateTimeGo] removeAllObjects];
    [[_cityBus estimateTimeBack] removeAllObjects];
    
    //    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [self fetchBusStopsGoWithAuthorityID:_authorityID routeID:_routeID];
    [self fetchBusStopsBackWithAuthorityID:_authorityID routeID:_routeID];
    
    if ([_authorityID isEqualToString:@"Taipei"]) {
        
        [self fetchTaipeiEstimateTimeWithrouteID:_routeID];
    } else {
        
        [self fetchNewTaipeiEstimateTimeWithrouteID:_routeID];
    }
    [_tableViewBusDetailList reloadData];
}


#pragma mark - Half-WidthToFull-Width

- (NSString *)editStringFromHalfWidthToFullWidth:(NSString *)string {
    
    for (int i = 0; i <= [string length]; i++) {
        
        string = [string stringByReplacingOccurrencesOfString:@"("
                                                   withString:@"（"];
        string = [string stringByReplacingOccurrencesOfString:@")"
                                                   withString:@"）"];
        string = [string stringByReplacingOccurrencesOfString:@"-"
                                                   withString:@"－"];
        string = [string stringByReplacingOccurrencesOfString:@"–"
                                                   withString:@"－"];
        string = [string stringByReplacingOccurrencesOfString:@"/"
                                                   withString:@"／"];
        string = [string stringByReplacingOccurrencesOfString:@"~"
                                                   withString:@"～"];
    }
    
    return string;
}




#pragma mark - FetchData

- (void)fetchBusStopsGoWithAuthorityID:(NSString *)authorityID
                               routeID:(NSString *)routeID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteID eq '%@' and KeyPattern eq true and Direction eq '0'&$format=JSON", authorityID, routeID];
    NSLog(@"fetchBusStopsGo URL: %@", stringWithURL);
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                NSLog(@"fetchBusStopsGo Thread: %@", [NSThread currentThread]);
                                                if (!error) {
                                                    
                                                    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&error];
                                                    
                                                    for (id object in array) {
                                                        
                                                        NSArray *stops = [object objectForKey:@"Stops"];
                                                        for (id objectInStops in stops) {
                                                            
                                                            NSString *stopID = [objectInStops objectForKey:@"StopID"];
                                                            NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
                                                            NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                                                            
                                                            [[_cityBus stopIDGo] addObject:stopID];
                                                            [[_cityBus stopNameGo] addObject:nameZhTW];
                                                        }
                                                    }
                                                }
                                            }];
    [dataTask resume];
}

- (void)fetchBusStopsBackWithAuthorityID:(NSString *)authorityID
                                 routeID:(NSString *)routeID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteID eq '%@' and KeyPattern eq true and Direction eq '1'&$format=JSON", authorityID, routeID];
    NSLog(@"fetchBusStopsBack URL: %@", stringWithURL);
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                NSLog(@"fetchBusStopsBack Thread: %@", [NSThread currentThread]);
                                                if (!error) {
                                                    
                                                    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                       error:&error];
                                                    
                                                    for (id object in array) {
                                                        
                                                        NSArray *stops = [object objectForKey:@"Stops"];
                                                        for (id objectInStops in stops) {
                                                            
                                                            NSString *stopID = [objectInStops objectForKey:@"StopID"];
                                                            NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
                                                            NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                                                            
                                                            [[_cityBus stopIDBack] addObject:stopID];
                                                            [[_cityBus stopNameBack] addObject:nameZhTW];
                                                        }
                                                    }
                                                }
                                            }];
    [dataTask resume];
}

- (void)fetchTaipeiEstimateTimeWithrouteID:(NSString *)routeID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/Taipei?$filter=RouteID eq '%@'&$format=JSON", routeID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSLog(@"fetchTaipeiEstimateTime URL: %@", stringWithURL);
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                NSLog(@"fetchTaipeiEstimateTime Thread: %@", [NSThread currentThread]);
                                                NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                   error:&error];
                                                
                                                for (id object in array) {
                                                    
                                                    NSString *stopID = [object objectForKey:@"StopID"];
                                                    NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
                                                    NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
                                                    NSString *stringWithTime;
                                                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                                                    if (estimateTime != nil) {
                                                        
                                                        int minutes = [estimateTime intValue] / 60;
                                                        int seconds = [estimateTime intValue] % 60;;
                                                        if ([estimateTime intValue] <= 30) {
                                                            
                                                            stringWithTime = @"進站中";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else if ([estimateTime intValue] <= 90) {
                                                            
                                                            stringWithTime = @"即將進站";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else {
                                                            
                                                            if (seconds <= 40) {
                                                                
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            } else {
                                                                
                                                                minutes++;
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            }
                                                        }
                                                    } else if ([stopStatus isEqualToNumber:@1]) {
                                                        
                                                        stringWithTime = @"尚未發車";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else if ([stopStatus isEqualToNumber:@2]) {
                                                        
                                                        stringWithTime = @"交管不停靠";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else if ([stopStatus isEqualToNumber:@3]) {
                                                        
                                                        stringWithTime = @"末班車已過";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else if ([stopStatus isEqualToNumber:@4]) {
                                                        
                                                        stringWithTime = @"今日未營運";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else {
                                                        
                                                        stringWithTime = @"尚未發車";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    }
                                                    
                                                    [[_cityBus estimateTime] addEntriesFromDictionary:dictionary];
                                                }
                                            }];
    [dataTask resume];
}

- (void)fetchNewTaipeiEstimateTimeWithrouteID:(NSString *)routeID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://data.ntpc.gov.tw/od/data/api/245793DB-0958-4C10-8D63-E7FA0D39207C?$format=json&$filter=RouteID eq %@", routeID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSLog(@"fetchNewTaipeiEstimateTime URL: %@", stringWithURL);
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                
                                                NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                   error:&error];
                                                NSLog(@"fetchNewTaipeiEstimateTime Thread: %@", [NSThread currentThread]);
                                                for (id object in array) {
                                                    
                                                    NSString *stopID = [object objectForKey:@"StopID"];
                                                    NSString *estimateTime = [object objectForKey:@"EstimateTime"];
                                                    NSString *goBack = [object objectForKey:@"GoBack"];
                                                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                                                    NSString *stringWithTime;
                                                    
                                                    int minutes = [estimateTime intValue] / 60;
                                                    int seconds = [estimateTime intValue] % 60;;
                                                    
                                                    if ([goBack isEqualToString:@"0"]) {
                                                        
                                                        if ([estimateTime intValue] <= 30) {
                                                            
                                                            stringWithTime = @"進站中";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else if ([estimateTime intValue] <= 90) {
                                                            
                                                            stringWithTime = @"即將進站";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else {
                                                            
                                                            if (seconds <= 40) {
                                                                
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            } else {
                                                                
                                                                minutes++;
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            }
                                                        }
                                                    } else if ([goBack isEqualToString:@"1"]) {
                                                        
                                                        if ([estimateTime intValue] <= 30) {
                                                            
                                                            stringWithTime = @"進站中";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else if ([estimateTime intValue] <= 90) {
                                                            
                                                            stringWithTime = @"即將進站";
                                                            [dictionary setObject:stringWithTime forKey:stopID];
                                                        } else {
                                                            
                                                            if (seconds <= 40) {
                                                                
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            } else {
                                                                
                                                                minutes++;
                                                                stringWithTime = [NSString stringWithFormat:@"約 %d 分", minutes];
                                                                [dictionary setObject:stringWithTime forKey:stopID];
                                                            }
                                                        }
                                                    } else if ([goBack isEqualToString:@"2"]) {
                                                        
                                                        stringWithTime = @"尚未發車";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else if ([goBack isEqualToString:@"3"]) {
                                                        
                                                        stringWithTime = @"末班車已過";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    } else {
                                                        
                                                        stringWithTime = @"今日未營運";
                                                        [dictionary setObject:stringWithTime forKey:stopID];
                                                    }
                                                    
                                                    [[_cityBus estimateTime] addEntriesFromDictionary:dictionary];
                                                }
                                            }];
    [dataTask resume];
}


#pragma mark - UpdateEstimateTime

- (void)updateEstimateTime {
    
    [[_cityBus estimateTimeGo] removeAllObjects];
    [[_cityBus estimateTimeBack] removeAllObjects];
    
    if ([_authorityID isEqualToString:@"Taipei"]) {
        
        [self fetchTaipeiEstimateTimeWithrouteID:_routeID];
    } else {
        
        [self fetchNewTaipeiEstimateTimeWithrouteID:_routeID];
    }
    [_tableViewBusDetailList reloadData];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
