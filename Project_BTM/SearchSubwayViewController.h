//
//  SearchSubwayViewController.h
//  Project_BTM
//
//  Created by user36 on 2017/5/24.
//  Copyright © 2017年 user36. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchSubwayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textFieldRouteName;
- (NSMutableDictionary *)fetchSubwayArrivedAtStation;

@end
