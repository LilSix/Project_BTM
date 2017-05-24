//
//  SearchViewController.m
//  Project_BTM
//

#import "SearchBusViewController.h"
#import "CityBus.h"


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
        
        routeNameList =@[@"", @"F", @"藍", @"紅", @"棕",
                         @"綠", @"橘", @"內科", @"幹線", @"先導",
                         @"南軟", @"夜間", @"活動", @"市民", @"跳蛙",
                         @"其他", @"臺北觀光巴士"];
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if (searchResults != nil) {
        return [searchResults count];
    }
    
    return [cityBusList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    
    if (searchResults == nil) {
        [[tableViewCell textLabel] setText:[cityBusList objectAtIndex:[indexPath row]]];
//        NSString *stringDepartureStopName = [departureStopName objectAtIndex:[indexPath row]];
//        NSString *stringDestinationStopName = [destinationStopName objectAtIndex:[indexPath row]];
        NSString *stringDetailTextLabel = [busStopStartToEnd objectAtIndex:[indexPath row]];
        [[tableViewCell detailTextLabel] setText:stringDetailTextLabel];
        [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    } else {
        [[tableViewCell textLabel] setText:[searchResults objectAtIndex:[indexPath row]]];
    }
    
    return tableViewCell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"%@", routeNameList);
    
    [_routeNamePicker setDelegate:self];
    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:NO];
    
    return false;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_routeNamePicker setDelegate:self];
    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
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
    
    // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
    // /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
    //        NSURL *url = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/232?$format=JSON"];
    NSURL *taipeiURL = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei?$format=JSON"];
    NSURL *newTaipeiURL = [NSURL URLWithString:@"http://data.ntpc.gov.tw/od/data/api/28D44B55-F429-4D59-A480-418CFB0E561E?$format=json"];
    
    NSData *taipeiData = [NSData dataWithContentsOfURL:taipeiURL];
    NSData *newTaipeiData = [NSData dataWithContentsOfURL:newTaipeiURL];
    
    NSError *error;
    NSArray *taipeiCityBus = [NSJSONSerialization JSONObjectWithData:taipeiData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    NSArray *newTaipeiCityBus = [NSJSONSerialization JSONObjectWithData:newTaipeiData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
    
    for (NSDictionary *dictionary in taipeiCityBus) {
        NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
        NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
        NSString *editLeftParenthesiszhTW = [zhTW stringByReplacingOccurrencesOfString:@"("
                                                                            withString:@"（"];
        NSString *editRightParenthesiszhTW = [editLeftParenthesiszhTW stringByReplacingOccurrencesOfString:@")"
                                                                                                withString:@"）"];
        NSString *editDashzhTW = [editRightParenthesiszhTW stringByReplacingOccurrencesOfString:@"-"
                                                                                     withString:@"－"];
        
        
        
        NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
        NSString *editLeftParenthesisDepartureStopNameZh = [departureStopNameZh stringByReplacingOccurrencesOfString:@"("
                                                                                                          withString:@"（"];
        NSString *editFinishDepartureStopNameZh = [editLeftParenthesisDepartureStopNameZh
                                                        stringByReplacingOccurrencesOfString:@")"
                                                                                  withString:@"）"];
        
        
        NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
        NSString *editLeftParenthesisDestinationStopNameZh = [destinationStopNameZh stringByReplacingOccurrencesOfString:@"("
                                                                                                          withString:@"（"];
        NSString *editFinishDestinationStopNameZh = [editLeftParenthesisDestinationStopNameZh
                                                        stringByReplacingOccurrencesOfString:@")"
                                                                                  withString:@"）"];
        
        NSString *startEnd = [NSString stringWithFormat:@"%@－%@", editFinishDepartureStopNameZh, editFinishDestinationStopNameZh];
        
        [cityBusList addObject:editDashzhTW];
        [busStopStartToEnd addObject:startEnd];
        
    }
    
    for (NSDictionary *dictionary in newTaipeiCityBus) {
        NSString *routeName = [dictionary objectForKey:@"RouteName"];
        NSString *editLeftParenthesisRouteName = [routeName stringByReplacingOccurrencesOfString:@"("
                                                                       withString:@"（"];
        NSString *editRightParenthesisRouteName = [editLeftParenthesisRouteName stringByReplacingOccurrencesOfString:@")"
                                                                       withString:@"）"];
        NSString *editFinishRouteName = [editRightParenthesisRouteName stringByReplacingOccurrencesOfString:@"–"
                                                                             withString:@"－"];
        
        NSString *startEnd = [dictionary objectForKey:@"startend"];
        NSString *editDashStartEnd = [startEnd stringByReplacingOccurrencesOfString:@"-"
                                                                     withString:@"－"];
        NSString *editDashStartEnd2 = [editDashStartEnd stringByReplacingOccurrencesOfString:@"–"
                                                                          withString:@"－"];
        NSString *editLeftParenthesisStartEnd = [editDashStartEnd2 stringByReplacingOccurrencesOfString:@"(" withString:@"（"];
        NSString *editFinishStartEnd = [editLeftParenthesisStartEnd stringByReplacingOccurrencesOfString:@")" withString:@"）"];
        
        
        [cityBusList addObject:editFinishRouteName];
        [busStopStartToEnd addObject:editFinishStartEnd];
        
    }
    
    [_searchResultsList reloadData];
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
