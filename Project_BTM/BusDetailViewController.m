//
//  BusDetailViewController.m
//  Project_BTM
//


#pragma mark .h files

#import "BusDetailViewController.h"
#import "CityBus.h"
#import "MBProgressHUD.h"


#pragma mark Frameworks

@import SystemConfiguration;
@import Foundation;
@import UIKit;
@import CoreGraphics;


#pragma mark -

@interface BusDetailViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate,
NSURLSessionDownloadDelegate> {
    
    CityBus *cityBus;
    NSURLSessionDownloadTask *downloadTaskWithBusStops;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewBusDetailList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goBackControl;

@end


#pragma mark -

@implementation BusDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidload: %@, %@, %@", _authorityID, _routeName, _routeUID);
    NSLog(@"_selectedStopUID: %@", _selectedStopUID);
    NSLog(@"[[cityBus stopUIDGo] count]: %ld", [[cityBus stopUIDGo] count]);
    
    [_goBackControl setSelectedSegmentIndex:0];
    [_tableViewBusDetailList setDataSource:self];
    
    [[self navigationItem] setTitle:[self editStringFromHalfWidthToFullWidth:_routeName]];
    NSString *go = [NSString stringWithFormat:@"去程（%@）", _destinationStopName];
    NSString *back = [NSString stringWithFormat:@"返程（%@）", _departureStopName];
    
    [_goBackControl setTitle:go forSegmentAtIndex:0];
    [_goBackControl setTitle:back forSegmentAtIndex:1];
    
    [self fetchBusStopsWithAuthorityID:_authorityID
                             routeName:_routeName
                              routeUID:_routeUID];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    NSLog(@"viewDidDisappear.");
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        cityBus = [[CityBus alloc] init];
        [cityBus setStopUIDGo:[NSMutableArray array]];
        [cityBus setStopUIDBack:[NSMutableArray array]];
        [cityBus setStopNameGo:[NSMutableArray array]];
        [cityBus setStopNameBack:[NSMutableArray array]];
        [cityBus setStopStatus:[NSMutableArray array]];
        [cityBus setKeyPattern:[NSMutableArray array]];
        [cityBus setEstimateTimeGo:[NSMutableArray array]];
        [cityBus setEstimateTimeBack:[NSMutableArray array]];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        return [[cityBus stopNameGo] count];
    }
    
    return [[cityBus stopNameBack] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Right Detail"
                                                                     forIndexPath:indexPath];
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[cityBus stopNameGo]
                                                                            objectAtIndex:[indexPath row]]];
        [[tableViewCell textLabel] setText:cellTextLabel];
        [[tableViewCell detailTextLabel] setText:[[cityBus estimateTimeGo] objectAtIndex:[indexPath row]]];
        
        return tableViewCell;
    }
    
    NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[cityBus stopNameBack]
                                                                        objectAtIndex:[indexPath row]]];
    [[tableViewCell textLabel] setText:cellTextLabel];
    [[tableViewCell detailTextLabel] setText:[[cityBus estimateTimeBack] objectAtIndex:[indexPath row]]];
    
    return tableViewCell;
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    
    
    @try {
        
        NSLog(@"Thread: %@", [NSThread currentThread]);
        
        NSLog(@"downloadTask: %@", downloadTask);
        
        // /v2/Bus/EstimatedTimeOfArrival/City/{City}/{RouteName}   取得指定[縣市],[路線名稱]的公車預估到站資料(N1)
        // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_EstimatedTimeOfArrival_0
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        for (NSDictionary *dictionary in array) {
            //            NSLog(@"%@", dictionary);
            //            NSNumber *isKeyPattern = [dictionary objectForKey:@"KeyPattern"];
            NSNumber *direction = [dictionary objectForKey:@"Direction"];
            
            
            //            NSBlockOperation *operationBack = [[NSBlockOperation alloc] init];
            //            NSBlockOperation *operationGo = [[NSBlockOperation alloc] init];
            //            NSBlockOperation *operationBack = [[NSBlockOperation alloc] init];
            //            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            //            [queue addOperationWithBlock:^{
            //            [operationGo addExecutionBlock:^{
            //                if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@0]) {
            if ([direction isEqualToNumber:@0]) {
                NSArray *stops = [dictionary objectForKey:@"Stops"];
                for (NSDictionary *dictionary in stops) {
                    
                    NSString *stopUID = [dictionary objectForKey:@"StopUID"];
                    NSString *stringWithTime = [self fetchEstimateTimeWithAuthorityID:_authorityID
                                                                            routeName:_routeName
                                                                             routeUID:_routeUID
                                                                              stopUID:stopUID];
                    NSDictionary *stopName = [dictionary objectForKey:@"StopName"];
                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                    [[cityBus stopNameGo] addObject:nameZhTW];
                    [[cityBus stopUIDGo] addObject:stopUID];
                    [[cityBus estimateTimeGo] addObject:stringWithTime];
                }
            }
            //            }];
            
            
            
            //            [queue addOperationWithBlock:^{
            //            [operationBack addExecutionBlock:^{
            
            //                if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@1]) {
            if ([direction isEqualToNumber:@1]) {
                NSArray *stops = [dictionary objectForKey:@"Stops"];
                for (NSDictionary *dictionary in stops) {
                    
                    NSString *stopUID = [dictionary objectForKey:@"StopUID"];
                    NSString *stringWithTime = [self fetchEstimateTimeWithAuthorityID:_authorityID
                                                                            routeName:_routeName
                                                                             routeUID:_routeUID
                                                                              stopUID:stopUID];
                    NSDictionary *stopName = [dictionary objectForKey:@"StopName"];
                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                    [[cityBus stopNameBack] addObject:nameZhTW];
                    [[cityBus stopUIDBack] addObject:stopUID];
                    [[cityBus estimateTimeBack] addObject:stringWithTime];
                }
            }
            //            }];
            
            
            //            [operationGo start];
            //            [operationBack start];
            //            [operation waitUntilFinished];
            
            //            [queue waitUntilAllOperationsAreFinished];
            
            //            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            //            [queue addOperations:@[operationGo, operationBack] waitUntilFinished:Y ES];
            
            
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"[%@]: %@", [exception name], [exception reason]);
    } @finally {
        
        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        
        NSLog(@"Download compelete.");
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [_tableViewBusDetailList reloadData];
        [MBProgressHUD hideHUDForView:[self view] animated:YES];
    }];
}


#pragma mark - FetchData

- (void)fetchBusStopsWithAuthorityID:(NSString *)authorityID
                           routeName:(NSString *)routeName
                            routeUID:(NSString *)routeUID {
    
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    [operation addExecutionBlock:^{

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue currentQueue]];
    
    
        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        
        // /v2/Bus/StopOfRoute/City/{City}/{RouteName}   取得指定[縣市],[路線名稱]的市區公車路線與站牌資料
        // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_StopOfRoute_0
        
        
        NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$filter=RouteUID eq '%@' and KeyPattern eq true&$format=JSON",authorityID, routeName, routeUID];
        NSLog(@"URL: %@", stringWithURL);
        stringWithURL = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        
        //    NSString *stringWithEstimate = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@'&$format=JSON"];
        
        downloadTaskWithBusStops = [session downloadTaskWithURL:URL];
        
        
        if (![[cityBus selectedRouteUID] isEqualToString:_routeUID]) {
            
            [cityBus setSelectedRouteUID: _routeUID];
            [downloadTaskWithBusStops resume];
            NSLog(@"downloadTaskWithBusStops: %@", downloadTaskWithBusStops);
            NSLog(@"[cityBus selectedStopUID]: %@", [cityBus selectedStopUID]);
            NSLog(@"Download JSON data...");
            
            NSLog(@"Operation in %@ thread.", [NSThread currentThread]);
        }
    }];
    [queue addOperation:operation];
    
    
    
//    else {
//        
//        ///FIXME: Don't download data again after enter same selection of view.
//        ///FIXME: Bus stops data don't download again just update bus estimate time.
//        for (int i = 0; i < [[cityBus stopUIDGo] count]; i++) {
//            
//            NSString *stopUID = [[cityBus stopUIDGo] objectAtIndex:i];
//            [[cityBus stopUIDGo] removeAllObjects];
//            [[cityBus stopUIDGo] addObject:[self fetchEstimateTimeWithAuthorityID:_authorityID
//                                                                        routeName:_routeName
//                                                                         routeUID:_routeUID
//                                                                          stopUID:stopUID]];
//        }
//        
//        for (int i = 0; i < [[cityBus stopUIDBack] count]; i++) {
//            
//            NSString *stopUID = [[cityBus stopUIDBack] objectAtIndex:i];
//            [[cityBus stopUIDBack] removeAllObjects];
//            [[cityBus stopUIDBack] addObject:[self fetchEstimateTimeWithAuthorityID:_authorityID
//                                                                          routeName:_routeName
//                                                                           routeUID:_routeUID
//                                                                            stopUID:stopUID]];
//        }
//        
//        NSLog(@"Update bus estimate time.");
//        [_tableViewBusDetailList reloadData];
//    }
}

///FIXME: SUPER SLOW!!! SOMETIME CAN'T FETCH THE FXXKING TIME!!!
- (NSString *)fetchEstimateTimeWithAuthorityID:(NSString *)authorityID
                                     routeName:(NSString *)routeName
                                      routeUID:(NSString *)routeID
                                       stopUID:(NSString *)stopUID {
    
    NSString *time;
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@' and StopUID eq '%@'&$format=JSON", authorityID, routeName, routeID, stopUID];
    NSLog(@"fetchEstimateTime URL: %@", stringWithURL);
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    stringWithURL = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:stringWithURL];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    
    if (!array) {
        
        time = @"尚未發車";
        
        return time;
    }
    
    for (NSDictionary *dictionary in array) {
        
        NSNumber *estimateTime = [dictionary objectForKey:@"EstimateTime"];
        NSNumber *stopStatus = [dictionary objectForKey:@"StopStatus"];
        if (estimateTime != nil) {
            
            int intTime = [estimateTime intValue];
            int minutes = intTime / 60;
            int seconds = intTime % 60;
            if (minutes < 1) {
                
                time = @"進站中";
                
                return time;
            } else if (minutes >= 1 && minutes <= 2) {
                
                time = @"即將進站";
                
                return time;
            }
            
            if (seconds < 30) {
                
                NSNumber *numberMinutes = [NSNumber numberWithInt:minutes];
                NSString *string = [numberMinutes stringValue];
                NSString *stringEstimateTime = [NSString stringWithFormat:@"約 %@ 分", string];
                time = stringEstimateTime;
            } else {
                
                NSNumber *numberMinutes = [NSNumber numberWithInt:minutes + 1];
                NSString *string = [numberMinutes stringValue];
                NSString *stringEstimateTime = [NSString stringWithFormat:@"約 %@ 分", string];
                time = stringEstimateTime;
            }
        } else if (estimateTime == nil && [stopStatus isEqualToNumber:@1]) {
            
            time = @"尚未發車";
        } else if (estimateTime == nil && [stopStatus isEqualToNumber:@2]) {
            
            time = @"交管不停靠";
        } else if (estimateTime == nil && [stopStatus isEqualToNumber:@3]) {
            
            time = @"末班車已過";
        } else if (estimateTime == nil && [stopStatus isEqualToNumber:@4]) {
            
            time = @"今日未營運";
        } else {
            
            time = @"尚未發車";
        }
    }
    
    return time;
}

//- (NSString *)updateEstimateTime {
//
//    NSString *time;
//    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
//    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@' and StopUID eq '%@'&$format=JSON", _authorityID, _routeName, _routeUID, cityBus.stopUID[indexPath.row]];
//    //    NSLog(@"fetchEstimateTime URL: %@", string);
//    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
//    NSString *encodingURL = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//    NSURL *URL = [NSURL URLWithString:encodingURL];
//    NSData *data = [NSData dataWithContentsOfURL:URL];
//    NSError *error;
//    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
//                                                     options:NSJSONReadingMutableContainers
//                                                       error:&error];
//    for (NSDictionary *dictionary in array) {
//
//        NSNumber *estimateTime = [dictionary objectForKey:@"EstimateTime"];
//        NSNumber *stopStatus = [dictionary objectForKey:@"StopStatus"];
//        if (estimateTime != nil) {
//
//            int intTime = [estimateTime intValue];
//            int minutes = intTime / 60;
//            int seconds = intTime % 60;
//            //            NSLog(@"%@，到站時間：%d:%d", nameZhTW, minutes, seconds);
//            if (minutes <= 1) {
//
//                time = @"進站中";
//            }
//
//            if (seconds <= 20) {
//
//                NSNumber *numberMinutes = [NSNumber numberWithInt:minutes];
//                NSString *string = [numberMinutes stringValue];
//                NSString *stringEstimateTime = [NSString stringWithFormat:@"約 %@ 分", string];
//                time = stringEstimateTime;
//
//            } else {
//
//                NSNumber *numberMinutes = [NSNumber numberWithInt:minutes + 1];
//                NSString *string = [numberMinutes stringValue];
//                NSString *stringEstimateTime = [NSString stringWithFormat:@"約 %@ 分", string];
//                time = stringEstimateTime;
//            }
//
//        } else if ([stopStatus isEqualToNumber:@1]) {
//
//            time = @"尚未發車";
//        } else if ([stopStatus isEqualToNumber:@2]) {
//
//            time = @"交管不停靠";
//        } else if ([stopStatus isEqualToNumber:@3]) {
//
//            time = @"末班車已過";
//        } else if ([stopStatus isEqualToNumber:@4]) {
//
//            time = @"今日未營運";
//        }
//    }
//
//    return nil;
//}


#pragma mark - IBACtion

- (IBAction)segmentedControlGoBackTouch:(UISegmentedControl *)sender {
    
    if ([_goBackControl selectedSegmentIndex] == 1) {
        
        [_tableViewBusDetailList reloadData];
    } else {
        
        [_tableViewBusDetailList reloadData];
    }
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




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
