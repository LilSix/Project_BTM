//
//  SubwayMapViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "SubwayMapViewController.h"


#pragma mark -

@interface SubwayMapViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewWithSubwayMap;
@property (strong, nonatomic) UIImageView *imageViewWithSubwayMap;

@end


#pragma mark -

@implementation SubwayMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_scrollViewWithSubwayMap setDelegate:self];
    [_scrollViewWithSubwayMap setMaximumZoomScale:3.0];
    
    UIImage *image = [UIImage imageNamed:@"MetroTaipeiMap.jpg"];
    _imageViewWithSubwayMap = [[UIImageView alloc] initWithImage:image];
    [_imageViewWithSubwayMap setContentMode:UIViewContentModeScaleAspectFit];
    [_scrollViewWithSubwayMap addSubview:_imageViewWithSubwayMap];
    
    /* 若以下步驟沒有執行，則之後透過 ScrollView 來縮放圖片的時候，圖片縮放過後周圍的白邊會破壞縮放功能。 */
    // 將 ImageView 的大小設定與 ScrollView 相同。
    [_imageViewWithSubwayMap setFrame:[_scrollViewWithSubwayMap bounds]];
    
    // 取得圖片縮小後的長寬。
    CGSize size = [self getImageSizeAfterAspectFit:_imageViewWithSubwayMap];
    
    // 將 ImageView 的大小調整為與圖片大小相同。
    [_imageViewWithSubwayMap setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // 將 ScrollView 的容器大小調整為與 ImageView 相同。
    [_scrollViewWithSubwayMap setContentSize:_imageViewWithSubwayMap.frame.size];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return [[scrollView subviews] firstObject];
}


#pragma mark - IBAction

- (IBAction)barButtonItemStopTouch:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - GetImageSizeAfterAspectFit

- (CGSize)getImageSizeAfterAspectFit:(UIImageView *)imageView {
    
    float widthRatio = [imageView bounds].size.width / [[imageView image] size].width;
    float heightRatio = [imageView bounds].size.height / [[imageView image] size].height;
    
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * [[imageView image] size].width;
    float imageHeight = scale * [[imageView image] size].height;
    
    return CGSizeMake(imageWidth, imageHeight);
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
