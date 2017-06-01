//
//  SearchBusDetailViewController.m
//  Project_BTM
//

#import "SearchBusDetailViewController.h"

@interface SearchBusDetailViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *mutableArray;
}

@property (weak, nonatomic) IBOutlet UITableView *searchBusDetailList;

@end

@implementation SearchBusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_searchBusDetailList setDelegate:self];
    [_searchBusDetailList setDataSource:self];
    
    NSCharacterSet *characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *string = [NSString stringWithFormat:@"http://ptx.transportdata.tw/MOTC/v2/Bus/StopOfRoute/City/Taipei/14?$filter=RouteUID eq 'TPE10891'and KeyPattern eq true and Direction eq '0'&$format=JSON"];
    NSString *encodingString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    NSURL *URL = [NSURL URLWithString:encodingString];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:nil];
    for (NSDictionary *dictionary in array) {
        
        NSArray *stops = [dictionary objectForKey:@"Stops"];
        
        for (NSDictionary *StopName in stops) {
        
            NSDictionary *zhTW = [StopName objectForKey:@"StopName"];
            NSString *string = [zhTW objectForKey:@"Zh_tw"];
            NSString *editedString = [self editStringFromHalfWidthToFullWidth:string];
            [mutableArray addObject:editedString];
            NSLog(@"%@", editedString);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        mutableArray = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"[mutableArray count]: %ld", [mutableArray count]);
    return [mutableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Basic Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[mutableArray objectAtIndex:[indexPath row]]];
    
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
