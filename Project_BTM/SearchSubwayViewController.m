//
//  SearchSubwayViewController.m
//  Project_BTM
//

#pragma mark - .h Files

#import "SearchSubwayViewController.h"
#import "SubwayDetailViewController.h"
#import "TaipeiSubway.h"
#import "MBProgressHUD.h"
#import "TaipeiSubwayData.h"
#import "AppDelegate.h"


#pragma mark - Frameworks

@import SystemConfiguration;
@import Foundation;
@import UIKit;
@import CoreGraphics;


#pragma mark -

@interface SearchSubwayViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,
UIPickerViewDataSource, UITextFieldDelegate, UITextFieldDelegate> {
    
    NSMutableArray *subwayLists;
    NSMutableDictionary *destinationLists;
    UIPickerView *pickerViewRouteName;
    NSString *stringWithSelectedRouteName;
    
    NSURLSessionConfiguration *configuration;
    NSURLSession *session;
    
    UIColor *colorWithImageViewRoute;
    
    NSInteger saveDidSelectRow;
    int lastDidSelectRow;
}

@property (strong, nonatomic) TaipeiSubway *taipeiSubway;

@property (strong, nonatomic) NSArray *routeNameDataSource;
@property (strong, nonatomic) NSString *departureStopName;
@property (strong, nonatomic) NSString *destinationStopName;
@property (strong, nonatomic) NSString *destinationStopName2;

@property (weak, nonatomic) IBOutlet UITableView *tableViewSubwayList;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRouteBackground;
@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;

@end


#pragma mark -

@implementation SearchSubwayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableViewSubwayList setDelegate:self];
    [_tableViewSubwayList setDataSource:self];
    
    [_textFieldRouteName setDelegate:self];
    
    pickerViewRouteName = [[UIPickerView alloc] init];
    [pickerViewRouteName setDataSource:self];
    [pickerViewRouteName setDelegate:self];
    [pickerViewRouteName setShowsSelectionIndicator:YES];
    
    _routeNameDataSource = @[@"BR 文湖線", @"R 淡水信義線", @"G 松山新店線", @"O 中和新蘆線", @"BL 板南線"];
    
    [_textFieldRouteName setDelegate:self];
    [_textFieldRouteName setInputView:pickerViewRouteName];
    
    [self setInputAccessoryViewWithUIToolbar];
    
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    
//    [_tableViewSubwayList reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        subwayLists = [NSMutableArray array];
        destinationLists = [NSMutableDictionary dictionary];
        
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
        
        _taipeiSubway = [[TaipeiSubway alloc] init];
        [_taipeiSubway setRoute:[NSMutableArray array]];
        [_taipeiSubway setStopID:[NSMutableDictionary dictionary]];
        [_taipeiSubway setRouteBR:[NSMutableArray array]];
        [_taipeiSubway setRouteR:[NSMutableArray array]];
        [_taipeiSubway setRouteG:[NSMutableArray array]];
        [_taipeiSubway setRouteO:[NSMutableArray array]];
        [_taipeiSubway setRouteBL:[NSMutableArray array]];
        
        saveDidSelectRow = 0;
        lastDidSelectRow = 0;
    }
    
    return self;
}


#pragma mark - UIToolbar

- (void)setInputAccessoryViewWithUIToolbar {
    
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
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
 
    [textField setText:[_routeNameDataSource objectAtIndex:saveDidSelectRow]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidEndEditing.");
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    return [[_taipeiSubway route] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[[_taipeiSubway route] objectAtIndex:[indexPath row]]];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id object in [_taipeiSubway route]) {

        NSString *stringWithSubwayStatus = [destinationLists objectForKey:object];
//        NSString *firstObject = [[_taipeiSubway route] firstObject];
//        NSString *lastObject = [[_taipeiSubway route] lastObject];
        if ([stringWithSubwayStatus isEqualToString:_departureStopName]) {
            
            stringWithSubwayStatus = @"▲ 列車停靠中";
            [mutableArray addObject:stringWithSubwayStatus];
        } else if ([stringWithSubwayStatus isEqualToString:_destinationStopName] ||
                   [stringWithSubwayStatus isEqualToString:_destinationStopName2]) {
            
            stringWithSubwayStatus = @"▼ 列車停靠中";
            [mutableArray addObject:stringWithSubwayStatus];
        } else {
            
            stringWithSubwayStatus = @"";
            [mutableArray addObject:stringWithSubwayStatus];
        }
    }
    [[tableViewCell detailTextLabel] setText:[mutableArray objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSString *stringWithStopName = [[_taipeiSubway route] objectAtIndex:[indexPath row]];
    
    UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[self editStringFromHalfWidthToFullWidth:stringWithStopName]
                                                               message:@"確定將此車站加入至常用車站中嗎？"
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                  style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                                                                    
                                                                    TaipeiSubwayData *taipeiSubwayData;
                                                                    taipeiSubwayData = [NSEntityDescription
                                                                                            insertNewObjectForEntityForName:@"TaipeiSubway"
                                                                                                     inManagedObjectContext:managedObjectContext];
                                                                    
                                                                    [taipeiSubwayData setRouteName:[_textFieldRouteName text]];
                                                                    taipeiSubwayData.stopID = [_taipeiSubway.stopID objectForKey:stringWithStopName];
                                                                    [taipeiSubwayData setStopName:stringWithStopName];
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


#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// returns the # of rows in each component..
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
    
    NSLog(@"didSelectRow");
    [_textFieldRouteName setText:_routeNameDataSource[row]];
    saveDidSelectRow = row;
}


#pragma mark - IBAction

- (IBAction)barButtonItemMapTouch:(UIBarButtonItem *)sender {
    
    UIViewController *viewController = [[UIViewController alloc] init];
    NSString *stringWithResource = [[NSBundle mainBundle] pathForResource:@"MetroTaipeiMap" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:stringWithResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)buttonSearchTouch:(UIButton *)sender {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
    [self fetchSubwayArrivedAtStation];
    
    if (![[_textFieldRouteName text] isEqualToString:@""]) {
        
        [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
        if (![[_buttonSearch currentTitleColor] isEqual:[UIColor whiteColor]]) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                [_buttonSearch setTintColor:[UIColor whiteColor]];
            }];
        }
        
        // BR 文湖線
        if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[0]]) {
            
            colorWithImageViewRoute = [UIColor colorWithRed:0.75
                                                      green:0.55
                                                       blue:0.23
                                                      alpha:1.0];
            
            [UIView animateWithDuration:0.5 animations:^{
                
                [_imageViewRouteBackground setBackgroundColor:colorWithImageViewRoute];
            }];
            
            [self fetchSubwayDetail:[_textFieldRouteName text]];
            
        // R 淡水信義線
        } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[1]]) {
            
            colorWithImageViewRoute = [UIColor colorWithRed:0.87
                                                      green:0.05
                                                       blue:0.20
                                                      alpha:1.0];
            [UIView animateWithDuration:0.5 animations:^{
               
                [_imageViewRouteBackground setBackgroundColor:colorWithImageViewRoute];
            }];
            [self fetchSubwayDetail:[_textFieldRouteName text]];
        
        // G 松山新店線
        } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[2]]) {
            
            colorWithImageViewRoute = [UIColor colorWithRed:0.07
                                                      green:0.52
                                                       blue:0.36
                                                      alpha:1.0];
            [UIView animateWithDuration:0.5 animations:^{
                
                [_imageViewRouteBackground setBackgroundColor:colorWithImageViewRoute];
            }];
            [self fetchSubwayDetail:[_textFieldRouteName text]];
            
        // O 中和新蘆線
        } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[3]]) {
            
            colorWithImageViewRoute = [UIColor colorWithRed:0.96
                                                      green:0.71
                                                       blue:0.20
                                                      alpha:1.0];
            [UIView animateWithDuration:0.5 animations:^{
                
                [_imageViewRouteBackground setBackgroundColor:colorWithImageViewRoute];
            }];
            [self fetchSubwayDetail:[_textFieldRouteName text]];
            
        // BL 板南線
        } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[4]]) {
            
            colorWithImageViewRoute = [UIColor colorWithRed:0.06
                                                      green:0.45
                                                       blue:0.73
                                                      alpha:1.0];
            [UIView animateWithDuration:0.5 animations:^{
                
                [_imageViewRouteBackground setBackgroundColor:colorWithImageViewRoute];
            }];
            [self fetchSubwayDetail:[_textFieldRouteName text]];
        }
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒"
                                                                                 message:@"請先選擇捷運路線後再做搜尋。"
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


#pragma mark - UIBarButtonItemAction

- (void)barButtonItemCancelTouch {
    
    [_textFieldRouteName setText:@""];
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}

- (void)barButtonItemDoneTouch {
    
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}



#pragma mark - FetchSubwayDetail

- (void)fetchSubwayDetail:(NSString *)routeName {
    
    [[_taipeiSubway route] removeAllObjects];
    [[_taipeiSubway stopID] removeAllObjects];
    
    NSString *stringWithURL = @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=7f5d3c69-1fdc-44a2-a5ef-13cffe323bd6";
    
    // BR 文湖線（動物園－南港展覽館）
    if ([routeName isEqualToString:_routeNameDataSource[0]]) {
        
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
        
                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingMutableContainers
                                                                                                                 error:&error];
                                                    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
                                                    NSArray *array = [dictionaryInResult objectForKey:@"results"];
                                                    
                                                    // "_id" for array index.
                                                    for (int i = 114; i <= 136; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [[_taipeiSubway route] addObject:stringWithStationA];
                                                        if (i == 136) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                            stringWithStationB = [self editStringFromHalfWidthToFullWidth:stringWithStationB];
                                                            [[_taipeiSubway route] addObject:stringWithStationB];
                                                        }
                                                    }
                                                    [_taipeiSubway setRoute:[[[[_taipeiSubway route] reverseObjectEnumerator] allObjects] mutableCopy]];
                                                    
                                                    int i = 1;
                                                    NSString *stringWithID;
                                                    for (id object in [_taipeiSubway route]) {
                                                        
                                                        if (i < 10) {
                                                            stringWithID = [NSString stringWithFormat:@"BR0%d", i];
                                                        } else {
                                                            stringWithID = [NSString stringWithFormat:@"BR%d", i];
                                                        }
                                                        [[_taipeiSubway stopID] setObject:stringWithID forKey:object];
                                                        i++;
                                                    }
                                                    
                                                    _departureStopName = [[_taipeiSubway route] firstObject];
                                                    _destinationStopName = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                        [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                    }];
                                                }];
        [dataTask resume];
   
    // R 淡水信義線
    } else if ([routeName isEqualToString:_routeNameDataSource[1]]) {
        
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingMutableContainers
                                                                                                                 error:&error];
                                                    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
                                                    NSArray *array = [dictionaryInResult objectForKey:@"results"];
                                                    for (int i = 0; i <= 25; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [[_taipeiSubway route] addObject:stringWithStationA];
                                                        if (i == 25) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                            stringWithStationB = [self editStringFromHalfWidthToFullWidth:stringWithStationB];
                                                            [[_taipeiSubway route] addObject:stringWithStationB];
                                                        }
                                                    }
                                                    [_taipeiSubway setRoute:[[[[_taipeiSubway route] reverseObjectEnumerator] allObjects] mutableCopy]];
                                                    
                                                    int i = 2;
                                                    NSString *stringWithID;
                                                    for (id object in [_taipeiSubway route]) {
                                                        
                                                        if (i < 10) {
                                                            stringWithID = [NSString stringWithFormat:@"R0%d", i];
                                                        } else {
                                                            stringWithID = [NSString stringWithFormat:@"R%d", i];
                                                        }
                                                        [[_taipeiSubway stopID] setObject:stringWithID forKey:object];
                                                        i++;
                                                    }
                                                    
                                                    _departureStopName = [[_taipeiSubway route] firstObject];
                                                    _destinationStopName = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                        [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                    }];
                                                }];
        [dataTask resume];
    
    // G 松山新店線
    } else if ([routeName isEqualToString:_routeNameDataSource[2]]) {
        
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingMutableContainers
                                                                                                                 error:&error];
                                                    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
                                                    NSArray *array = [dictionaryInResult objectForKey:@"results"];
                                                    for (int i = 43; i <= 60; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [[_taipeiSubway route] addObject:stringWithStationA];
                                                        if (i == 60) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                            stringWithStationB = [self editStringFromHalfWidthToFullWidth:stringWithStationB];
                                                            [[_taipeiSubway route] addObject:stringWithStationB];
                                                        }
                                                    }
                                                    [_taipeiSubway setRoute:[[[[_taipeiSubway route] reverseObjectEnumerator] allObjects] mutableCopy]];
                                                    
                                                    int i = 1;
                                                    NSString *stringWithID;
                                                    for (id object in [_taipeiSubway route]) {
                                                        
                                                        if (i < 10) {
                                                            stringWithID = [NSString stringWithFormat:@"G0%d", i];
                                                        } else {
                                                            stringWithID = [NSString stringWithFormat:@"G%d", i];
                                                        }
                                                        [[_taipeiSubway stopID] setObject:stringWithID forKey:object];
                                                        i++;
                                                    }
                                                    
                                                    _departureStopName = [[_taipeiSubway route] firstObject];
                                                    _destinationStopName = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                        [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                    }];
                                                }];
        [dataTask resume];
    
    // O 中和新蘆線
    } else if ([routeName isEqualToString:_routeNameDataSource[3]]) {
        
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingMutableContainers
                                                                                                                 error:&error];
                                                    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
                                                    NSArray *array = [dictionaryInResult objectForKey:@"results"];
                                                    
                                                    // 南勢角－迴龍
                                                    for (int i = 153; i <= 172; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [[_taipeiSubway route] addObject:stringWithStationA];
                                                        if (i == 172) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                            stringWithStationB = [self editStringFromHalfWidthToFullWidth:stringWithStationB];
                                                            [[_taipeiSubway route] addObject:stringWithStationB];
                                                        }
                                                    }
                                                    [_taipeiSubway setRoute:[[[[_taipeiSubway route] reverseObjectEnumerator] allObjects] mutableCopy]];
                                                    
                                                    _departureStopName = [[_taipeiSubway route] firstObject];
                                                    _destinationStopName = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    // 三重國小－蘆洲
                                                    NSMutableArray *mutableArray = [NSMutableArray array];
                                                    for (int j = 137; j <=141; j++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:j];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [mutableArray addObject:stringWithStationA];
                                                    }
                                                    mutableArray = mutableArray.reverseObjectEnumerator.allObjects.mutableCopy;
                                                    for (id object in mutableArray) {
                                                        
                                                        [[_taipeiSubway route] addObject:object];
                                                    }
                                                    
                                                    int i = 1;
                                                    NSString *stringWithID;
                                                    for (id object in [_taipeiSubway route]) {
                                                        
                                                        if (i < 10) {
                                                            
                                                            stringWithID = [NSString stringWithFormat:@"O0%d", i];
                                                        } else if (i > 21) {

                                                            stringWithID = [NSString stringWithFormat:@"O%d", i + 28];
                                                        } else {
                                                            
                                                            stringWithID = [NSString stringWithFormat:@"O%d", i];
                                                        }
                                                        [[_taipeiSubway stopID] setObject:stringWithID forKey:object];
                                                        i++;
                                                    }
                                                    
                                                    _destinationStopName2 = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                        [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                    }];
                                                }];
        [dataTask resume];
        
    // BL 板南線
    } else if ([routeName isEqualToString:_routeNameDataSource[4]]) {
        
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingMutableContainers
                                                                                                                 error:&error];
                                                    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
                                                    NSArray *array = [dictionaryInResult objectForKey:@"results"];
                                                    for (int i = 74; i <= 95; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        stringWithStationA = [self editStringFromHalfWidthToFullWidth:stringWithStationA];
                                                        [[_taipeiSubway route] addObject:stringWithStationA];
                                                        if (i == 95) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                            stringWithStationB = [self editStringFromHalfWidthToFullWidth:stringWithStationB];
                                                            [[_taipeiSubway route] addObject:stringWithStationB];
                                                        }
                                                    }
                                                    [_taipeiSubway setRoute:[[[[_taipeiSubway route] reverseObjectEnumerator] allObjects] mutableCopy]];
                                                    
                                                    int i = 1;
                                                    NSString *stringWithID;
                                                    for (id object in [_taipeiSubway route]) {
                                                        
                                                        if (i < 10) {
                                                            stringWithID = [NSString stringWithFormat:@"BL0%d", i];
                                                        } else {
                                                            stringWithID = [NSString stringWithFormat:@"BL%d", i];
                                                        }
                                                        [[_taipeiSubway stopID] setObject:stringWithID forKey:object];
                                                        i++;
                                                    }
                                                    
                                                    _departureStopName = [[_taipeiSubway route] firstObject];
                                                    _destinationStopName = [[_taipeiSubway route] lastObject];
//                                                    [self fetchSubwayArrivedAtStation];
                                                    
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                        [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                    }];
                                                }];
        [dataTask resume];
    }
}

- (NSMutableDictionary *)fetchSubwayArrivedAtStation {
    
    // Remove objects from mutable array before search.
    [subwayLists removeAllObjects];
    [destinationLists removeAllObjects];
    [[self view] isFirstResponder];
    
    NSURL *URL = [NSURL URLWithString:@"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=55ec6d6e-dc5c-4268-a725-d04cc262172b"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                
                                                NSDictionary *subwayListsJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                options:NSJSONReadingMutableContainers
                                                                                                                  error:&error];
                                                NSDictionary *result = [subwayListsJSON objectForKey:@"result"];
                                                NSArray *results = [result objectForKey:@"results"];
                                                
                                                for (NSDictionary *dictionary in results) {
                                                    NSString *station = [dictionary objectForKey:@"Station"];
                                                    NSString *destination = [dictionary objectForKey:@"Destination"];
//                                                    NSString *destination = [NSString stringWithFormat:@"終點站：%@", tempDestination];
                                                    
                                                    station = [NSString stringWithFormat:@"捷運%@", station];
                                                    destination = [NSString stringWithFormat:@"捷運%@", destination];
                                                    
                                                    [destinationLists setObject:destination forKey:station];
//                                                    _destinationStopName = [NSString stringWithFormat:@"捷運%@", _destinationStopName];
//                                                    _destinationStopName2 = [NSString stringWithFormat:@"捷運%@", _destinationStopName2];
                                                    
//                                                    if ([destination isEqualToString:_departureStopName]) {
//                                                        
//                                                        NSString *stringWithSuwayStatus = @"▲ 列車到站中";
//                                                        [destinationLists setObject:stringWithSuwayStatus forKey:station];
//                                                    }
//                                                    
//                                                    if ([destination isEqualToString:_destinationStopName]) {
//                                                        
//                                                        NSString *stringWithSuwayStatus = @"▼ 列車到站中";
//                                                        [destinationLists setObject:stringWithSuwayStatus forKey:station];
//                                                    }
//                                                    
//                                                    if ([destination isEqualToString:_destinationStopName2]) {
//                                                        
//                                                        NSString *stringWithSuwayStatus = @"▼ 列車到站中";
//                                                        [destinationLists setObject:stringWithSuwayStatus forKey:station];
//                                                    }
                                                }
//                                                
//                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                                    
//                                                    [_tableViewSubwayList reloadData];
//                                                    [MBProgressHUD hideHUDForView:[self view] animated:YES];
//                                                }];
                                            }];
    [dataTask resume];
    
    return destinationLists;
}



/*
#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    NSDictionary *dictionaryInResult = [dictionary objectForKey:@"result"];
    NSArray *array = [dictionaryInResult objectForKey:@"results"];
    for (int i = 114; i <= 136; i++) {
        
        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
        [[_taipeiSubway routeBR] addObject:stringWithStationA];
        if (i == 136) {
            
            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
            [[_taipeiSubway routeBR] addObject:stringWithStationB];
        }
    }
    
    [_taipeiSubway setRouteBR:[[[[_taipeiSubway routeBR] reverseObjectEnumerator] allObjects] mutableCopy]];
    [_tableViewSubwayList reloadData];
    
}
*/




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Show Subway Detail"]) {
        
        SubwayDetailViewController *subwayDetailViewController = [segue destinationViewController];
        [subwayDetailViewController setColorWithSelectedRoute:colorWithImageViewRoute];
    }
    
    
}


@end
