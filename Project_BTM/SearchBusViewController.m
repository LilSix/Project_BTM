//
//  SearchViewController.m
//  Project_BTM
//


#pragma mark .h files

#import "SearchBusViewController.h"
#import "BusDetailViewController.h"
#import "CityBus.h"


#pragma mark Frameworks

@import SystemConfiguration;


#pragma mark -

@interface SearchBusViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    CityBus *cityBus;
    
    NSMutableArray *cityBusList;
//    NSMutableArray *departureStopName;
//    NSMutableArray *destinationStopName;
    
    NSMutableArray *busStopStartToEnd;
    
    NSArray *searchResults;
    
    UIPickerView *pickerViewRouteName;
    
    NSString *cityBusRouteTitle;
    
    
    NSString *searchRouteName;
    NSString *searchRouteNumber;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewBusList;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (strong, nonatomic) IBOutlet UISearchController *searchDisplayController;

@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property (weak, nonatomic) IBOutlet UITextField *textViewRouteName;
@property (weak, nonatomic) IBOutlet UITextField *textViewRouteNumber;
//@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewRouteName;

@property (strong, nonatomic) NSArray *routeNameDataSouce;

@end


#pragma mark -

@implementation SearchBusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Picker view.
    pickerViewRouteName = [[UIPickerView alloc] init];
    [pickerViewRouteName setDelegate:self];
    [pickerViewRouteName setDataSource:self];
    [pickerViewRouteName setShowsSelectionIndicator:YES];
    
    // Bus route name data in picker view.
    _routeNameDataSouce = @[@"", @"F", @"小", @"藍", @"紅",
                            @"棕", @"綠", @"橘", @"內科", @"幹線",
                            @"先導", @"南軟", @"夜間", @"活動", @"市民",
                            @"跳蛙", @"其他", @"臺北觀光巴士"];
    
    // Route name text field.
    [_textViewRouteName setDelegate:self];
    [_textViewRouteName setInputView:pickerViewRouteName];

    // Table view.
    [_tableViewBusList setDelegate:self];
    [_tableViewBusList setDataSource:self];
    
    UIToolbar* toolBar = [[UIToolbar alloc] init];
    [toolBar setBarStyle:UIBarStyleDefault];
    
    // Create toolbar cancel bar button item.
    UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(barButtonItemCancelTouch)];
    
    // Create toolbar fixed space bar button item.
    UIBarButtonItem *barButtonItemFixedSpace = [[UIBarButtonItem alloc]
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                         target:self
                                                                         action:nil];
    // Create toolbar done bar button item.
    UIBarButtonItem *barButtonItemSearch = [[UIBarButtonItem alloc] initWithTitle:@"確認"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(barButtonItemDoneTouch)];
    
    // Put bar button item in array.
    NSArray *arrayToolBarButtonItem = @[barButtonItemCancel, barButtonItemFixedSpace, barButtonItemSearch];
    
    // Setting about toolbar.
    [toolBar sizeToFit];
    [toolBar setItems:arrayToolBarButtonItem];
    [_textViewRouteName setInputAccessoryView:toolBar];
    [_textViewRouteNumber setInputAccessoryView:toolBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        // Initial mutable array.
        cityBusList = [NSMutableArray array];
//        departureStopName = [NSMutableArray array];
//        destinationStopName = [NSMutableArray array];
        busStopStartToEnd = [NSMutableArray array];
        
        
        cityBus = [[CityBus alloc] init];
        [cityBus setAuthorityID:[NSMutableArray array]];
        [cityBus setRouteUID:[NSMutableArray array]];
        [cityBus setRouteName:[NSMutableArray array]];
        [cityBus setDepartureStopName:[NSMutableArray array]];
        [cityBus setDestinationStopName:[NSMutableArray array]];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
//    NSLog(@"[[cityBus routeName] count]: %ld", [[cityBus routeName] count]);
    return [[cityBus routeName] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[cityBus routeName] objectAtIndex:[indexPath row]]];
    [[tableViewCell textLabel] setText:cellTextLabel];
    
    NSString *cellDetailTextLabel = [NSString stringWithFormat:@"%@－%@",
                                        [[cityBus departureStopName] objectAtIndex:[indexPath row]],
                                        [[cityBus destinationStopName] objectAtIndex:[indexPath row]]];
    
    [[tableViewCell detailTextLabel] setText:cellDetailTextLabel];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
}


//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    [busDetailViewController setCityBusRouteTitle:[[cityBus routeName] objectAtIndex:[indexPath row]]];
////    [cityBus setCityBusRouteTitle:[[cityBus routeName] objectAtIndex:[indexPath row]]];
//    
//    NSLog(@"UITableViewDelegate");
////    NSLog(@"_cityBusRoute: %@", [cityBus cityBusRouteTitle]);
//    
////    NSLog(@"cityBusRouteTitle = %@", cityBusRouteTitle);
//}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    NSLog(@"%@", routeNameList);
    
//    [_routeNamePicker setDelegate:self];
//    [_routeNamePicker setDataSource:self];
    
    NSLog(@"textFieldShouldBeginEditing");
    
//    [routeNamePicker setHidden:NO];
    
//    if ([_routeNameTextField ]) {
//        
////        UIPickerView *tempPickerView = [[self view] viewWithTag:11];
////        [tempPickerView setHidden:YES];
//        NSLog(@"[_routeNameTextField isEditing]");
//        [_routeNamePicker setHidden:NO];
//    } else if ([_routeNumberTextField isTouchInside]){
//        [_routeNamePicker setHidden:YES];
//    }
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    return YES;
}


#pragma mark - UIPickerViewDataSource

// Returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// Returns the # of rows in each component.
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    
    return [_routeNameDataSouce count];
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    return [_routeNameDataSouce objectAtIndex:row];
}


// Called by the picker view when the user selects a row in a component.
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    [_textViewRouteName setText:_routeNameDataSouce[row]];
}


#pragma mark - prepareForDownloadJSONData

///TODO: Create method to prepare download JSON data.
//- (NSURLSessionDownloadTask *)prepareForDownloadJSONData {
//    
//    NSString *stringName = [_routeNameTextField text];
//    NSString *stringNumber = [_routeNumberTextField text];
//
//    // Use NSOperationQueue to background download JSON data.
//    NSURLSessionConfiguration *URLSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:URLSessionConfiguration
//                                                          delegate:self
//                                                     delegateQueue:[NSOperationQueue mainQueue]];
//    
//    NSString *stringTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@%@?$format=JSON", stringName, stringNumber];
//    NSURL *URLTaipei = [NSURL URLWithString:stringTaipei];
//    NSURLSessionDownloadTask *taipeiDownloadTask = [session downloadTaskWithURL:URLTaipei];
//    
//    NSString *stringNewTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/NewTaipei/%@%@?$format=JSON", stringName, stringNumber];
//    NSURL *URLNewTiapei = [NSURL URLWithString:stringNewTaipei];
//    NSURLSessionDownloadTask *newTaipeiDownloadtask = [session downloadTaskWithURL:URLNewTiapei];
//    
//    return nil;
//}






#pragma mark - IBAction

- (IBAction)buttonSearchTouch:(UIButton *)sender {
    
    [[self view] endEditing:YES];
//    [[self view] resignFirstResponder];
    
    if (![[_textViewRouteName text] isEqualToString:@""] || ![[_textViewRouteNumber text] isEqualToString:@""]) {
        
        // Use NSOperationQueue to background download JSON data.
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        
        
        // Fix URL encoding: http://blog.csdn.net/andanlan/article/details/53368727
        // Encoding special characters in URL.
        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        
        //    http:ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
        //    /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
        // Prepare for download Taipei City bus JSON file.
        NSString *stringTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@%@?$orderby=RouteID asc&$format=JSON", [_textViewRouteName text], [_textViewRouteNumber text]];
        stringTaipei = [stringTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URLTaipei = [NSURL URLWithString:stringTaipei];
        NSURLSessionDownloadTask *downloadTaskTaipei = [session downloadTaskWithURL:URLTaipei];

        // Prepare for download New Taipei City bus JSON file.
        NSString *stringNewTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/NewTaipei/%@%@?$orderby=RouteID asc&$format=JSON", [_textViewRouteName text], [_textViewRouteNumber text]];
        stringNewTaipei = [stringNewTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URLNewTiapei = [NSURL URLWithString:stringNewTaipei];
        NSURLSessionDownloadTask *downloadtaskNewTaipei = [session downloadTaskWithURL:URLNewTiapei];
        
//        NSBlockOperation *operationTaipei = [[NSBlockOperation alloc] init];
//        NSBlockOperation *operationNewTaipei = [[NSBlockOperation alloc] init];
        
        if (!([searchRouteName isEqualToString:[_textViewRouteName text]] &&
            [searchRouteNumber isEqualToString:[_textViewRouteNumber text]])) {
            
            [[cityBus authorityID] removeAllObjects];
            [[cityBus routeUID] removeAllObjects];
            [[cityBus routeName] removeAllObjects];
            [[cityBus departureStopName] removeAllObjects];
            [[cityBus destinationStopName] removeAllObjects];
            [busStopStartToEnd removeAllObjects];
            [_tableViewBusList reloadData];
            
            searchRouteName = [_textViewRouteName text];
            searchRouteNumber = [_textViewRouteNumber text];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                
                [downloadTaskTaipei resume];
                [downloadtaskNewTaipei resume];
            }];
            
            NSLog(@"Start download JSON data...");   
        }
        
        
        
//        [operationTaipei addExecutionBlock:^{
//        
//            [downloadTaskTaipei resume];
//            NSLog(@"Taipei downloadTaskTaipei: %@", downloadTaskTaipei);
//        }];
//        
//        [operationNewTaipei addExecutionBlock:^{
//            
//            [downloadtaskNewTaipei resume];
//            NSLog(@"New Taipei downloadtaskNewTaipei: %@", downloadtaskNewTaipei);
//        }];
//        
//        [queue addOperations:@[operationTaipei, operationNewTaipei] waitUntilFinished:YES];

//        [queue addOperationWithBlock:^{
//            
//            [downloadTaskTaipei resume];
//            [downloadtaskNewTaipei resume];
//        }];
        
        
    } else {

        // Remove objects if text field is empty.
        [[cityBus authorityID] removeAllObjects];
        [[cityBus routeUID] removeAllObjects];
        [[cityBus routeName] removeAllObjects];
        [[cityBus departureStopName] removeAllObjects];
        [[cityBus destinationStopName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        [_tableViewBusList reloadData];
        
        
        // Alert view.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告"
                                                                                 message:@"請輸入路線或號碼後再做搜尋。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
    
    
    
    
//    NSString *stringName = [_routeNameTextField text];
//    NSString *stringNumber = [_routeNumberTextField text];
    
//    NSString *combineString = [NSString stringWithFormat:@"%@%@", stringName, stringNumber];
//    
//    [_searchResultsList reloadData];
//
//    if ([combineString isEqualToString:@""]) {
//        
//        // Remove objects if text field is empty.
//        [cityBusList removeAllObjects];
//        [busStopStartToEnd removeAllObjects];
//        
//        // Alert view.
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
//                                                                                 message:@"Please input route number."
//                                                                          preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK"
//                                                              style:UIAlertActionStyleDefault
//                                                            handler:nil];
//        [alertController addAction:alertAction];
//        [self presentViewController:alertController animated:YES completion:nil];
//    } else {
//        
//        // Remove objects from mutablearray before search.
//        [cityBusList removeAllObjects];
//        [busStopStartToEnd removeAllObjects];
//        
//        NSString *stringTaipeiURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@?$format=JSON", combineString];
//        
//        // Fix URL encoding. http://blog.csdn.net/andanlan/article/details/53368727
//        NSString *stringNewTaipeiURL = [NSString stringWithFormat:@"http://data.ntpc.gov.tw/od/data/api/67BB3C2B-E7D1-43A7-B872-61B2F082E11B?$format=json&$filter=nameZh eq %@", combineString];
//        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
//        NSString *encodingNewTaipeiURL = [stringNewTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//        NSString *encodingTaipeiURL = [stringTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//        
//        NSURL *taipeiURL = [NSURL URLWithString:encodingTaipeiURL];
//        NSURL *newTaipeiURL = [NSURL URLWithString:encodingNewTaipeiURL];
//        
//        NSData *taipeiData = [NSData dataWithContentsOfURL:taipeiURL];
//        NSData *newTaipeiData = [NSData dataWithContentsOfURL:newTaipeiURL];
//        
//        NSError *error;
//        
//        NSArray *taipeiCityBus = [NSJSONSerialization JSONObjectWithData:taipeiData
//                                                                 options:NSJSONReadingMutableContainers
//                                                                   error:&error];
//        NSArray *newTaipeiCityBus = [NSJSONSerialization JSONObjectWithData:newTaipeiData
//                                                                    options:NSJSONReadingMutableContainers
//                                                                      error:&error];
//        
//        if (taipeiCityBus != nil) {
//            
//            for (NSDictionary *dictionary in taipeiCityBus) {
//                NSLog(@"result: %@", dictionary);
//                
//                NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
//                NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
//                NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
//                NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
//                
//                NSString *editedString = [self editStringFromHalfWidthToFullWidth:zhTW];
//                NSString *editedDepartureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
//                NSString *editedDestinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];
//
//                NSString *startEnd = [NSString stringWithFormat:@"%@－%@", editedDepartureStopNameZh, editedDestinationStopNameZh];
//                
//                [cityBusList addObject:editedString];
//                [busStopStartToEnd addObject:startEnd];
//            }
//        }
//        
//
//        if (newTaipeiCityBus != nil) {
//    
//            for (NSDictionary *dictionary in newTaipeiCityBus) {
//                
//                NSString *nameZh = [dictionary objectForKey:@"nameZh"];
//                NSString *departureZh = [dictionary objectForKey:@"departureZh"];
//                NSString *destinationZh = [dictionary objectForKey:@"destinationZh"];
//                
//                NSString *editedString = [self editStringFromHalfWidthToFullWidth:nameZh];
//                NSString *editedDepartureZh = [self editStringFromHalfWidthToFullWidth:departureZh];
//                NSString *editedDestinationZh = [self editStringFromHalfWidthToFullWidth:destinationZh];
//                
//                NSString *startEnd = [NSString stringWithFormat:@"%@－%@", editedDepartureZh, editedDestinationZh];
//                
//                [cityBusList addObject:editedString];
//                [busStopStartToEnd addObject:startEnd];
//                
//            }
//        }
//    }
//
//    [_searchResultsList reloadData];
}

- (IBAction)barButtonItemStopTouch:(UIBarButtonItem *)sender {
    
    searchRouteName = @"";
    searchRouteNumber = @"";
    
    [_textViewRouteName setText:@""];
    [_textViewRouteNumber setText:@""];
    
    [[cityBus authorityID] removeAllObjects];
    [[cityBus routeUID] removeAllObjects];
    [[cityBus routeName] removeAllObjects];
    [[cityBus departureStopName] removeAllObjects];
    [[cityBus destinationStopName] removeAllObjects];
    [busStopStartToEnd removeAllObjects];
    [_tableViewBusList reloadData];
}


#pragma mark - UIBarButtonItem Action

- (void)barButtonItemCancelTouch {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}

- (void)barButtonItemDoneTouch {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
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


#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[self view] endEditing:YES];
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    @try {
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
        for (NSDictionary *dictionary in array) {
            
            NSString *authorityID = [dictionary objectForKey:@"AuthorityID"];
            NSString *routeUID = [dictionary objectForKey:@"RouteUID"];
            NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
            NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
            NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
            NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
            
            if (![departureStopNameZh isEqualToString:@""]) {
                
                departureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
                destinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];

                if ([authorityID isEqualToString:@"004"]) {
                    
                    [[cityBus authorityID] addObject:@"Taipei"];
                } else if ([authorityID isEqualToString:@"005"]) {
                    
                    [[cityBus authorityID] addObject:@"NewTaipei"];
                }
                
                [[cityBus routeUID] addObject:routeUID];
                [[cityBus routeName] addObject:zhTW];
                [[cityBus departureStopName] addObject:departureStopNameZh];
                [[cityBus destinationStopName] addObject:destinationStopNameZh];
            }
        }

    } @catch (NSException *exception) {
        
        NSLog(@"Caught: %@, %@", [exception name], [exception reason]);
    } @finally {
        
        NSLog(@"[cityBus routeUID]: %@", [cityBus routeUID]);
        NSLog(@"[cityBus routeName]: %@", [cityBus routeName]);
        NSLog(@"Download compeleted.");
        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        [_tableViewBusList reloadData];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showBusDetail"]) {
        
        BusDetailViewController *busDetailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [_tableViewBusList indexPathForSelectedRow];  /*  An index path identifying the row and
                                                                                section of the selected row.    */
        NSString *authorityID = [[cityBus authorityID] objectAtIndex:[indexPath row]];
        NSString *routeName = [[cityBus routeName] objectAtIndex:[indexPath row]];
        NSString *routeUID = [[cityBus routeUID] objectAtIndex:[indexPath row]];
        NSString *departureStopName = [[cityBus departureStopName] objectAtIndex:[indexPath row]];
        NSString *destinationStopName = [[cityBus destinationStopName] objectAtIndex:[indexPath row]];
        
        [busDetailViewController setAuthorityID:authorityID];
        [busDetailViewController setRouteName:routeName];
        [busDetailViewController setRouteUID:routeUID];
        [busDetailViewController setDepartureStopName:departureStopName];
        [busDetailViewController setDestinationStopName:destinationStopName];
        [busDetailViewController setSelectedStopUID:routeUID];
        NSLog(@"[busDetailViewController selectedStopUID]: %@", [busDetailViewController selectedStopUID]);
    }
}


@end
