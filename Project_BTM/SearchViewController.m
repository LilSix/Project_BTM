//
//  SearchViewController.m
//  Project_BTM
//
//  Created by user36 on 2017/5/12.
//  Copyright © 2017年 user36. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating> {

    NSArray *jsonArray;
    UISearchController *mySearchController;
    
}



@end

@implementation SearchViewController

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // /v2/Bus/Route/City/{City}/{RouteName}    取得指定[縣市],[路線名稱]的路線資料
    NSURL *url = [NSURL URLWithString:@"http://ptx.transportdata.tw/MOTC/v2/Bus/Route/City/Taipei/14?$format=JSON"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    for (NSDictionary *jsonDictionary in jsonArray) {
        NSDictionary *routeName = [jsonDictionary objectForKey:@"RouteName"];
        NSDictionary *zhTW = [routeName objectForKey:@"Zh_tw"];
        NSLog(@"Zh_tw: %@", zhTW);
    }
    
    [mySearchController setSearchResultsUpdater:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [jsonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Basic Cell"
                                                                 forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:@"Title"];
    
    return tableViewCell;
}

#pragma mark - UISearchResultsUpdating Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
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
