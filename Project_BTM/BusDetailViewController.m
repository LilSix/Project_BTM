//
//  BusDetailViewController.m
//  Project_BTM
//


#pragma mark .h files

#import "BusDetailViewController.h"
#import "CityBus.h"

@interface BusDetailViewController ()<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    CityBus *cityBus;
}

@property (weak, nonatomic) IBOutlet UITableView *busDetailList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *goBackControl;


@end


#pragma mark -

@implementation BusDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidload: %@, %@, %@", _authorityID, _routeName, _routeUID);
    
    [_goBackControl setSelectedSegmentIndex:0];
    
    [_busDetailList setDataSource:self];
    
    [[self navigationItem] setTitle:[self editStringFromHalfWidthToFullWidth:_routeName]];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    // /v2/Bus/StopOfRoute/City/{City}/{RouteName}   取得指定[縣市],[路線名稱]的市區公車路線與站牌資料
    // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_StopOfRoute_0
    

///FIXME: Don't download data again after enter same selection of view.
    
//    if (![[cityBus stopUID] isEqualToArray:[cityBus stopUID]]) {
    
    
        NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/%@/%@?$filter=RouteUID eq '%@'&$format=JSON",_authorityID, _routeName, _routeUID];
        NSString *encodingString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URL = [NSURL URLWithString:encodingString];
        NSLog(@"URL: %@", URL);
        NSURLSessionDownloadTask *downloadTaskTaipei = [session downloadTaskWithURL:URL];
            
        [downloadTaskTaipei resume];
//    } else {
    
//        [self updateEstimateTime];
//    }
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
        [cityBus setStopUID:[NSMutableArray array]];
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
            NSNumber *isKeyPattern = [dictionary objectForKey:@"KeyPattern"];
            NSNumber *direction = [dictionary objectForKey:@"Direction"];

            NSBlockOperation *operationGo = [[NSBlockOperation alloc] init];
            NSBlockOperation *operationBack = [[NSBlockOperation alloc] init];
            
            [operationGo addExecutionBlock:^{
                
                if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@0]) {
                    
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
                        [[cityBus stopUID] addObject:stopUID];
                        [[cityBus estimateTimeGo] addObject:time];
                    }
                }
            }];
            
            [operationBack addExecutionBlock:^{
                
                if ([isKeyPattern isEqualToNumber:@1] && [direction isEqualToNumber:@1]) {
                    
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
                    }
                }
            }];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperations:@[operationGo, operationBack] waitUntilFinished:YES];
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
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodingURL = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSLog(@"encodingURL = %@", encodingURL);
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
            if (minutes < 1) {
                
                time = @"進站中";
                
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

- (NSString *)updateEstimateTime {
    
    NSString *time;
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/EstimatedTimeOfArrival/City/%@/%@?$filter=RouteUID eq '%@' and StopUID eq '%@'&$format=JSON", _authorityID, _routeName, _routeUID, cityBus.stopUID[indexPath.row]];
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
            }
            
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
    
    return nil;
}


#pragma mark - IBACtion

- (IBAction)segmentedControlGoBackTouch:(UISegmentedControl *)sender {
    
    if ([_goBackControl selectedSegmentIndex] == 1) {
        
        [_busDetailList reloadData];
    } else {
        
        [_busDetailList reloadData];
    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
