//
//  AppDelegate.m
//  GrowingAdvertising
//
//  Created by YoloMao on 2022/6/27.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "AppDelegate.h"
@import GrowingAnalytics;
#import "GrowingAdvertising.h"

static NSString *const kGrowingProjectId = @"bc675c65b3b0290e";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始化GrowingAdvertising
    GrowingAdvertConfiguration *adConfiguration = [GrowingAdvertConfiguration configurationWithProjectId:@"0a1b4118dd954ec3bcc69da5138bdb96"
                                                                                              urlScheme:@"growing.530c8231345c492d"];
    __weak typeof(self) weakSelf = self;
    adConfiguration.deepLinkCallback = ^(NSDictionary * _Nonnull params, NSTimeInterval appAwakePassedTime, NSError * _Nonnull error) {
        NSLog(@"初始化配置callback params is : %@",params);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"初始化配置callback"
                                                                                message:[NSString stringWithFormat:@"%@", params]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Advertising" style:UIAlertActionStyleCancel handler:nil]];
            [weakSelf.topMostController presentViewController:controller animated:YES completion:nil];
        });
    };
    [GrowingAdvertising startWithConfiguration:adConfiguration];

    // 初始化GrowingAnalytics
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
    configuration.encryptEnabled = YES;
    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:launchOptions];
    return YES;
}

- (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    return YES;
}

@end
