//
//  AppDelegate.h
//  Project_BTM
//
//  Created by user36 on 2017/5/11.
//  Copyright © 2017年 user36. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

