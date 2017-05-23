//
//  SearchViewController.m
//  Project_BTM
//

#import "SearchViewController.h"
#import "CityBus.h"


@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    NSMutableArray *cityBusList;
    NSMutableArray *departureStopName;
    NSMutableArray *destinationStopName;
    NSArray *searchResults;
    NSString *stringURL;
    UISearchController *searchController;
    NSArray *arrayRouteName;
}

@property (weak, nonatomic) IBOutlet UITableView *searchResultsList;

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (strong, nonatomic) IBOutlet UISearchController *searchDisplayController;

@property (weak, nonatomic) IBOutlet UITextField *routeNameTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *routeNamePicker;


@end


#pragma mark -

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [_searchResultsList setDataSource:self];
//    [_searchResultsList setDelegate:self];
//    [searchController setSearchResultsUpdater:self];
    [_routeNameTextField setDelegate:self];
    [_routeNamePicker setDelegate:self];
    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:YES];
    
    arrayRouteName =@[@"1", @"2", @"3", @"4", @"5", @"6"];
    
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
//        arrayRouteName = [NSMutableArray array];

        
        // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
        // /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
//        NSURL *url = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/232?$format=JSON"];
        NSURL *taipeiURL = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei?$format=JSON"];
        NSURL *newTaipeiURL = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/NewTaipei?$format=JSON"];
        
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
            NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
            NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
            
            [cityBusList addObject:zhTW];
            [departureStopName addObject:departureStopNameZh];
            [destinationStopName addObject:destinationStopNameZh];
            
        }
        
        for (NSDictionary *dictionary in newTaipeiCityBus) {
            NSDictionary *routeName = [dictionary objectForKey:@"RouteName"];
            NSString *zhTW = [routeName objectForKey:@"Zh_tw"];
            NSString *departureStopNameZh = [dictionary objectForKey:@"DepartureStopNameZh"];
            NSString *destinationStopNameZh = [dictionary objectForKey:@"DestinationStopNameZh"];
            
            [cityBusList addObject:zhTW];
            [departureStopName addObject:departureStopNameZh];
            [destinationStopName addObject:destinationStopNameZh];
            
        }
//        NSLog(@"results: %@", mutableArrayCityBus);
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (searchResults != nil) {
        return [searchResults count];
    }
    NSLog(@"[arraySearchResult count]: %ld", [searchResults count]);
    return [cityBusList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    
    if (searchResults == nil) {
        [[tableViewCell textLabel] setText:[cityBusList objectAtIndex:[indexPath row]]];
        NSString *stringDepartureStopName = [departureStopName objectAtIndex:[indexPath row]];
        NSString *stringDestinationStopName = [destinationStopName objectAtIndex:[indexPath row]];
        NSString *stringDetailTextLabel = [NSString stringWithFormat:@"%@－%@",
                                           stringDepartureStopName,
                                           stringDestinationStopName];
        [[tableViewCell detailTextLabel] setText:stringDetailTextLabel];
    } else {
        [[tableViewCell textLabel] setText:[searchResults objectAtIndex:[indexPath row]]];
    }
    
    
    return tableViewCell;
}


#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrayRouteName count];
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [arrayRouteName objectAtIndex:row];
}


//#pragma mark - UISearchResultsUpdating
//
//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    if ([searchController isActive]) {
//        NSString *string = [[searchController searchBar] text];
//        NSLog(@"string: %@", string);
//        if ([string length] > 0) {
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
//            searchResults = [cityBusList filteredArrayUsingPredicate:predicate];
//        } else {
//            searchResults = nil;
//        }
//    } else {
//        searchResults = nil;
//    }
//    
//    [_searchResultsList reloadData];
//}


//#pragma mark - UISearchBarDelegate
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    NSString *string = [searchBar text];
//    NSLog(@"string: %@", string);
//    if ([string length] > 0) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
//        searchResults = [cityBusList filteredArrayUsingPredicate:predicate];
//    } else {
//        searchResults = nil;
//    }
//
//}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"%@", arrayRouteName);
    
    [_routeNamePicker setDelegate:self];
    [_routeNamePicker setDataSource:self];
    [_routeNamePicker setHidden:NO];
    
    
    return false;
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
