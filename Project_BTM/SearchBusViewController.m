//
//  SearchViewController.m
//  Project_BTM
//

#import "SearchBusViewController.h"
#import "CityBus.h"

// Framework
@import SystemConfiguration;


@interface SearchBusViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    NSMutableArray *cityBusList;
    NSMutableArray *departureStopName;
    NSMutableArray *destinationStopName;
    
    NSMutableArray *busStopStartToEnd;
    
    NSArray *searchResults;
    NSArray *routeNameList;
    
    
    
//    UIPickerView *routeNamePicker;
}

@property (weak, nonatomic) IBOutlet UITableView *searchResultsList;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (strong, nonatomic) IBOutlet UISearchController *searchDisplayController;

@property (weak, nonatomic) IBOutlet UIButton *buttonSearch;
@property (weak, nonatomic) IBOutlet UITextField *routeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *routeNumberTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *routeNamePicker;


@end


#pragma mark -

@implementation SearchBusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_routeNameTextField setDelegate:self];
//    [_routeNumberTextField setDelegate:self];
    [_routeNumberTextField setTag:6];
    
    
    [_searchResultsList setDelegate:self];
    [_searchResultsList setDataSource:self];
    
    [_routeNamePicker setDelegate:self];
    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        cityBusList = [NSMutableArray array];
        departureStopName = [NSMutableArray array];
        destinationStopName = [NSMutableArray array];
        busStopStartToEnd = [NSMutableArray array];
        
        routeNameList = @[@"", @"藍", @"紅", @"棕", @"綠",
                          @"橘", @"F", @"內科", @"幹線", @"先導",
                          @"南軟", @"夜間", @"活動", @"市民", @"跳蛙",
                          @"其他", @"臺北觀光巴士"];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [cityBusList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[cityBusList objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setText:[busStopStartToEnd objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    NSLog(@"%@", routeNameList);
    
//    [_routeNamePicker setDelegate:self];
//    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:NO];

    return false;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [_routeNamePicker setDelegate:self];
//    [_routeNamePicker setDataSource:self];
    
    [_routeNamePicker setHidden:YES];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
////    [textField resignFirstResponder];
////    [_routeNamePicker setHidden:YES];
//    return YES;
//}


#pragma mark - UIPickerViewDataSource

// Returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// Returns the # of rows in each component.
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    
    return [routeNameList count];
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
    
    [_routeNameTextField setText:routeNameList[row]];
}


#pragma mark - IBAction

- (IBAction)buttonSearchTouch:(UIButton *)sender {
    
    [_routeNamePicker setHidden:YES];
    
    /*  http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
        /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料   */
    
    
    NSString *stringName = [_routeNameTextField text];
    NSString *stringNumber = [_routeNumberTextField text];
    
    NSString *combineString = [NSString stringWithFormat:@"%@%@", stringName, stringNumber];
    
    if ([combineString isEqualToString:@""]) {
        
        // Alert view.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                                 message:@"Please input route number."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        
        // Remove objects from mutablearray before search.
        [cityBusList removeAllObjects];
        [busStopStartToEnd removeAllObjects];

        
        
        
        
        NSString *stringTaipeiURL = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/%@?$format=JSON", combineString];
        
        // Fix URL encoding. http://blog.csdn.net/andanlan/article/details/53368727
        NSString *stringNewTaipeiURL = [NSString stringWithFormat:@"http://data.ntpc.gov.tw/od/data/api/67BB3C2B-E7D1-43A7-B872-61B2F082E11B?$format=json&$filter=nameZh eq %@", combineString];
        NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSString *encodingNewTaipeiURL = [stringNewTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSString *encodingTaipeiURL = [stringTaipeiURL stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        
        NSURL *taipeiURL = [NSURL URLWithString:encodingTaipeiURL];
        NSURL *newTaipeiURL = [NSURL URLWithString:encodingNewTaipeiURL];
        
        NSData *taipeiData = [NSData dataWithContentsOfURL:taipeiURL];
        NSData *newTaipeiData = [NSData dataWithContentsOfURL:newTaipeiURL];
        
        NSError *error;
        NSArray *taipeiCityBus = [NSJSONSerialization JSONObjectWithData:taipeiData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
        NSArray *newTaipeiCityBus = [NSJSONSerialization JSONObjectWithData:newTaipeiData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];
        
        if (taipeiCityBus != nil) {
            
            for (NSDictionary *dictionary in taipeiCityBus) {
                NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
                NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
                NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
                NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
                
                NSString *editedString = [self editStringFromHalfWidthToFullWidth:zhTW];
                NSString *editedDepartureStopNameZh = [self editStringFromHalfWidthToFullWidth:departureStopNameZh];
                NSString *editedDestinationStopNameZh = [self editStringFromHalfWidthToFullWidth:destinationStopNameZh];

                NSString *startEnd = [NSString stringWithFormat:@"%@－%@", editedDepartureStopNameZh, editedDestinationStopNameZh];
                
                [cityBusList addObject:editedString];
                [busStopStartToEnd addObject:startEnd];
            }
        }
        
        
        if (newTaipeiCityBus != nil) {
    
            for (NSDictionary *dictionary in newTaipeiCityBus) {
                
                NSString *nameZh = [dictionary objectForKey:@"nameZh"];
                NSString *departureZh = [dictionary objectForKey:@"departureZh"];
                NSString *destinationZh = [dictionary objectForKey:@"destinationZh"];
                
                NSString *editedString = [self editStringFromHalfWidthToFullWidth:nameZh];
                NSString *editedDepartureZh = [self editStringFromHalfWidthToFullWidth:departureZh];
                NSString *editedDestinationZh = [self editStringFromHalfWidthToFullWidth:destinationZh];
                
                NSString *startEnd = [NSString stringWithFormat:@"%@－%@", editedDepartureZh, editedDestinationZh];
                
                [cityBusList addObject:editedString];
                [busStopStartToEnd addObject:startEnd];
                
            }
        }
    }

    [_searchResultsList reloadData];
}


#pragma mark - Edit String

- (NSString *)editStringFromHalfWidthToFullWidth:(NSString *)string {
    
    NSString *editingString = [string stringByReplacingOccurrencesOfString:@"("
                                                                withString:@"（"];
    NSString *editingString2 = [editingString stringByReplacingOccurrencesOfString:@")"
                                                                        withString:@"）"];
    NSString *editingString3 = [editingString2 stringByReplacingOccurrencesOfString:@"-"
                                                                         withString:@"－"];
    NSString *editingString4 = [editingString3 stringByReplacingOccurrencesOfString:@"–"
                                                                         withString:@"－"];
    NSString *finishString = [editingString4 stringByReplacingOccurrencesOfString:@"/"
                                                                       withString:@"／"];
    
    return finishString;
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
