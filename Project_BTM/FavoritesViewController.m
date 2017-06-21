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
    SearchSubwayViewController *searchSubwayVC;
    TaipeiSubwayData *taipeiSubwayData;
    
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
    
    NSString *selectedDepartureStopName;
    NSString *selectedDestinationStopName;
    
    NSIndexPath *indexPathSelected;
//    NSMutableDictionary *destinationLists;
}

@property (strong, nonatomic) NSMutableDictionary *destinationLists;
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
    
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    
    [_segmentedControlBusSubway setSelectedSegmentIndex:0];
    
    
    _destinationLists = [self fetchSubwayArrivedAtStation];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"FavoritesViewController viewWillAppear:");
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
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
        
        _destinationLists = [NSMutableDictionary dictionary];
        searchSubwayVC = [[SearchSubwayViewController alloc] init];
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
        
        [tableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [[tableViewCell textLabel] setText:[favoritesBusStopName objectAtIndex:[indexPath row]]];
        
        NSString *departureStopName = [favoritesBusDepartureStopName objectAtIndex:[indexPath row]];
        NSString *destinationStopName = [favoritesBusDestinationStopName objectAtIndex:[indexPath row]];
        NSString *routeName = [favoritesBusRouteName objectAtIndex:[indexPath row]];
        NSString *stringWithDetailTextLabel = [NSString stringWithFormat:@"%@（%@－%@）", routeName, departureStopName, destinationStopName];
        
        [[tableViewCell detailTextLabel] setText:stringWithDetailTextLabel];
        [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    } else {
        
        [tableViewCell setAccessoryType:UITableViewCellAccessoryNone];
        
        NSString *stationStatus;
        NSMutableArray *mutableArray = [NSMutableArray array];
        _destinationLists = [self fetchSubwayArrivedAtStation];
        for (id object in favoritesSubwayStopName) {
            
            stationStatus = [_destinationLists objectForKey:object];
            if (stationStatus != nil) {
                
                stationStatus = [NSString stringWithFormat:@"列車停靠中（往：%@）", stationStatus];
                [mutableArray addObject:stationStatus];
            } else {
                
                stationStatus = @"列車尚未到站";
                [mutableArray addObject:stationStatus];
            }
        }
        
        [[tableViewCell textLabel] setText:[favoritesSubwayStopName objectAtIndex:[indexPath row]]];
        [[tableViewCell detailTextLabel] setText:[mutableArray objectAtIndex:[indexPath row]]];
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
    if ([_segmentedControlBusSubway selectedSegmentIndex] == 0) {
        
        BusDetailViewController *busDetailVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"BusDetailID"];
        [busDetailVC setAuthorityID:[favoritesBusAuthorityID objectAtIndex:[indexPath row]]];
        [busDetailVC setRouteID:[favoritesBusRouteID objectAtIndex:[indexPath row]]];
        [busDetailVC setRouteName:[favoritesBusRouteName objectAtIndex:[indexPath row]]];
        [busDetailVC setDepartureStopName:[favoritesBusDepartureStopName objectAtIndex:[indexPath row]]];
        [busDetailVC setDestinationStopName:[favoritesBusDestinationStopName objectAtIndex:[indexPath row]]];
        [[self navigationController] pushViewController:busDetailVC animated:YES];
    } else {
        
//        SearchSubwayViewController *searchSubwayVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"SearchSubwayID"];
//        [searchSubwayVC setTextFieldRouteName:[favoritesSubwayRouteName objectAtIndex:[indexPath row]]];
//        [[self navigationController] pushViewController:searchSubwayVC animated:YES];
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
    
    NSLog(@"_destinationLists = %@", _destinationLists);
    NSLog(@"[favoritesBusStopName count]): %ld", [favoritesBusStopName count]);
    NSLog(@"[favoritesSubwayStopName count]): %ld", [favoritesSubwayStopName count]);
}


- (IBAction)segmentedControlBusSubwayTouch:(UISegmentedControl *)sender {
    
    if ([sender selectedSegmentIndex] == 0) {
        
        [[self navigationItem] setRightBarButtonItem:nil];
        [_tableViewFavoritesList reloadData];
    } else {
        
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        UIBarButtonItem *barButtonItemRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchSubwayArrivedAtStation)];
        [[self navigationItem] setRightBarButtonItem:barButtonItemRefresh];
        
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


#pragma mark - FetchSubwayArrivedAtStation

- (NSMutableDictionary *)fetchSubwayArrivedAtStation {
    
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
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
                                                    
                                                    [_destinationLists setObject:destination forKey:station];
                                                }
                                                
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    
                                                    [MBProgressHUD hideHUDForView:[self view] animated:YES];
                                                }];
                                            }];
    [dataTask resume];
    
    return _destinationLists;
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
        
            searchSubwayVC = [segue destinationViewController];
        }
}

@end
