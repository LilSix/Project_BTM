//
//  SearchSubwayViewController.m
//  Project_BTM
//

#import "SearchSubwayViewController.h"
#import "TaipeiSubway.h"

@interface SearchSubwayViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,
UIPickerViewDataSource, UITextFieldDelegate, UITextFieldDelegate> {
    
    NSMutableArray *subwayLists;
    NSMutableArray *destinationLists;
    UIPickerView *pickerViewRouteName;
    NSString *stringWithSelectedRouteName;
    
    NSURLSessionConfiguration *configuration;
    NSURLSession *session;
}

@property (strong, nonatomic) TaipeiSubway *taipeiSubway;
@property (strong, nonatomic) NSArray *routeNameDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSubwayList;
@property (weak, nonatomic) IBOutlet UITextField *textFieldRouteName;

@end

@implementation SearchSubwayViewController


#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableViewSubwayList setDelegate:self];
    [_tableViewSubwayList setDataSource:nil];
    
    [_textFieldRouteName setDelegate:self];
    
    
    
    pickerViewRouteName = [[UIPickerView alloc] init];
    [pickerViewRouteName setDataSource:self];
    [pickerViewRouteName setDelegate:self];
    [pickerViewRouteName setShowsSelectionIndicator:YES];
    
    _routeNameDataSource = @[@"BR 文湖線", @"R 淡水信義線", @"G 松山新店線", @"O 中和新蘆線", @"BL 板南線"];
    
    [_textFieldRouteName setDelegate:self];
    [_textFieldRouteName setInputView:pickerViewRouteName];
    
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
    
//    [self fetchSubwayDetail];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    
    [_tableViewSubwayList reloadData];
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
        destinationLists = [NSMutableArray array];
        
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
        
        _taipeiSubway = [[TaipeiSubway alloc] init];
        [_taipeiSubway setRouteBR:[NSMutableArray array]];
        [_taipeiSubway setRouteR:[NSMutableArray array]];
        [_taipeiSubway setRouteG:[NSMutableArray array]];
        [_taipeiSubway setRouteO:[NSMutableArray array]];
        [_taipeiSubway setRouteBL:[NSMutableArray array]];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    return [subwayLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[[_taipeiSubway routeBR] objectAtIndex:[indexPath row]]];
//    [[tableViewCell detailTextLabel] setText:[destinationLists objectAtIndex:[indexPath row]]];
//    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
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
}



#pragma mark - IBAction

- (IBAction)barButtonItemRefreshTouch:(UIBarButtonItem *)sender {
    
    // Remove objects from mutable array before search.
    /*
    [subwayLists removeAllObjects];
    [destinationLists removeAllObjects];
    
    NSURL *URL = [NSURL URLWithString:@"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=55ec6d6e-dc5c-4268-a725-d04cc262172b"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSError *error;
    
    if (data != nil) {

        NSDictionary *subwayListsJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&error];
        NSDictionary *result = [subwayListsJSON objectForKey:@"result"];
        NSArray *results = [result objectForKey:@"results"];
        
        for (NSDictionary *dictionary in results) {
            NSString *station = [dictionary objectForKey:@"Station"];
            NSString *tempDestination = [dictionary objectForKey:@"Destination"];
            NSString *destination = [NSString stringWithFormat:@"終點站：%@", tempDestination];
            
            NSString *editedStation = [self editStringFromHalfWidthToFullWidth:station];
            NSString *editedDestination = [self editStringFromHalfWidthToFullWidth:destination];
            
            [subwayLists addObject:editedStation];
            [destinationLists addObject:editedDestination];
        }
        
        [_tableViewSubwayList reloadData];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                                 message:@"No data to display."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
        
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
     */
    
    
    [_tableViewSubwayList reloadData];
    
    NSLog(@"[[_taipeiSubway routeBR] count]: %ld", [[_taipeiSubway routeBR] count]);
}


#pragma mark - UIBarButtonItem Action

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
    
    NSString *stringWithURL = @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=7f5d3c69-1fdc-44a2-a5ef-13cffe323bd6";
    
    if ([routeName isEqualToString:_routeNameDataSource[0]]) {
    
        NSURL *URL = [NSURL URLWithString:stringWithURL];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error) {
                                                    
                                                    [[_taipeiSubway routeBR] removeAllObjects];
                                                    
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
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [_tableViewSubwayList reloadData];
                                                    });
                                                }];
        [dataTask resume];
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
                                                        if (i == 25) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                        }
                                                    }
                                                }];
        [dataTask resume];
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
                                                    for (int i = 43; i <= 71; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        if (i == 71) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                        }
                                                    }
                                                }];
        [dataTask resume];
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
                                                    for (int i = 153; i <= 172; i++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:i];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                        
                                                        if (i == 172) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                        }
                                                    }
                                                    for (int j = 137; j <=141; j++) {
                                                        
                                                        NSDictionary *dictionaryWithArray = [array objectAtIndex:j];
                                                        NSString *stringWithStationA = [dictionaryWithArray objectForKey:@"stationA"];
                                                    }
                                                }];
        [dataTask resume];
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
                                                        if (i == 95) {
                                                            
                                                            NSString *stringWithStationB = [dictionaryWithArray objectForKey:@"stationB"];
                                                        }
                                                    }
                                                }];
        [dataTask resume];
    }
    
    [_tableViewSubwayList reloadData];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidEndEditing.");
}

- (IBAction)buttonSearchTouch:(UIButton *)sender {
    
    if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[0]]) {
        
        [self fetchSubwayDetail:[_textFieldRouteName text]];
    } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[1]]) {
        
        [self fetchSubwayDetail:[_textFieldRouteName text]];
    } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[2]]) {
        
        [self fetchSubwayDetail:[_textFieldRouteName text]];
    } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[3]]) {
        
        [self fetchSubwayDetail:[_textFieldRouteName text]];
    } else if ([[_textFieldRouteName text] isEqualToString:_routeNameDataSource[4]]) {
        
        [self fetchSubwayDetail:[_textFieldRouteName text]];
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
