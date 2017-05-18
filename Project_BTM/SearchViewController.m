//
//  SearchViewController.m
//  Project_BTM
//
//  Created by user36 on 2017/5/12.
//  Copyright © 2017年 user36. All rights reserved.
//

#import "SearchViewController.h"
#import "CityBus.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate> {
    NSMutableArray *mutableArrayCityBus;
    NSArray *arraySearchResult;
    NSString *stringURL;
    UISearchController *mySearchController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewSearchResult;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableViewSearchResult setDataSource:self];
    [_tableViewSearchResult setDelegate:self];
    [mySearchController setSearchResultsUpdater:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Method

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        mutableArrayCityBus = [NSMutableArray array];
//        mutableArraySearchResult = [NSMutableArray array];
        
        // http://ptx.transportdata.tw/MOTC/Swagger/#!/CityBusApi/CityBusApi_Route_0
        // /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
//        NSURL *url = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/232?$format=JSON"];
        NSURL *url = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei?$format=JSON"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        for (NSDictionary *jsonDictionary in jsonArray) {
            NSDictionary *routeName = [jsonDictionary objectForKey:@"RouteName"];
            NSString *zhTW = [routeName objectForKey:@"Zh_tw"];

            [mutableArrayCityBus addObject:zhTW];
            
        }
//        NSLog(@"results: %@", mutableArrayCityBus);
    }
    return self;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (arraySearchResult != nil) {
        return [arraySearchResult count];
    }
    NSLog(@"[arraySearchResult count]: %ld", [arraySearchResult count]);
    return [mutableArrayCityBus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Basic Cell"
                                                                     forIndexPath:indexPath];
    
    if (arraySearchResult == nil) {
        [[tableViewCell textLabel] setText:[mutableArrayCityBus objectAtIndex:[indexPath row]]];
    } else {
        [[tableViewCell textLabel] setText:[arraySearchResult objectAtIndex:[indexPath row]]];
    }
    
    
    return tableViewCell;
}

#pragma mark - UISearchResultsUpdating Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([searchController isActive]) {
        NSString *string = [[searchController searchBar] text];
        NSLog(@"string: %@", string);
        if ([string length] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
            arraySearchResult = [mutableArrayCityBus filteredArrayUsingPredicate:predicate];
        } else {
            arraySearchResult = nil;
        }
    } else {
        arraySearchResult = nil;
    }
    
    [_tableViewSearchResult reloadData];
}

#pragma mark - UIBarPositioningDelegate Method

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSString *string = [searchBar text];
    NSLog(@"string: %@", string);
    if ([string length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
        arraySearchResult = [mutableArrayCityBus filteredArrayUsingPredicate:predicate];
    } else {
        arraySearchResult = nil;
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
