//
//  FavoritesViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "CityBusData.h"
#import "MBProgressHUD.h"
#import "TaipeiSubwayData.h"
#import "BusDetailViewController.h"
#import "SearchBusViewController.h"
#import "SearchSubwayViewController.h"


#pragma mark - Frameworks

@import CoreData;
@import Foundation;
@import UIKit;
@import CoreGraphics;


#pragma mark -

@interface FavoritesViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    CityBusData *cityBusData;
    TaipeiSubwayData *taipeiSubwayData;
    BusDetailViewController *busDetailVC;
    
    NSMutableArray *favoritesBusStopID;
    NSMutableArray *favoritesBusStopName;
    NSMutableArray *favoritesBusRouteID;
    NSMutableArray *favoritesBusRouteName;
    NSMutableArray *favoritesBusDepartureStopName;
    NSMutableArray *favoritesBusDestinationStopName;
    NSMutableArray *favoritesBusAuthorityID;
    
    
    NSMutableArray *favoritesSubwayStopID;
    NSMutableArray *favoritesSubwayStopName;
    NSMutableArray *favoritesSubwayRouteName;
    
    NSMutableDictionary *destinationLists;
    NSString *selectedDepartureStopName;
    NSString *selectedDestinationStopName;
    
    NSIndexPath *indexPathSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewFavoritesList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlBusSubway;

@end


#pragma mark -

@implementation FavoritesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableViewFavoritesList setDelegate:self];
    [_tableViewFavoritesList setDataSource:self];
    
    [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
    
    [_segmentedControlBusSubway setSelectedSegmentIndex:0];
    
//    destinationLists = [searchSubwayViewController fetchSubwayArrivedAtStation];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"FavoritesViewController viewWillAppear:");
    [self fetchBusCoreData];
    [self fetchSubwayCoreData];
    [_tableViewFavoritesList reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [_tableViewFavoritesList setEditing:editing animated:animated];
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        cityBusData = [[CityBusData alloc] init];
        favoritesBusStopName = [NSMutableArray array];
        favoritesBusRouteID = [NSMutableArray array];
        favoritesBusRouteName = [NSMutableArray array];
        favoritesBusDepartureStopName = [NSMutableArray array];
        favoritesBusDestinationStopName = [NSMutableArray array];
        favoritesBusAuthorityID = [NSMutableArray array];
        favoritesBusStopID = [NSMutableArray array];
        
        taipeiSubwayData = [[TaipeiSubwayData alloc] init];
        favoritesSubwayStopID = [NSMutableArray array];
        favoritesSubwayStopName = [NSMutableArray array];
        favoritesSubwayRouteName = [NSMutableArray array];
        
        destinationLists = [NSMutableDictionary dictionary];
        
        busDetailVC = [[BusDetailViewController alloc] init];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    if ([_segmentedControlBusSubway selectedSegmentIndex] == 0) {
        
        return [favoritesBusStopName count];
    }
    
    return [favoritesSubwayStopName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Subtitle Cell"
                                                                     forIndexPath:indexPath];
    [tableViewCell setShowsReorderControl:YES];
    
    if ([_segmentedControlBusSubway selectedSegmentIndex] == 0) {
        
        [[tableViewCell textLabel] setText:[favoritesBusStopName objectAtIndex:[indexPath row]]];
        
        NSString *departureStopName = [favoritesBusDepartureStopName objectAtIndex:[indexPath row]];
        NSString *destinationStopName = [favoritesBusDestinationStopName objectAtIndex:[indexPath row]];
        NSString *routeName = [favoritesBusRouteName objectAtIndex:[indexPath row]];
        NSString *stringWithDetailTextLabel = [NSString stringWithFormat:@"%@（%@－%@）", routeName, departureStopName, destinationStopName];
        
        [[tableViewCell detailTextLabel] setText:stringWithDetailTextLabel];
        [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    } else {
        
        [[tableViewCell textLabel] setText:[favoritesSubwayStopName objectAtIndex:[indexPath row]]];
        [[tableViewCell detailTextLabel] setText:[favoritesSubwayRouteName objectAtIndex:[indexPath row]]];
        [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    }
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    if ([_segmentedControlBusSubway selectedSegmentIndex] == 0) {
        
        if (editingStyle == UITableViewCellEditingStyleDelete){
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CityBus"
                                                      inManagedObjectContext:managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            NSString *stringWithStopID = [favoritesBusStopID objectAtIndex:[indexPath row]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopID = %@", stringWithStopID];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            for (id object in arrayWithObjects) {
                
                [managedObjectContext deleteObject:object];
            }
            [managedObjectContext save:nil];
            
            
            [self fetchBusCoreData];
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
        }
    } else {
        
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TaipeiSubway"
                                       inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        NSString *stringWithStopID = [favoritesSubwayStopID objectAtIndex:[indexPath row]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopID = %@", stringWithStopID];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (id object in arrayWithObjects) {
            
            [managedObjectContext deleteObject:object];
        }
        [managedObjectContext save:nil];
        
        [self fetchSubwayCoreData];
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
    }
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    if ([_segmentedControlBusSubway selectedSegmentIndex] == 0) {
        
        
//        [self performSegueWithIdentifier:@"showBusDetail" sender:self];
        BusDetailViewController *bdvc = [[self storyboard] instantiateViewControllerWithIdentifier:@"BusDetailID"];
        [bdvc setAuthorityID:[favoritesBusAuthorityID objectAtIndex:[indexPath row]]];
        [bdvc setRouteID:[favoritesBusRouteID objectAtIndex:[indexPath row]]];
        [bdvc setRouteName:[favoritesBusRouteName objectAtIndex:[indexPath row]]];
        [bdvc setDepartureStopName:[favoritesBusDepartureStopName objectAtIndex:[indexPath row]]];
        [bdvc setDestinationStopName:[favoritesBusDestinationStopName objectAtIndex:[indexPath row]]];
        
        
//        indexPathSelected = indexPath;
//        [self performSegueWithIdentifier:@"showBusDetail" sender:self];
        [[self navigationController] pushViewController:bdvc animated:YES];
        
        
//        BusDetailViewController *busDetailVC = [[BusDetailViewController alloc] init];
//        
//        UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"showBusDetail"
//                                                                          source:self
//                                                                     destination:busDetailVC];
//        [self prepareForSegue:segue sender:self];
        
        /*
        NSString *stringWithStopName = [favoritesBusStopName objectAtIndex:[indexPath row]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self editStringFromHalfWidthToFullWidth:stringWithStopName]
                                                                                 message:@"確定將此車站自常用車站中移除嗎？"
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                      style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction *action) {
                                                                        
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

                                                                        [self fetchBusCoreData];
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
        */

    } else {
        
//        [self performSegueWithIdentifier:@"showSubwayDetail" sender:self];
        
        /*
        NSString *stringWithStopID = [favoritesSubwayStopID objectAtIndex:[indexPath row]];
        NSString *stringWithStopName = [favoritesSubwayStopName objectAtIndex:[indexPath row]];
        
        UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:[self editStringFromHalfWidthToFullWidth:stringWithStopName]
                                                                   message:@"確定將此車站自常用車站中移除嗎？"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertActionWithDone = [UIAlertAction actionWithTitle:@"確定"
                                                                      style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction *action) {
                                                                        
                                                                        NSEntityDescription *entity = [NSEntityDescription
                                                                                                           entityForName:@"TaipeiSubway"
                                                                                                           inManagedObjectContext:managedObjectContext];
                                                                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                                                                        [fetchRequest setEntity:entity];
                                                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopID = %@", stringWithStopID];
                                                                        [fetchRequest setPredicate:predicate];
                                                                        
                                                                        NSError *error;
                                                                        NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                                                                        
                                                                        for (id object in arrayWithObjects) {
                                                                            
                                                                            [managedObjectContext deleteObject:object];
                                                                        }
                                                                        [managedObjectContext save:nil];
        
                                                                        [self fetchSubwayCoreData];
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
         */
    }
}


#pragma mark - FetchCoreData

- (void)fetchBusCoreData {
    
    [favoritesBusStopName removeAllObjects];
    [favoritesBusRouteName removeAllObjects];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CityBus"];
    NSError *error;
    NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([arrayWithObjects count] != 0) {
        
        for (id object in arrayWithObjects) {
            
            [favoritesBusStopID addObject:[object valueForKey:@"stopID"]];
            [favoritesBusStopName addObject:[object valueForKey:@"stopName"]];
            [favoritesBusRouteName addObject:[object valueForKey:@"routeName"]];
            [favoritesBusDepartureStopName addObject:[object valueForKey:@"departureStopName"]];
            [favoritesBusDestinationStopName addObject:[object valueForKey:@"destinationStopName"]];
            [favoritesBusRouteID addObject:[object valueForKey:@"routeID"]];
            [favoritesBusAuthorityID addObject:[object valueForKey:@"authorityID"]];
        }
    } else {
        
        NSLog(@"fetchBusCoreData [arrayWithObjects count]: 0");
    }
}

- (void)fetchSubwayCoreData {
    
    [favoritesSubwayStopID removeAllObjects];
    [favoritesSubwayStopName removeAllObjects];
    [favoritesSubwayRouteName removeAllObjects];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TaipeiSubway"];
    NSError *error;
    NSArray *arrayWithObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([arrayWithObjects count] != 0) {
        
        for (id object in arrayWithObjects) {
            
            [favoritesSubwayStopID addObject:[object valueForKey:@"stopID"]];
            [favoritesSubwayStopName addObject:[object valueForKey:@"stopName"]];
            [favoritesSubwayRouteName addObject:[object valueForKey:@"routeName"]];
        }
    } else {
        
        NSLog(@"fetchSubwayCoreData [arrayWithObjects count]: 0");
    }
}


#pragma mark - IBAction

- (IBAction)barButtonItemRefreshTouch:(UIBarButtonItem *)sender {
    
    NSLog(@"[favoritesBusStopName count]): %ld", [favoritesBusStopName count]);
    NSLog(@"[favoritesSubwayStopName count]): %ld", [favoritesSubwayStopName count]);
}


- (IBAction)segmentedControlBusSubwayTouch:(UISegmentedControl *)sender {
    
    if ([sender selectedSegmentIndex] == 0) {
        
        [_tableViewFavoritesList reloadData];
    } else {
        
        [_tableViewFavoritesList reloadData];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
//    if ([[segue identifier] isEqualToString:@"showBusDetail"]) {
//        
//        busDetailVC = [segue destinationViewController];
//        [busDetailVC setAuthorityID:[favoritesBusAuthorityID objectAtIndex:[indexPathSelected row]]];
//        [busDetailVC setRouteID:[favoritesBusRouteID objectAtIndex:[indexPathSelected row]]];
//        [busDetailVC setRouteName:[favoritesBusRouteName objectAtIndex:[indexPathSelected row]]];
//        [busDetailVC setDepartureStopName:[favoritesBusDepartureStopName objectAtIndex:[indexPathSelected row]]];
//        [busDetailVC setDestinationStopName:[favoritesBusDestinationStopName objectAtIndex:[indexPathSelected row]]];
//        
//    } else
    
        if ([[segue identifier] isEqualToString:@"showSubwayDetail"]) {
        
        SearchSubwayViewController *searchSubwayViewController = [[SearchSubwayViewController alloc] init];
        searchSubwayViewController = [segue destinationViewController];
    }
}

@end
