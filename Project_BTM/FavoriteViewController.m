//
//  FavoriteViewController.m
//  Project_BTM
//
//  Created by user36 on 2017/5/11.
//  Copyright © 2017年 user36. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *mutableArrayFavorite;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewFavorite;

@end

@implementation FavoriteViewController

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self tableViewFavorite] setDataSource:self];
    [[self tableViewFavorite] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InitWithCoder Method

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        mutableArrayFavorite = [NSMutableArray array];
    }
    return self;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Basic Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:@"Title"];
    
    return tableViewCell;
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
