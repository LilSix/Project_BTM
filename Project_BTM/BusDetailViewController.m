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
NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate> {
    
    
    NSURLSessionDataTask *fetchBusStopsGo;
    NSURLSessionDataTask *fetchBusStopsBack;
    NSURLSessionDataTask *fetchEstimateGo;
    NSURLSessionDataTask *fetchEstimateBack;
    NSCharacterSet *characterSet;
}

@property (strong, nonatomic) CityBus *cityBus;
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
    NSLog(@"[[cityBus stopUIDGo] count]: %ld", [[_cityBus stopUIDGo] count]);
    
    [_goBackControl setSelectedSegmentIndex:0];
    [_tableViewBusDetailList setDataSource:self];
    
    [[self navigationItem] setTitle:[self editStringFromHalfWidthToFullWidth:_routeName]];
    NSString *go = [NSString stringWithFormat:@"去程（%@）", _destinationStopName];
    NSString *back = [NSString stringWithFormat:@"返程（%@）", _departureStopName];
    [_goBackControl setTitle:go forSegmentAtIndex:0];
    [_goBackControl setTitle:back forSegmentAtIndex:1];
    

    
    [self fetchBusStopsGoWithAuthorityID:_authorityID routeUID:_routeUID];
    [self fetchBusStopsBackWithAuthorityID:_authorityID routeUID:_routeUID];
    [self fetchEstimateTimeGoWithAuthorityID:_authorityID routeUID:_routeUID];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [_tableViewBusDetailList reloadData];
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
    NSLog(@"viewWillAppear.");
}


- (void)viewDidAppear:(BOOL)animated {
    
//    [_tableViewBusDetailList reloadData];
    NSLog(@"viewDidAppear.");
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
        
        _cityBus = [[CityBus alloc] init];
        [_cityBus setStopUIDGo:[NSMutableArray array]];
        [_cityBus setStopUIDBack:[NSMutableArray array]];
        [_cityBus setStopNameGo:[NSMutableArray array]];
        [_cityBus setStopNameBack:[NSMutableArray array]];
        [_cityBus setStopStatus:[NSMutableArray array]];
        [_cityBus setKeyPattern:[NSMutableArray array]];
        [_cityBus setEstimateTimeGo:[NSMutableArray array]];
        [_cityBus setEstimateTimeBack:[NSMutableArray array]];
        
        characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
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
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Right Detail"
                                                                     forIndexPath:indexPath];
    
    if ([_goBackControl selectedSegmentIndex] == 0) {
        
        NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[_cityBus stopNameGo]
                                                                            objectAtIndex:[indexPath row]]];
        [[tableViewCell textLabel] setText:cellTextLabel];
        [[tableViewCell detailTextLabel] setText:[[_cityBus estimateTimeGo] objectAtIndex:[indexPath row]]];
        
        return tableViewCell;
    }
    
    NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[_cityBus stopNameBack]
                                                                        objectAtIndex:[indexPath row]]];
    [[tableViewCell textLabel] setText:cellTextLabel];
//    [[tableViewCell detailTextLabel] setText:[[_cityBus estimateTimeBack] objectAtIndex:[indexPath row]]];
    
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
                    [[_cityBus stopNameGo] addObject:nameZhTW];
                    [[_cityBus stopUIDGo] addObject:stopUID];
                    [[_cityBus estimateTimeGo] addObject:stringWithTime];
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
                    [[_cityBus stopNameBack] addObject:nameZhTW];
                    [[_cityBus stopUIDBack] addObject:stopUID];
                    [[_cityBus estimateTimeBack] addObject:stringWithTime];
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
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        
//        [_tableViewBusDetailList reloadData];
//        [MBProgressHUD hideHUDForView:[self view] animated:YES];
//    }];
}


#pragma mark - FetchData

/*
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
//        NSLog(@"URL: %@", stringWithURL);
        stringWithURL = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        
        //    NSString *stringWithEstimate = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@'&$format=JSON"];
        
        downloadTaskWithBusStops = [session downloadTaskWithURL:URL];
        
        
        if (![[_cityBus selectedRouteUID] isEqualToString:_routeUID]) {
            
            [_cityBus setSelectedRouteUID: _routeUID];
            [downloadTaskWithBusStops resume];
//            NSLog(@"downloadTaskWithBusStops: %@", downloadTaskWithBusStops);
//            NSLog(@"[cityBus selectedStopUID]: %@", [_cityBus selectedStopUID]);
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
*/
 
///FIXME: SUPER SLOW!!! SOMETIME CAN'T FETCH THE FXXKING TIME!!!
- (NSString *)fetchEstimateTimeWithAuthorityID:(NSString *)authorityID
                                     routeName:(NSString *)routeName
                                      routeUID:(NSString *)routeID
                                       stopUID:(NSString *)stopUID {
    
    NSString *time;
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@' and StopUID eq '%@'&$format=JSON", authorityID, routeName, routeID, stopUID];
//    NSLog(@"fetchEstimateTime URL: %@", stringWithURL);
//    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    stringWithURL = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:stringWithURL];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    
    if (![array count]) {
        
        time = @"末班車已過";
        
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


#pragma mark - TEST

/*
- (void)fetchBusStopsGoWithAuthorityID:(NSString *)authorityID
                               routeUID:(NSString *)routeUID {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteUID eq '%@' and KeyPattern eq true and Direction eq '0'&$format=JSON", authorityID, routeUID];
    NSLog(@"fetchEstimateTimeGo URL: %@", stringWithURL);
    
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    fetchBusStopsGo = [session dataTaskWithURL:URL];
    NSLog(@"fetchBusStopsGo = %@", fetchBusStopsGo);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    if (!error) {
                                                        
                                                        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&error];
                                                        NSLog(@"fetchBusStopsGo count: %ld", [array count]);
                                                        for (id object in array) {
                                                            
                                                            NSArray *stops = [object objectForKey:@"Stops"];
                                                            for (id objectInStops in stops) {
                                                                
                                                                NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
                                                                [self fetchEstimateTimeGoWithAuthorityID:authorityID
                                                                                                 stopUID:stopUID];
                                                                NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
                                                                NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                                                                
                                                                [[_cityBus stopUIDGo] addObject:stopUID];
                                                                [[_cityBus stopNameGo] addObject:nameZhTW];
                                                            }
                                                        }
                                                    }
                                                }];
    
    
    [fetchBusStopsGo resume];
}



- (void)fetchBusStopsBackWithAuthorityID:(NSString *)authorityID
                                routeUID:(NSString *)routeUID {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteUID eq '%@' and KeyPattern eq true and Direction eq '1'&$format=JSON", authorityID, routeUID];
//    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    fetchBusStopsBack = [session dataTaskWithURL:URL];
    

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    if (!error) {
                                                        
                                                        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&error];
                                                        NSLog(@"fetchBusStopsBack count: %ld", [array count]);
                                                        
                                                        for (id object in array) {
                                                            
                                                            NSArray *stops = [object objectForKey:@"Stops"];
                                                            for (id objectInStops in stops) {
                                                                
                                                                NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
                                                                [self fetchEstimateTimeBackWithAuthorityID:authorityID
                                                                                                   stopUID:stopUID];
                                                                NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
                                                                NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                                                                
                                                                [[_cityBus stopUIDBack] addObject:stopUID];
                                                                [[_cityBus stopNameBack] addObject:nameZhTW];
                                                            }
                                                        }
                                                    }
                                                }];

    [fetchBusStopsBack resume];
}

- (void)fetchEstimateTimeGoWithAuthorityID:(NSString *)authorityID
                                   stopUID:(NSString *)stopUID {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:nil];
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@?$filter=StopUID eq '%@'&$format=JSON", authorityID, stopUID];
    
//    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    fetchEstimateGo = [session dataTaskWithURL:URL];
    

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                        
                                                    if (!error) {

                                                        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:NSJSONReadingMutableContainers
                                                                                                               error:&error];
                                                        NSString *stringWithTime;
                                                        NSLog(@"%@ array: %@", stopUID, array);
                                                        
                                                        if (array == nil || [array count] == 0 || data == nil) {
                                                            
                                                            stringWithTime = @"尚未發車";
                                                        } else {
                                                        
                                                            for (id object in array) {
                                                                
                                                                NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
                                                                NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
                                                                if (estimateTime != nil) {
                                                                    
                                                                     stringWithTime = [estimateTime stringValue];
                                                                } else {
                                                                    
                                                                    if ([stopStatus isEqualToNumber:@1]) {
                                                                        
                                                                        stringWithTime = @"尚未發車";
                                                                    } else if ([stopStatus isEqualToNumber:@2]) {
                                                                        
                                                                        stringWithTime = @"交管不停靠";
                                                                    } else if ([stopStatus isEqualToNumber:@3]) {
                                                                        
                                                                        stringWithTime = @"末班車已過";
                                                                    } else if ([stopStatus isEqualToNumber:@4]) {
                                                                        
                                                                        stringWithTime = @"今日未營運";
                                                                    } else {
                                                                        
                                                                        stringWithTime = @"尚未發車";
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        [[_cityBus estimateTimeGo] addObject:stringWithTime];
                                                    }
                                                }];

    
//    [fetchEstimateGo resume];
}

- (void)fetchEstimateTimeBackWithAuthorityID:(NSString *)authorityID
                                     stopUID:(NSString *)stopUID {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@?$filter=StopUID eq '%@'&$format=JSON", authorityID, stopUID];
//    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingString = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    fetchEstimateBack = [session dataTaskWithURL:URL];
    

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    if (!error) {
                                                        
                                                        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:&error];
                                                        NSLog(@"%@ array: %@", stopUID, array);
                                                        NSString *stringWithTime;
                                                        
                                                        if (array == nil || [array count] == 0 || data == nil) {
                                                            
                                                            stringWithTime = @"尚未發車";
                                                            [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                        } else {
                                                        
                                                            for (id object in array) {
                                                                
                                                                NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
                                                                NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
                                                                if (estimateTime != nil) {
                                                                    
                                                                    stringWithTime = [estimateTime stringValue];
                                                                    [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                                } else {
                                                                    
                                                                    if (estimateTime == nil || [stopStatus isEqualToNumber:@1]) {
                                                                        
                                                                        stringWithTime = @"尚未發車";
                                                                        [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                                    } else if (estimateTime == nil || [stopStatus isEqualToNumber:@2]) {
                                                                        
                                                                        stringWithTime = @"交管不停靠";
                                                                        [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                                    } else if (estimateTime == nil || [stopStatus isEqualToNumber:@3]) {
                                                                        
                                                                        stringWithTime = @"末班車已過";
                                                                        [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                                    } else if (estimateTime == nil || [stopStatus isEqualToNumber:@4]) {
                                                                        
                                                                        stringWithTime = @"今日未營運";
                                                                        [[_cityBus estimateTimeBack] addObject:stringWithTime];
                                                                    } else {
                                                                        
                                                                        stringWithTime = @"尚未發車";
                                                                        [[_cityBus estimateTimeGo] addObject:stringWithTime];
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }];

//    [fetchEstimateBack resume];
}


#pragma mark - TESTDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    @try {
        
        NSLog(@"dataTask = %@", dataTask);
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        
        if (array == nil) {
            
            [dataTask resume];
        }
            for (id object in array) {
                
                NSArray *stops = [object objectForKey:@"Stops"];
                for (id objectInStops in stops) {
                    
                    NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
                    NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                    NSLog(@"fetchBusStopsGo: %@", nameZhTW);
                    [[_cityBus stopUIDGo] addObject:stopUID];
                    [[_cityBus stopNameGo] addObject:nameZhTW];
                }
            }
            
        
    
            
//            NSArray *array = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:nil];
//
//            for (id object in array) {
//                
//                NSArray *stops = [object objectForKey:@"Stops"];
//                for (id objectInStops in stops) {
//                    
//                    NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
//                    NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
//                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
//                    NSLog(@"fetchBusStopsBack: %@", nameZhTW);
//                    [[_cityBus stopUIDBack] addObject:stopUID];
//                    [[_cityBus stopNameBack] addObject:nameZhTW];
//                }
//            }
        
    } @catch (NSException *exception) {
        
        NSLog(@"%@, %@", [exception name], [exception reason]);
    } @finally {
        
        [session finishTasksAndInvalidate];
//        [_tableViewBusDetailList reloadData];
        NSLog(@"Compelet.");
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [_tableViewBusDetailList reloadData];
    }];
}
*/

    
    


- (void)fetchBusStopsGoWithAuthorityID:(NSString *)authorityID
                              routeUID:(NSString *)routeUID {

    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteUID eq '%@' and KeyPattern eq true and Direction eq '0'&$format=JSON", authorityID, routeUID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSLog(@"fetchEstimateTimeGo URL: %@", stringWithURLEncoding);
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    for (id object in array) {
        
        NSArray *stops = [object objectForKey:@"Stops"];
        for (id objectInStops in stops) {
            
            NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
            NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
//            [self fetchEstimateTimeGoWithAuthorityID:authorityID stopUID:stopUID];
            NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
            
            [[_cityBus stopUIDGo] addObject:stopUID];
            [[_cityBus stopNameGo] addObject:nameZhTW];
            NSLog(@"%@, %@", [_cityBus stopUIDGo], [_cityBus stopNameGo]);
        }
    }
}

- (void)fetchBusStopsBackWithAuthorityID:(NSString *)authorityID
                                routeUID:(NSString *)routeUID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@?$filter=RouteUID eq '%@' and KeyPattern eq true and Direction eq '1'&$format=JSON", authorityID, routeUID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSLog(@"fetchEstimateTimeGo URL: %@", stringWithURLEncoding);
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    for (id object in array) {
        
        NSArray *stops = [object objectForKey:@"Stops"];
        for (id objectInStops in stops) {
            
            NSString *stopUID = [objectInStops objectForKey:@"StopUID"];
            NSDictionary *stopName = [objectInStops objectForKey:@"StopName"];
//            [self fetchEstimateTimeBackWithAuthorityID:authorityID stopUID:stopUID];
            NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
            
            [[_cityBus stopUIDBack] addObject:stopUID];
            [[_cityBus stopNameBack] addObject:nameZhTW];
            NSLog(@"%@, %@", [_cityBus stopUIDBack], [_cityBus stopNameBack]);
        }
    }
}

/*
- (void)fetchEstimateTimeGoWithAuthorityID:(NSString *)authorityID
                                   stopUID:(NSString *)stopUID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@?$filter=StopUID eq '%@'&$format=JSON", authorityID, stopUID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];

    NSString *stringWithTime;
    if (array == nil || [array count] == 0 || data == nil) {
        
        stringWithTime = @"尚未發車";
    } else {
        
        for (id object in array) {
            
            NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
            NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
            if (estimateTime != nil) {
                
                stringWithTime = [estimateTime stringValue];
            } else {
                
                if ([stopStatus isEqualToNumber:@1]) {
                    
                    stringWithTime = @"尚未發車";
                } else if ([stopStatus isEqualToNumber:@2]) {
                    
                    stringWithTime = @"交管不停靠";
                } else if ([stopStatus isEqualToNumber:@3]) {
                    
                    stringWithTime = @"末班車已過";
                } else if ([stopStatus isEqualToNumber:@4]) {
                    
                    stringWithTime = @"今日未營運";
                } else {
                    
                    stringWithTime = @"尚未發車";
                }
            }
            
            [[_cityBus estimateTimeGo] addObject:stringWithTime];
        }
    }
}

- (void)fetchEstimateTimeBackWithAuthorityID:(NSString *)authorityID
                                     stopUID:(NSString *)stopUID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@?$filter=StopUID eq '%@'&$format=JSON", authorityID, stopUID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    
    NSString *stringWithTime;
    if (array == nil || [array count] == 0 || data == nil) {
        
        stringWithTime = @"尚未發車";
    } else {
        
        for (id object in array) {
            
            NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
            NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
            if (estimateTime != nil) {
                
                stringWithTime = [estimateTime stringValue];
            } else {
                
                if ([stopStatus isEqualToNumber:@1]) {
                    
                    stringWithTime = @"尚未發車";
                } else if ([stopStatus isEqualToNumber:@2]) {
                    
                    stringWithTime = @"交管不停靠";
                } else if ([stopStatus isEqualToNumber:@3]) {
                    
                    stringWithTime = @"末班車已過";
                } else if ([stopStatus isEqualToNumber:@4]) {
                    
                    stringWithTime = @"今日未營運";
                } else {
                    
                    stringWithTime = @"尚未發車";
                }
            }
            
            [[_cityBus estimateTimeBack] addObject:stringWithTime];
        }
    }
}
*/


- (void)fetchEstimateTimeGoWithAuthorityID:(NSString *)authorityID
                                  routeUID:(NSString *)routeUID {
    
    NSString *stringWithURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@?$filter=RouteUID eq '%@' and Direction eq '0'&$format=JSON", authorityID, routeUID];
    NSString *stringWithURLEncoding = [stringWithURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:stringWithURLEncoding];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *stringWithTime;
    
    for (id object in array) {
        
        NSNumber *estimateTime = [object objectForKey:@"EstimateTime"];
        NSNumber *stopStatus = [object objectForKey:@"StopStatus"];
        if (estimateTime != nil) {
         
            stringWithTime = [estimateTime stringValue];
        } else if ([stopStatus isEqualToNumber:@1]) {
            
            stringWithTime = @"尚未發車";
        } else if ([stopStatus isEqualToNumber:@2]) {
            
            stringWithTime = @"交管不停靠";
        } else if ([stopStatus isEqualToNumber:@3]) {
            
            stringWithTime = @"末班車已過";
        } else if ([stopStatus isEqualToNumber:@4]) {
            
            stringWithTime = @"今日未營運";
        } else {
            
            stringWithTime = @"尚未發車";
        }
        
        [dictionary setObject:stringWithTime forKey:routeUID];
        [[_cityBus estimateTimeGo] addObject:dictionary];
    }
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
