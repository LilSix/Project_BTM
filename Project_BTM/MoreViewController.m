//
//  MoreViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "MoreViewController.h"
#import "MoreDetailViewController.h"


#pragma mark -

@interface MoreViewController ()<UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *mutableArrayWithLinkName;
    NSMutableDictionary *mutableDicWithURL;
    NSString *stringWithURL;
}

@property (weak, nonatomic) IBOutlet UITableView *talbeViewMoreLists;


@end


#pragma mark -

@implementation MoreViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_talbeViewMoreLists setDelegate:self];
    [_talbeViewMoreLists setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        stringWithURL = [[NSString alloc] init];
        
        NSString *cityBusLinkName = @"大臺北公車";
        NSString *taipeiSubwayLinkName = @"臺北捷運公司";
        mutableArrayWithLinkName = [NSMutableArray arrayWithObjects:cityBusLinkName, taipeiSubwayLinkName, nil];
        
        mutableDicWithURL = [NSMutableDictionary dictionary];
        [mutableDicWithURL setObject:@"https://ebus.gov.taipei" forKey:cityBusLinkName];
        [mutableDicWithURL setObject:@"http://www.metro.taipei/ct.asp?xItem=78479152&CtNode=70089&mp=122035" forKey:taipeiSubwayLinkName];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [mutableArrayWithLinkName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Basic Cell"
                                                                     forIndexPath:indexPath];
    [[tableViewCell textLabel] setText:[mutableArrayWithLinkName objectAtIndex:[indexPath row]]];
    
    return tableViewCell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    stringWithURL = [mutableDicWithURL objectForKey:[mutableArrayWithLinkName objectAtIndex:[indexPath row]]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showMoreDetail"]) {
        
        MoreDetailViewController *moreDetailVC = [segue destinationViewController];
        [moreDetailVC setStringLWithURLForWeb:stringWithURL];
    }
}

@end
