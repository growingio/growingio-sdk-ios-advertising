//
//  AppDelegate.m
//  Example
//
//  Created by sheng on 2021/5/27.
//

#import "AppDelegate.h"

#import "GrowingAdvertising.h"
#import "GrowingAutotracker.h"
//#import <GrowingAuto>
#import <UserNotifications/UserNotifications.h>

static NSString *const kGrowingProjectId = @"91eaf9b283361032";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithProjectId:kGrowingProjectId];
    configuration.debugEnabled = YES;
    //    configuration.impressionScale = 1.0;

    // 暂时设置host为mocky链接，防止请求404，实际是没有上传到服务器的，正式使用请去掉，或设置正确的host
    configuration.dataCollectionServerHost = @"https://run.mocky.io/v3/08999138-a180-431d-a136-051f3c6bd306";
    GrowingTrackConfiguration *configuration2 =
        [GrowingTrackConfiguration configurationWithProjectId:@"0a1b4118dd954ec3bcc69da5138bdb96"];
    configuration2.debugEnabled = YES;

    [GrowingAdvertising startWithConfiguration:configuration2 urlScheme:@"growing.bae230e3f4b1bfbd"];
    [GrowingAdvertising sharedInstance].deeplinkHandler = ^(NSDictionary * _Nonnull params, NSTimeInterval processTime, NSError * _Nonnull error) {
        NSLog(@"deeplink params is : %@",params);
    };
    [GrowingAutotracker startWithConfiguration:configuration launchOptions:launchOptions];
    //    [GrowingTracker startWithConfiguration:configuration launchOptions:launchOptions];
    //    [[GrowingAutotracker sharedInstance] setLocation:[@30.11 doubleValue] longitude:[@32.22 doubleValue]];
    return YES;
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    if (@available(iOS 10, *)) {
        //  10以后的注册方式
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //监听回调事件
        // iOS 10 使用以下方法注册，才能得到授权，注册通知以后，会自动注册 deviceToken，如果获取不到
        // deviceToken，Xcode8下要注意开启 Capability->Push Notification。
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                  if (granted) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [[UIApplication sharedApplication] registerForRemoteNotifications];
                                      });
                                  }
                              }];

    } else if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =
            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (NSInteger i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i] & 0xff];
    }

    NSLog(@"推送Token 字符串：%@", deviceTokenString);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"远程通知1"
                                                                   message:@"点击一下呗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                 animated:YES
                                                                               completion:nil];
}
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,
// id> *)options {
//    return NO;
//}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return NO;
//}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
////    if ([Growing handleURL:url]) {
////        return YES;
////    }
//    return NO;
//}

// universal Link执行
- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    //    [Growing handleURL:userActivity.webpageURL];
    restorationHandler(nil);
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return NO;
}

@end
