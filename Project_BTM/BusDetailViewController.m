//
//  BusDetailViewController.m
//  Project_BTM
//

///MARK: .h files
#import "BusDetailViewController.h"
#import "CityBus.h"

@interface BusDetailViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
//    NSMutableArray *mutableArray;
    CityBus *cityBus;
}

@property (weak, nonatomic) IBOutlet UITableView *busDetailList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goBackControl;

@end

@implementation BusDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidload: %@, %@, %@", _authorityID, _routeName, _routeUID);
    
    [_goBackControl setSelectedSegmentIndex:0];
    
//    [_busDetailList setDelegate:self];
    [_busDetailList setDataSource:self];
    
    [[self navigationItem] setTitle:[self editStringFromHalfWidthToFullWidth:_routeName]];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    // /v2/Bus/StopOfRoute/City/{City}/{RouteName}   取得指定[縣市],[路線名稱]的市區公車路線與站牌資料
    // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_StopOfRoute_0
    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$filter=RouteUID eq '%@'&$format=JSON",_authorityID, _routeName, _routeUID];
//    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/Taipei/306?$filter=RouteUID eq 'TPE10473' and Direction eq '0'&$format=JSON"];

    
//        NSString *string2 = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$filter=RouteUID eq '%@'and KeyPattern eq true and Direction eq '0'&$format=JSON",_authorityID, _routeName, _routeUID];
    
//    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$format=JSON", _authorityID, _routeName];
    NSString *encodingString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//    NSString *encodingString2 = [string2 stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    NSLog(@"URL: %@", URL);
//    NSURL *URL2 = [NSURL URLWithString:encodingString2];
    NSURLSessionDownloadTask *downloadTaskTaipei = [session downloadTaskWithURL:URL];
//    NSURLSessionDownloadTask *downloadTaskTaipei2 = [session downloadTaskWithURL:URL2];
//    NSData *data = [NSData dataWithContentsOfURL:URLTaipei];
//    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
//                                                     options:NSJSONReadingMutableContainers
//                                                       error:nil];
//    for (NSDictionary *dictionary in array) {
//        
//        NSArray *stops = [dictionary objectForKey:@"Stops"];
//        
//        for (NSDictionary *StopName in stops) {
//        
//            NSDictionary *zhTW = [StopName objectForKey:@"StopName"];
//            NSString *string = [zhTW objectForKey:@"Zh_tw"];
//            NSString *editedString = [self editStringFromHalfWidthToFullWidth:string];
//            [mutableArray addObject:editedString];
//            NSLog(@"%@", editedString);
//        }
//    }
    [downloadTaskTaipei resume];
//    [downloadTaskTaipei2 resume];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
//        mutableArray = [NSMutableArray array];
        cityBus = [[CityBus alloc] init];
        [cityBus setStopUID:[NSMutableArray array]];
        [cityBus setStopNameGo:[NSMutableArray array]];
        [cityBus setStopNameBack:[NSMutableArray array]];
        [cityBus setStopStatus:[NSMutableArray array]];
        [cityBus setKeyPattern:[NSMutableArray array]];
        [cityBus setEstimateTimeGo:[NSMutableArray array]];
        [cityBus setEstimateTimeBack:[NSMutableArray array]];
        
//        [[self navigationItem] setTitle:[cityBus cityBusRouteTitle]];
//        [self setTitle:[cityBus cityBusRouteTitle]];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
//    NSLog(@"[mutableArray count]: %ld", [mutableArray count]);
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
        NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[cityBus stopNameGo] objectAtIndex:[indexPath row]]];
        [[tableViewCell textLabel] setText:cellTextLabel];
        [[tableViewCell detailTextLabel] setText:[[cityBus estimateTimeGo] objectAtIndex:[indexPath row]]];
        
        return tableViewCell;
    }
        
    NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[cityBus stopNameBack] objectAtIndex:[indexPath row]]];
    [[tableViewCell textLabel] setText:cellTextLabel];
    [[tableViewCell detailTextLabel] setText:[[cityBus estimateTimeBack] objectAtIndex:[indexPath row]]];
    
    return tableViewCell;
}



#pragma mark - Half-Width To Full-Width

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


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    
    @try {

        // /v2/Bus/EstimatedTimeOfArrival/City/{City}/{RouteName}   取得指定[縣市],[路線名稱]的公車預估到站資料(N1)
        // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_EstimatedTimeOfArrival_0
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        for (NSDictionary *dictionary in array) {
            
///FIXME: KeyPattern bug.
//            NSString *
            NSNumber *isKeyPattern = [dictionary objectForKey:@"KeyPattern"];
            NSNumber *direction = [dictionary objectForKey:@"Direction"];

            if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@0]) {
            
//                NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$filter=RouteUID eq '%@'and KeyPattern eq false and Direction eq '0'&$format=JSON",_authorityID, _routeName, _routeUID];
//                NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
//                NSString *encodingString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//                NSURL *URLTaipei = [NSURL URLWithString:encodingString];
            
//                NSArray *stops = [dictionary objectForKey:@"Stops"];
//                for (NSDictionary *dictionaryStops in stops) {
//                
//                    NSString *stopUID = [dictionaryStops objectForKey:@"StopUID"];
                    
//                    // Download bus estimate time of arrival stop.
//                    NSString *stringURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=StopUID eq '%@'&$format=JSON", _authorityID, _routeName, stopUID];
//                    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
//                    NSString *encodingString = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//                    NSURL *URL = [NSURL URLWithString:encodingString];
//                    NSData *dataURL = [NSData dataWithContentsOfURL:URL];
//                    NSError *error;
//                    NSArray *arrayEstimateTime = [NSJSONSerialization JSONObjectWithData:dataURL
//                                                                                 options:NSJSONReadingMutableContainers
//                                                                                   error:&error];
//                    
//                    for (NSDictionary *dictionaryET in arrayEstimateTime) {
//                        NSNumber *stopStatus = [dictionary objectForKey:@"StopStatus"];
//                        
//                        if ([stopStatus isEqual: @1]) {
//                            
//                            [[cityBus stopStatus] addObject:@"尚未發車"];
//                        } else if ([stopStatus isEqual:@2]) {
//                            
//                            [[cityBus stopStatus] addObject:@"交管不停靠"];
//                        } else if ([stopStatus isEqual:@3]) {
//                            
//                            NSString *string = @"末班車已過";
//                            [[cityBus stopStatus] addObject:string];
//                        } else if ([stopStatus isEqual:@4]) {
//                            
//                            [[cityBus stopStatus] addObject:@"今日未營運"];
//                        } else {
//                            
//                            NSString *estimateTime = [dictionary objectForKey:@"EstimateTime"];
//                            [[cityBus stopStatus] addObject:estimateTime];
//                        }
//                    }
            
                    
                    NSArray *stops = [dictionary objectForKey:@"Stops"];
                for (NSDictionary *dictionary in stops) {
                    
                    NSString *stopUID = [dictionary objectForKey:@"StopUID"];
                    
                    NSString *time = [self fetchEstimateTimeWithAuthorityID:_authorityID
                                                                    routeName:_routeName
                                                                     routeUID:_routeUID
                                                                      stopUID:stopUID];
                    NSDictionary *stopName = [dictionary objectForKey:@"StopName"];
                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                    [[cityBus stopNameGo] addObject:nameZhTW];
                    [[cityBus estimateTimeGo] addObject:time];
//                    NSLog(@"%@, %@", stopUID, nameZhTW);
                }
                
//                    NSNumber *estimateTime = [dictionary objectForKey:@"EstimateTime"];
//                    NSString *stringTime = [estimateTime stringValue];
                
//                    [[cityBus stopStatus] addObject:stringTime];
                
//                NSLog(@"[[cityBus stopName] count]: %ld", [[cityBus stopName] count]);
//                NSLog(@"[[cityBus estimateTime] count]: %ld", [[cityBus estimateTime] count]);
//                }
//            }
            } else if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@1]) {
                
                NSArray *stops = [dictionary objectForKey:@"Stops"];
                for (NSDictionary *dictionary in stops) {
                    
                    NSString *stopUID = [dictionary objectForKey:@"StopUID"];
                    
                    NSString *time = [self fetchEstimateTimeWithAuthorityID:_authorityID
                                                                  routeName:_routeName
                                                                   routeUID:_routeUID
                                                                    stopUID:stopUID];
                    NSDictionary *stopName = [dictionary objectForKey:@"StopName"];
                    NSString *nameZhTW = [stopName objectForKey:@"Zh_tw"];
                    [[cityBus stopNameBack] addObject:nameZhTW];
                    [[cityBus estimateTimeBack] addObject:time];
                    //                    NSLog(@"%@, %@", stopUID, nameZhTW);
                }
                
                //                    NSNumber *estimateTime = [dictionary objectForKey:@"EstimateTime"];
                //                    NSString *stringTime = [estimateTime stringValue];
                
                //                    [[cityBus stopStatus] addObject:stringTime];
                
//                NSLog(@"[[cityBus stopName] count]: %ld", [[cityBus stopName] count]);
//                NSLog(@"[[cityBus estimateTime] count]: %ld", [[cityBus estimateTime] count]);
            }
    
        }
    } @catch (NSException *exception) {
        
        NSLog(@"[%@]: %@", [exception name], [exception reason]);
    } @finally {
        
        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        [_busDetailList reloadData];
    }
}


- (NSString *)fetchEstimateTimeWithAuthorityID:(NSString *)authorityID
                                     routeName:(NSString *)routeName
                                      routeUID:(NSString *)routeID
                                       stopUID:(NSString *)stopUID {
    
    NSString *time;
    
    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@' and StopUID eq '%@'&$format=JSON", authorityID, routeName, routeID, stopUID];
//    NSLog(@"fetchEstimateTime URL: %@", string);
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingURL = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingURL];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&error];
    for (NSDictionary *dictionary in array) {
        
        NSNumber *estimateTime = [dictionary objectForKey:@"EstimateTime"];
        NSNumber *stopStatus = [dictionary objectForKey:@"StopStatus"];
        if (estimateTime != nil) {
            
            int intTime = [estimateTime intValue];
            int minutes = intTime / 60;
            int seconds = intTime % 60;
//            NSLog(@"%@，到站時間：%d:%d", nameZhTW, minutes, seconds);
            if (minutes <= 1) {
                
                time = @"進站中";
                
                return time;
            } else if ((minutes >= 1 && seconds >= 30) || minutes <= 2) {
                
                time = @"即將到站";
                
                return time;
            } else {
            
                if (seconds <= 20) {
                    
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
            }
        } else if ([stopStatus isEqualToNumber:@1]) {
            
            time = @"尚未發車";
        } else if ([stopStatus isEqualToNumber:@2]) {
            
            time = @"交管不停靠";
        } else if ([stopStatus isEqualToNumber:@3]) {
            
            time = @"末班車已過";
        } else if ([stopStatus isEqualToNumber:@4]) {
            
            time = @"今日未營運";
        }
    }
    
    return time;
}


- (IBAction)segmentedControlGoBackTouch:(UISegmentedControl *)sender {
    
    if ([_goBackControl selectedSegmentIndex] == 1) {
        
        [_busDetailList reloadData];
    } else {
        
        [_busDetailList reloadData];
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
