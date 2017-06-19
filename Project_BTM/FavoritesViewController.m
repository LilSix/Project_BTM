//
//  FavoritesViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "CityBusData.h"
#import "MBProgressHUD.h"


#pragma mark - Frameworks

@import CoreData;
@import Foundation;
@import UIKit;
@import CoreGraphics;


#pragma mark -

@interface FavoritesViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    CityBusData *cityBusData;
    NSMutableArray *favoritesStopName;
    NSMutableArray *favoritesRouteName;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewFavoritesList;

@end


#pragma mark -

@implementation FavoritesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableViewFavoritesList setDelegate:self];
    [_tableViewFavoritesList setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"FavoritesViewController viewWillAppear:");
    [self fetchCoreData];
    [_tableViewFavoritesList reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        cityBusData = [[CityBusData alloc] init];
        favoritesStopName = [NSMutableArray array];
        favoritesRouteName = [NSMutableArray array];
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [favoritesStopName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[favoritesStopName objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setText:[favoritesRouteName objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor lightGrayColor]];
    
    return tableViewCell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *stringWithStopName = [favoritesStopName objectAtIndex:[indexPath row]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self editStringFromHalfWidthToFullWidth:stringWithStopName]
                                                                             message:@"確定將此車站至喜好項目中移除嗎？"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                  style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                                                                    
                                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                                    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
                                                                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityBus"
                                                                                                              inManagedObjectContext:managedObjectContext];
                                                                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                                                                    [fetchRequest setEntity:entity];
                                                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopName = %@", stringWithStopName];
                                                                    [fetchRequest setPredicate:predicate];
                                                                    
                                                                    NSError *error;
                                                                    NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                                                                    
                                                                    for (id object in arrayWithObjects) {
                                                                        
                                                                        [managedObjectContext deleteObject:object];
                                                                    }
                                                                    [managedObjectContext save:nil];
                                                                    
                                                                    [favoritesStopName removeObjectAtIndex:[indexPath row]];
                                                                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                                    [tableView reloadData];
                                                                    
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


#pragma mark - FetchCoreData

- (void)fetchCoreData {
    
    [favoritesStopName removeAllObjects];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CityBus"];
    NSError *error;
    NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([arrayWithObjects count] != 0) {
        
        for (id object in arrayWithObjects) {
            
            [favoritesStopName addObject:[object valueForKey:@"stopName"]];
            [favoritesRouteName addObject:[object valueForKey:@"routeName"]];
        }
    } else {
        
        NSLog(@"[arrayWithObjects count]: 0");
    }
}


#pragma mark - IBAction

- (IBAction)barButtonItemRefreshTouch:(UIBarButtonItem *)sender {
    
//    [_tableViewFavoritesList reloadData];
    NSLog(@"[favoritesStopName count]): %ld", [favoritesStopName count]);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
