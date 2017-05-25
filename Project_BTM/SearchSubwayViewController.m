//
//  SearchSubwayViewController.m
//  Project_BTM
//

#import "SearchSubwayViewController.h"

@interface SearchSubwayViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *subwayLists;
    NSMutableArray *destinationLists;
}

@property (weak, nonatomic) IBOutlet UITableView *searchResultsList;

@end

@implementation SearchSubwayViewController


#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_searchResultsList setDelegate:self];
    [_searchResultsList setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        subwayLists = [NSMutableArray array];
        destinationLists = [NSMutableArray array];
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
    [[tableViewCell textLabel] setText:[subwayLists objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setText:[destinationLists objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setTextColor:[UIColor grayColor]];
    
    return tableViewCell;
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


#pragma mark - IBAction

- (IBAction)barButtonItemRefreshTouch:(UIBarButtonItem *)sender {
    
    // Remove objects from mutable array before search.
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
            NSString *destination = [NSString stringWithFormat:@"目的地：%@", tempDestination];
            
            NSString *editedStation = [self editStringFromHalfWidthToFullWidth:station];
            NSString *editedDestination = [self editStringFromHalfWidthToFullWidth:destination];
            
            [subwayLists addObject:editedStation];
            [destinationLists addObject:editedDestination];
        }
        
        [_searchResultsList reloadData];
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
