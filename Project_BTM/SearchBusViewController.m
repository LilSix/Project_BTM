//
//  SearchViewController.m
//  Project_BTM
//

///MARK: .h files
#import "SearchBusViewController.h"
#import "BusDetailViewController.h"
#import "CityBus.h"

///MARK: Frameworks
@import SystemConfiguration;


@interface SearchBusViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    CityBus *cityBus;
    
    NSMutableArray *cityBusList;
    NSMutableArray *departureStopName;
    NSMutableArray *destinationStopName;
    
    NSMutableArray *busStopStartToEnd;
    
    NSArray *searchResults;
    NSArray *routeNameList;
    
    UIPickerView *routeNamePicker;
    
    NSString *cityBusRouteTitle;
    
    
//    UIPickerView *routeNamePicker;
}

@property (weak, nonatomic) IBOutlet UITableView *searchBusList;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (strong, nonatomic) IBOutlet UISearchController *searchDisplayController;

@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property (weak, nonatomic) IBOutlet UITextField *routeName;
@property (weak, nonatomic) IBOutlet UITextField *routeNumber;
//@property (weak, nonatomic) IBOutlet UIPickerView *routeNamePicker;

//@property (strong, nonatomic) NSString *cityBusRouteTitle;

@end


#pragma mark -

@implementation SearchBusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSLog(@"viewDidLoad");
    
    // Picker view.
    routeNamePicker = [[UIPickerView alloc] init];
    [routeNamePicker setDelegate:self];
    [routeNamePicker setDataSource:self];
    [routeNamePicker setShowsSelectionIndicator:YES];
    
///FIXME: Picker selection dismiss.
    // Bus route name data in picker view.
    routeNameList = @[@"", @"藍", @"紅", @"棕", @"綠",
                      @"橘", @"F", @"內科", @"幹線", @"先導",
                      @"南軟", @"夜間", @"活動", @"市民", @"跳蛙",
                      @"其他", @"臺北觀光巴士"];
    
    // Route name text field.
    [_routeName setDelegate:self];
    [_routeName setInputView:routeNamePicker];

    // Table view.
    [_searchBusList setDelegate:self];
    [_searchBusList setDataSource:self];
    
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
    [_routeName setInputAccessoryView:toolBar];
    [_routeNumber setInputAccessoryView:toolBar];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIBarButtonItem Action

- (void)barButtonItemCancelTouch {
    
    [_routeName endEditing:YES];
    [_routeNumber endEditing:YES];
    
}

- (void)barButtonItemDoneTouch {
    
    [_routeName endEditing:YES];
    [_routeNumber endEditing:YES];
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        // Initial mutable array.
        cityBusList = [NSMutableArray array];
        departureStopName = [NSMutableArray array];
        destinationStopName = [NSMutableArray array];
        busStopStartToEnd = [NSMutableArray array];
        
        
        cityBus = [[CityBus alloc] init];
        [cityBus setAuthorityID:[NSMutableArray array]];
        [cityBus setRouteUID:[NSMutableArray array]];
        [cityBus setRouteName:[NSMutableArray array]];
        
        
//        NSLog(@"initWithCoder");
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
    [[tableViewCell detailTextLabel] setText:[busStopStartToEnd objectAtIndex:[indexPath row]]];
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
//    [_routeNamePicker setDelegate:self];
//    [_routeNamePicker setDataSource:self];
//    [textField resignFirstResponder];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    [routeNamePicker setHidden:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

//    [routeNamePicker setHidden:YES];
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
    
    return [[cityBus routeName] count];
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    return [routeNameList objectAtIndex:row];
}


// Called by the picker view when the user selects a row in a component.
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    [_routeName setText:routeNameList[row]];
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
    
//    [routeNamePicker setHidden:YES];
//    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
    
//    http:ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
//    /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
    
    NSString *stringName = [_routeName text];
    NSString *stringNumber = [_routeNumber text];
    
    if (![stringName isEqualToString:@""] || ![stringNumber isEqualToString:@""]) {
            
        // Remove objects if text field is empty.
        [[cityBus authorityID] removeAllObjects];
        [[cityBus routeUID] removeAllObjects];
        [[cityBus routeName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        
        // Use NSOperationQueue to background download JSON data.
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:self
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        
        
        // Fix URL encoding. http://blog.csdn.net/andanlan/article/details/53368727
//        NSString *stringNewTaipeiURL = [NSString stringWithFormat:@"http://data.ntpc.gov.tw/od/data/api/67BB3C2B-E7D1-43A7-B872-61B2F082E11B?$format=json&$filter=nameZh eq %@", combineString];
//        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
//        NSString *encodingNewTaipeiURL = [stringNewTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//        NSString *encodingTaipeiURL = [stringTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
//
//        NSURL *taipeiURL = [NSURL URLWithString:encodingTaipeiURL];
//        NSURL *newTaipeiURL = [NSURL URLWithString:encodingNewTaipeiURL];
        
        // Encoding special characters in URL.
        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];

        // Prepare for download Taipei City bus JSON file.
        NSString *stringTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@%@?$orderby=RouteID asc&$format=JSON", stringName, stringNumber];
        NSString *encodingStringTaipei = [stringTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URLTaipei = [NSURL URLWithString:encodingStringTaipei];
        NSURLSessionDownloadTask *downloadTaskTaipei = [session downloadTaskWithURL:URLTaipei];

        // Prepare for download New Taipei City bus JSON file.
        NSString *stringNewTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/NewTaipei/%@%@?$orderby=RouteID asc&$format=JSON", stringName, stringNumber];
        NSString *encodingStringNewTaipei = [stringNewTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSURL *URLNewTiapei = [NSURL URLWithString:encodingStringNewTaipei];
        NSURLSessionDownloadTask *downloadtaskNewTaipei = [session downloadTaskWithURL:URLNewTiapei];
        
        [downloadTaskTaipei resume];
        [downloadtaskNewTaipei resume];
            
        NSLog(@"Start download JSON data...");
    } else {
        
        // Remove objects if text field is empty.
        [[cityBus authorityID] removeAllObjects];
        [[cityBus routeUID] removeAllObjects];
        [[cityBus routeName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        
        // Alert view.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告"
                                                                                 message:@"請輸入路線或號碼後再做搜尋。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [[cityBus routeName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        [_searchBusList reloadData];
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
    
    [_routeName setText:@""];
    [_routeNumber setText:@""];
    
    [[cityBus authorityID] removeAllObjects];
    [[cityBus routeUID] removeAllObjects];
    [[cityBus routeName] removeAllObjects];
    [busStopStartToEnd removeAllObjects];
    [_searchBusList reloadData];
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
    
//    [routeNamePicker setHidden:YES];
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
//                NSString *editedZhTW = [self editStringFromHalfWidthToFullWidth:zhTW];
                NSString *editedDepartureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
                NSString *editedDestinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];
                NSString *departureToDestination = [NSString stringWithFormat:@"%@－%@", editedDepartureStopNameZh, editedDestinationStopNameZh];
                
                if ([authorityID isEqualToString:@"004"]) {
                    
                    [[cityBus authorityID] addObject:@"Taipei"];
                } else if ([authorityID isEqualToString:@"005"]) {
                    
                    [[cityBus authorityID] addObject:@"NewTaipei"];
                }
                
                [[cityBus routeUID] addObject:routeUID];
                [[cityBus routeName] addObject:zhTW];
                [busStopStartToEnd addObject:departureToDestination];
            }
        }
        
        NSLog(@"[cityBus routeUID]: %@", [cityBus routeUID]);
        NSLog(@"[cityBus routeName]: %@", [cityBus routeName]);
    } @catch (NSException *exception) {
        
        NSLog(@"Caught: %@, %@", [exception name], [exception reason]);
    } @finally {
        
        NSLog(@"Download compeleted.");
        
        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        [_searchBusList reloadData];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showBusDetail"]) {
        
        BusDetailViewController *busDetailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [_searchBusList indexPathForSelectedRow];  /*  An index path identifying the row and
                                                                                section of the selected row.    */
        NSString *authorityID = [[cityBus authorityID] objectAtIndex:[indexPath row]];
        NSString *routeName = [[cityBus routeName] objectAtIndex:[indexPath row]];
        NSString *routeUID = [[cityBus routeUID] objectAtIndex:[indexPath row]];

        [busDetailViewController setAuthorityID:authorityID];
        [busDetailViewController setRouteName:routeName];
        [busDetailViewController setRouteUID:routeUID];
//        NSLog(@"routeUID = %@", routeUID);
    }
}


@end
