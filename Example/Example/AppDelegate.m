//
//  AppDelegate.m
//  Example
//
//  Created by sheng on 2021/5/27.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <GrowingToolsKit/GrowingToolsKit.h>
#import "GrowingAdvertising.h"
#import "GrowingAutotracker.h"

static NSString *const kGrowingProjectId = @"bc675c65b3b0290e";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化GioKit
    [GrowingToolsKit start];

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
            [controller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil]];
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

#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application - applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application - applicationDidBecomeActive");

    // 如若您需要使用IDFA作为访问用户ID，参考如下代码
    /**
     // 调用AppTrackingTransparency相关实现请在ApplicationDidBecomeActive之后，适配iOS 15
     // 参考: https:developer.apple.com/forums/thread/690607?answerId=688798022#688798022
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // 初始化SDK
        }];
    } else {
        // 初始化SDK
    }
     */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"Application - applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application - applicationDidEnterBackground");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application - applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return YES;
}

// Universal Link
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    restorationHandler(nil);
    return YES;
}

@end
