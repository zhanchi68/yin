//
//  AppDelegate.m
//  erp
//
//  Created by 周兵 on 2020/7/7.
//  Copyright © 2020 sdqc56. All rights reserved.
//

#import "AppDelegate.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "QCTrackOverlyViewController.h"

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
   QCTrackOverlyViewController *VC = [[QCTrackOverlyViewController alloc] init];
      self.window.rootViewController = VC;
      [self.window makeKeyAndVisible];
    [AMapServices sharedServices].apiKey = @"f8830d70ee7b33ebe317d24c0e40929f";
    
    return YES;
}




@end
