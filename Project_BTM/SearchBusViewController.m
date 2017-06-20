//
//  SearchViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "SearchBusViewController.h"
#import "BusDetailViewController.h"
#import "CityBus.h"
#import "MBProgressHUD.h"


#pragma mark - Frameworks

@import SystemConfiguration;
@import Foundation;
@import UIKit;
@import CoreGraphics;


#pragma mark -

@interface SearchBusViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    NSMutableArray *cityBusList;
    NSMutableArray *busStopStartToEnd;
    NSArray *searchResults;
    UIPickerView *pickerViewRouteName;
    NSString *cityBusRouteTitle;
    NSString *searchRouteName;
    NSString *searchRouteNumber;
    NSInteger saveDidSelectRow;
}

@property (strong, nonatomic) CityBus *cityBus;
@property (strong, nonatomic) NSArray *routeNameDataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableViewBusList;
@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRouteName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRouteNumber;

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
    _routeNameDataSource = @[@"", @"F", @"小", @"藍", @"紅",
                            @"棕", @"綠", @"橘", @"內科", @"幹線",
                            @"先導", @"南軟", @"夜間", @"活動", @"市民",
                            @"跳蛙", @"其他", @"臺北觀光巴士"];
    
    // Route name text field.
    [_textFieldRouteName setDelegate:self];
    [_textFieldRouteName setInputView:pickerViewRouteName];
    
    // Table view.
    [_tableViewBusList setDelegate:self];
    [_tableViewBusList setDataSource:self];
    
    UIToolbar* toolBar = [[UIToolbar alloc] init];
    [toolBar setBarStyle:UIBarStyleDefault];
    
    // Create toolbar cancel bar button item.
    UIBarButtonItem *barButtonItemCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(barButtonItemCancelTouch)];
    
    // Create toolbar fixed space bar button item.
    UIBarButtonItem *barButtonItemFixedSpace = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:self
                                                action:nil];
    // Create toolbar done bar button item.
    UIBarButtonItem *barButtonItemSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:self
                                                                                         action:@selector(barButtonItemDoneTouch)];
    
    // Put bar button item in array.
    NSArray *arrayToolBarButtonItem = @[barButtonItemCancel, barButtonItemFixedSpace, barButtonItemSearch];
    
    // Setting about toolbar.
    [toolBar sizeToFit];
    [toolBar setItems:arrayToolBarButtonItem];
    [_textFieldRouteName setInputAccessoryView:toolBar];
    [_textFieldRouteNumber setInputAccessoryView:toolBar];
    
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
        
        
        _cityBus = [[CityBus alloc] init];
        [_cityBus setAuthorityID:[NSMutableArray array]];
        [_cityBus setRouteID:[NSMutableArray array]];
        [_cityBus setRouteName:[NSMutableArray array]];
        [_cityBus setDepartureStopName:[NSMutableArray array]];
        [_cityBus setDestinationStopName:[NSMutableArray array]];
        
        saveDidSelectRow = 0;
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    //    NSLog(@"[[cityBus routeName] count]: %ld", [[cityBus routeName] count]);
    return [[_cityBus routeName] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    NSString *cellTextLabel = [self editStringFromHalfWidthToFullWidth:[[_cityBus routeName]
                                                                        objectAtIndex:[indexPath row]]];
    [[tableViewCell textLabel] setText:cellTextLabel];
    
    NSString *cellDetailTextLabel = [NSString stringWithFormat:@"%@－%@",
                                     [[_cityBus departureStopName] objectAtIndex:[indexPath row]],
                                     [[_cityBus destinationStopName] objectAtIndex:[indexPath row]]];
    
    [[tableViewCell detailTextLabel] setText:cellDetailTextLabel];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldShouldBeginEditing:");
    [textField setText:[_routeNameDataSource objectAtIndex:saveDidSelectRow]];
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
    
    return [_routeNameDataSource count];
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    return [_routeNameDataSource objectAtIndex:row];
}


// Called by the picker view when the user selects a row in a component.
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    [_textFieldRouteName setText:[_routeNameDataSource objectAtIndex:row]];
    saveDidSelectRow = row;
}


#pragma mark - IBAction

- (IBAction)buttonSearchTouch:(UIButton *)sender {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
    
    if (![[_textFieldRouteName text] isEqualToString:@""] || ![[_textFieldRouteNumber text] isEqualToString:@""]) {
        
        [self fetchBusDataListWithRouteName:[_textFieldRouteName text] RouteNumber:[_textFieldRouteNumber text]];
    } else {
        
        // Remove objects if text field is empty.
        [[_cityBus authorityID] removeAllObjects];
        [[_cityBus routeID] removeAllObjects];
        [[_cityBus routeName] removeAllObjects];
        [[_cityBus departureStopName] removeAllObjects];
        [[_cityBus destinationStopName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        [_tableViewBusList reloadData];
        
        // Show alert view when two of text field are all empty.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒"
                                                                                 message:@"請先輸入路線或號碼後再做搜尋。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"確認"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)barButtonItemStopTouch:(UIBarButtonItem *)sender {
    
    searchRouteName = @"";
    searchRouteNumber = @"";
    
    [_textFieldRouteName setText:searchRouteName];
    [_textFieldRouteNumber setText:searchRouteNumber];
    
    [[self view] endEditing:YES];
    
    [[_cityBus authorityID] removeAllObjects];
    [[_cityBus routeID] removeAllObjects];
    [[_cityBus routeName] removeAllObjects];
    [[_cityBus departureStopName] removeAllObjects];
    [[_cityBus destinationStopName] removeAllObjects];
    [busStopStartToEnd removeAllObjects];
    [_tableViewBusList reloadData];
}


#pragma mark - UIBarButtonItem Action

- (void)barButtonItemCancelTouch {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}

- (void)barButtonItemDoneTouch {
    
    if ([_textFieldRouteName isEditing]) {
        
        [_textFieldRouteName endEditing:YES];
        [_textFieldRouteNumber becomeFirstResponder];
    } else {
    
        [[self view] endEditing:YES];
        [[self view] resignFirstResponder];
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


#pragma mark - TouchEvent

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
            NSString *routeID = [dictionary objectForKey:@"RouteID"];
            NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
            NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
            NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
            NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
            
            if (![departureStopNameZh isEqualToString:@""]) {
                
                departureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
                destinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];
                
                if ([authorityID isEqualToString:@"004"]) {
                    
                    [[_cityBus authorityID] addObject:@"Taipei"];
                } else if ([authorityID isEqualToString:@"005"]) {
                    
                    [[_cityBus authorityID] addObject:@"NewTaipei"];
                }
                
                [[_cityBus routeID] addObject:routeID];
                [[_cityBus routeName] addObject:zhTW];
                [[_cityBus departureStopName] addObject:departureStopNameZh];
                [[_cityBus destinationStopName] addObject:destinationStopNameZh];
            }
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"Caught: %@, %@", [exception name], [exception reason]);
    } @finally {
        
        [session finishTasksAndInvalidate];
        [downloadTask cancel];
        
        NSLog(@"[cityBus routeID]: %@", [_cityBus routeID]);
        NSLog(@"[cityBus routeName]: %@", [_cityBus routeName]);
        NSLog(@"Download compeleted.");
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [_tableViewBusList reloadData];
            [MBProgressHUD hideHUDForView:[self view] animated:YES];
        }];
    }
}


#pragma mark - FetchBusDataList

- (void)fetchBusDataListWithRouteName:(NSString *)routeName RouteNumber:(NSString *)routeNumber {
    
    if (!([searchRouteName isEqualToString:routeName] &&
          [searchRouteNumber isEqualToString:routeNumber])) {
        
        // Show progress view.
        [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
        
        // Remove all objects before download data.
        [[_cityBus authorityID] removeAllObjects];
        [[_cityBus routeID] removeAllObjects];
        [[_cityBus routeName] removeAllObjects];
        [[_cityBus departureStopName] removeAllObjects];
        [[_cityBus destinationStopName] removeAllObjects];
        [busStopStartToEnd removeAllObjects];
        [_tableViewBusList reloadData];
        
        if ([routeName isEqualToString:@"夜間"]) {
            
            routeName = @"夜";
        }
        
        // Save text field string.
        searchRouteName = routeName;
        searchRouteNumber = routeNumber;
        
        // Fix URL encoding: http://blog.csdn.net/andanlan/article/details/53368727
        // Encoding special characters in URL.
        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        
        // Create background thread to download data.
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSBlockOperation *operationTaipei = [[NSBlockOperation alloc] init];
        NSBlockOperation *operationNewTaipei = [[NSBlockOperation alloc] init];
        [operationTaipei addExecutionBlock:^{
            
            // Use NSOperationQueue to background download JSON data.
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                                  delegate:self
                                                             delegateQueue:[NSOperationQueue currentQueue]];
            
            //    http:ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
            //    /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
            // Prepare for download Taipei City bus JSON file.
            NSString *stringTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@%@?$orderby=RouteID asc&$format=JSON", routeName, routeNumber];
            stringTaipei = [stringTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
            NSURL *URLTaipei = [NSURL URLWithString:stringTaipei];
            NSURLSessionDownloadTask *downloadTaskTaipei = [session downloadTaskWithURL:URLTaipei];
            [downloadTaskTaipei resume];
            
            NSLog(@"downloadTaskTaipei 在第 %@ 幾個執行緒。", [NSThread currentThread]);
        }];
        
        [operationNewTaipei addExecutionBlock:^{
            
            // Use NSOperationQueue to background download JSON data.
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                                  delegate:self
                                                             delegateQueue:[NSOperationQueue currentQueue]];
            
            // Prepare for download New Taipei City bus JSON file.
            NSString *stringNewTaipei = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/NewTaipei/%@%@?$orderby=RouteID asc&$format=JSON", [_textFieldRouteName text], [_textFieldRouteNumber text]];
            stringNewTaipei = [stringNewTaipei stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
            NSURL *URLNewTiapei = [NSURL URLWithString:stringNewTaipei];
            NSURLSessionDownloadTask *downloadTaskNewTaipei = [session downloadTaskWithURL:URLNewTiapei];
            [downloadTaskNewTaipei resume];
            
            NSLog(@"downloadTaskNewTaipei 在第 %@ 幾個執行緒。", [NSThread currentThread]);
        }];
//        [queue addOperation:operationNewTaipei];
        [queue addOperations:@[operationTaipei, operationNewTaipei] waitUntilFinished:YES];
        
        NSLog(@"Start download JSON data...");
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Show Bus Detail"]) {
        
        BusDetailViewController *busDetailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [_tableViewBusList indexPathForSelectedRow];  /*  An index path identifying the row and
                                                                                section of the selected row.    */
        NSString *authorityID = [[_cityBus authorityID] objectAtIndex:[indexPath row]];
        NSString *routeName = [[_cityBus routeName] objectAtIndex:[indexPath row]];
        NSString *routeID = [[_cityBus routeID] objectAtIndex:[indexPath row]];
        NSString *departureStopName = [[_cityBus departureStopName] objectAtIndex:[indexPath row]];
        NSString *destinationStopName = [[_cityBus destinationStopName] objectAtIndex:[indexPath row]];
        
        [busDetailViewController setAuthorityID:authorityID];
        [busDetailViewController setRouteName:routeName];
        [busDetailViewController setRouteID:routeID];
        [busDetailViewController setDepartureStopName:departureStopName];
        [busDetailViewController setDestinationStopName:destinationStopName];
        [busDetailViewController setSelectedStopUID:routeID];
        NSLog(@"[busDetailViewController selectedStopUID]: %@", [busDetailViewController selectedStopUID]);
    }
}


@end
