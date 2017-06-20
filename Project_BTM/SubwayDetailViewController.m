//
//  SubwayDetailViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "SubwayDetailViewController.h"
#import "TaipeiSubway.h"


#pragma mark -

@interface SubwayDetailViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *subwayLists;
    NSMutableArray *destinationLists;
}

@property (strong, nonatomic) TaipeiSubway *taipeiSubway;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSubwayDetailList;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewRouteBackground;

@end


#pragma mark -

@implementation SubwayDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_imageViewRouteBackground setBackgroundColor:_colorWithSelectedRoute];
    
    [_tableViewSubwayDetailList setDelegate:self];
    [_tableViewSubwayDetailList setDataSource:self];
    
    // Remove objects from mutable array before search.
     [subwayLists removeAllObjects];
     [destinationLists removeAllObjects];
     [[self view] isFirstResponder];
     
     NSURL *URL = [NSURL URLWithString:@"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=55ec6d6e-dc5c-4268-a725-d04cc262172b"];
     NSData *data = [NSData dataWithContentsOfURL:URL];
     NSError *error;
     
     NSDictionary *subwayListsJSON = [NSJSONSerialization JSONObjectWithData:data
     options:NSJSONReadingMutableContainers
     error:&error];
     NSDictionary *result = [subwayListsJSON objectForKey:@"result"];
     NSArray *results = [result objectForKey:@"results"];
     
     for (NSDictionary *dictionary in results) {
         NSString *station = [dictionary objectForKey:@"Station"];
         NSString *tempDestination = [dictionary objectForKey:@"Destination"];
         NSString *destination = [NSString stringWithFormat:@"終點站：%@", tempDestination];
         
         station = [self editStringFromHalfWidthToFullWidth:station];
         destination = [self editStringFromHalfWidthToFullWidth:destination];
         
         if ([tempDestination isEqualToString:@"南港展覽館站"]) {
            
             [subwayLists addObject:station];
             [destinationLists addObject:destination];
         }
         
         
         
         
     }
         [_tableViewSubwayDetailList reloadData];
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
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Right Detail Cell" forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[subwayLists objectAtIndex:[indexPath row]]];
    [[tableViewCell detailTextLabel] setText:[destinationLists objectAtIndex:[indexPath row]]];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
