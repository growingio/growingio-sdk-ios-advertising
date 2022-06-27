//
// GrowingAdvertising.m
// GrowingAdvertising
//
//  Created by sheng on 2021/5/11.
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

#import "GrowingAdvertising/Public/GrowingAdvertising.h"
#import "GrowingAdvertising/Utils/GrowingAdUtils.h"
#import "GrowingAdvertising/Event/GrowingActivateEvent.h"
#import "GrowingAdvertising/Event/GrowingReengageEvent.h"
#import "GrowingAdvertising/Request/GrowingAdPreRequest.h"
#import "GrowingAdvertising/Request/GrowingAdEventRequest.h"

#import "GrowingTrackerCore/Public/GrowingEventNetworkService.h"
#import "GrowingTrackerCore/Public/GrowingServiceManager.h"
#import "GrowingTrackerCore/Event/GrowingEventManager.h"
#import "GrowingTrackerCore/Event/GrowingEventChannel.h"
#import "GrowingTrackerCore/Event/GrowingTrackEventType.h"
#import "GrowingTrackerCore/Helpers/NSData+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"
#import "GrowingTrackerCore/Helpers/NSURL+GrowingHelper.h"
#import "GrowingTrackerCore/Manager/GrowingConfigurationManager.h"
#import "GrowingTrackerCore/DeepLink/GrowingDeepLinkHandler.h"
#import "GrowingTrackerCore/Thread/GrowingDispatchManager.h"
#import "GrowingTrackerCore/Thirdparty/Logger/GrowingLogger.h"
#import <WebKit/WebKit.h>

GrowingMod(GrowingAdvertising)

@interface GrowingAdvertising () <GrowingDeepLinkHandlerProtocol, GrowingEventInterceptor>

@property (nonatomic, copy) GrowingAdvertConfiguration *configuration;
@property (nonatomic, assign, getter=isActivateSended) BOOL activateSended; // 是否已经发了activate，也表示是否第一次启动
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSError *deepLinkError;

@end

static GrowingAdvertising *sharedInstance = nil;

@implementation GrowingAdvertising

#pragma mark - GrowingModuleProtocol

+ (BOOL)singleton {
    return YES;
}

- (void)growingModInit:(GrowingContext *)context {
    [[GrowingEventManager sharedInstance] addInterceptor:self];
    [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:self];
    [self loadClipboard];
    [self versionPrint];
}

#pragma mark - GrowingDeepLinkHandlerProtocol

- (BOOL)growingHandlerUrl:(NSURL *)url {
    return [self growingHandlerUrl:url isManual:NO callback:nil];
}

#pragma mark - GrowingEventInterceptor

- (void)growingEventManagerChannels:(NSMutableArray<GrowingEventChannel *> *)channels {
    // 由于reengage activate，发送地址和3.0不一致，需要另创建channel来发送
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[@"reengage", @"activate"]
                                                            urlTemplate:@"app/%@/ios/ctvt"
                                                          isCustomEvent:NO]];
}

- (id<GrowingRequestProtocol> _Nullable)growingEventManagerRequestWithChannel:(GrowingEventChannel *_Nullable)channel {
    if (channel.eventTypes.count > 0 && [channel.eventTypes indexOfObject:@"reengage"] != NSNotFound) {
        return [[GrowingAdEventRequest alloc] init];
    }
    return nil;
}

#pragma mark - Public Method

+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        @throw [NSException exceptionWithName:@"[GrowingAdvertising] GrowingAdvertising未初始化"
                                       reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数，并且先初始化GrowingAdvertising之后，再初始化GrowingAnalytics"
                                     userInfo:nil];
    }
    if (![GrowingConfigurationManager sharedInstance].trackConfiguration) {
        @throw [NSException exceptionWithName:@"[GrowingAdvertising] GrowingAnalytics未初始化"
                                       reason:@"请初始化GrowingAnalytics之后，再调用GrowingAdvertising相关实例函数"
                                     userInfo:nil];
    }
    return sharedInstance;
}

+ (void)startWithConfiguration:(GrowingAdvertConfiguration *)configuration {
    if (![NSThread isMainThread]) {
        @throw [NSException exceptionWithName:@"[GrowingAdvertising] 初始化异常"
                                       reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数，并且确保在主线程中"
                                     userInfo:nil];
    }

    if (!configuration.projectId.length) {
        @throw [NSException exceptionWithName:@"[GrowingAdvertising] 初始化异常"
                                       reason:@"ProjectId不能为空"
                                     userInfo:nil];
    }
    
    if (!configuration.urlScheme.length) {
        @throw [NSException exceptionWithName:@"[GrowingAdvertising] 初始化异常"
                                       reason:@"URLScheme不能为空"
                                     userInfo:nil];
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.configuration = configuration;
    });
}

- (NSString *)projectId {
    return self.configuration.projectId;
}

- (NSString *)urlScheme {
    return self.configuration.urlScheme;
}

- (GrowingAdDeepLinkCallback)deepLinkCallback {
    return self.configuration.deepLinkCallback;
}

- (BOOL)dataCollectionEnabled {
    return self.configuration.dataCollectionEnabled;
}

- (BOOL)readClipBoardEnabled {
    return self.configuration.readClipBoardEnabled;
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (enabled == self.configuration.dataCollectionEnabled) {
            return;
        }
        self.configuration.dataCollectionEnabled = enabled;
        if (enabled) {
            [self loadClipboard];
        }
    }];
}

- (void)setReadClipBoardEnabled:(BOOL)enabled {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        if (enabled == self.configuration.readClipBoardEnabled) {
            return;
        }
        self.configuration.readClipBoardEnabled = enabled;
    }];
}

- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback {
    return [self growingHandlerUrl:url isManual:YES callback:callback];
}

#pragma mark - Private Method

- (void)versionPrint {
    NSDictionary *info = [NSBundle bundleForClass:self.class].infoDictionary;
    if (info) {
        NSString *version = info[@"CFBundleShortVersionString"];
        if (version.length > 0) {
            GIOLogInfo(@"%@", [NSString stringWithFormat:@"[GrowingAdvertising] Thank you very much for using GrowingAdvertising. "
                                                         @"GrowingAdvertising version: %@", version]);
        }
    }
}

- (BOOL)SDKDoNotTrack {
    if (![GrowingConfigurationManager sharedInstance].trackConfiguration.dataCollectionEnabled
        || !self.dataCollectionEnabled) {
        GIOLogDebug(@"[GrowingAdvertising] dataCollectionEnabled is false");
        return YES;
    }
    return NO;
}

- (void)setActivateSended:(BOOL)activateSended {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(activateSended) forKey:@"GrowingAdvertisingIsActivateSended"];
    [userDefaults synchronize];
}

- (BOOL)isActivateSended {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingAdvertisingIsActivateSended"];
    return number && number.boolValue;
}

- (BOOL)growingHandlerUrl:(NSURL *)url isManual:(BOOL)isManual callback:(GrowingAdDeepLinkCallback)callback {
    if (![GrowingAdUtils isGrowingIOUrl:url]) {
        if (isManual) {
            // 若手动触发callback则报错
            [self handleDeepLinkError:[self illegalURLError] callback:callback startDate:nil];
        }
        return NO;
    }

    NSString *reengageType = [url.scheme hasPrefix:@"growing."] ? @"url_scheme" : @"universal_link";
    
    // ShortChain
    if ([GrowingAdUtils isShortChainUlink:url]) {
        NSDate *startDate = [NSDate date];
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            [self accessUserAgent:^(NSString *userAgent) {
                if ([self SDKDoNotTrack]) {
                    return;
                }
                GrowingAdPreRequest *eventRequest = nil;
                eventRequest = [[GrowingAdPreRequest alloc] init];
                eventRequest.hashId = [url.path componentsSeparatedByString:@"/"].lastObject;
                eventRequest.isManual = isManual;
                eventRequest.userAgent = userAgent;
                eventRequest.query = [url.query growingHelper_dictionaryObject];
                id <GrowingEventNetworkService> service = [[GrowingServiceManager sharedInstance] createService:@protocol(GrowingEventNetworkService)];
                if (!service) {
                    GIOLogError(@"[GrowingAdvertising] -growingHandlerUrl:isManual:callback: error : no network service support");
                    return;
                }
                [service sendRequest:eventRequest completion:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull data, NSError * _Nonnull error) {
                    if ([self SDKDoNotTrack]) {
                        return;
                    }
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        NSDictionary *dataDict = [[data growingHelper_dictionaryObject] objectForKey:@"data"];
                        NSDictionary *customParams = [dataDict objectForKey:@"custom_params"];
                        [self sendReengageEvent:dataDict reengageType:reengageType customParams:customParams startDate:startDate callback:callback];
                    } else {
                        [self handleDeepLinkError:[self requestFailedError] callback:callback startDate:startDate];
                    }
                }];
            }];
        }];
        return YES;
    }
    // 如果是长链
    NSDictionary *dataDict = url.growingHelper_queryDict;
    if (dataDict[@"link_id"]) {
        [GrowingDispatchManager dispatchInGrowingThread:^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            NSString *customStr = dataDict[@"custom_params"] ?: @"";
            NSDictionary *customParams = [GrowingAdUtils URLDecodedString:customStr].growingHelper_dictionaryObject;
            [self sendReengageEvent:dataDict reengageType:reengageType customParams:customParams startDate:nil callback:callback];
        }];
        return YES;
    }
    return NO;
}

- (void)accessUserAgent:(void (^)(NSString *_Nullable userAgent))block {
    if (!block) {
        return;
    }
    if (self.userAgent) {
        [GrowingDispatchManager dispatchInGrowingThread:^{
            block(self.userAgent);
        }];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // WKWebView的initWithFrame方法偶发崩溃，这里 @try @catch保护
        @try {
            self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            __weak typeof(self) weakSelf = self;
            [self.wkWebView evaluateJavaScript:@"navigator.userAgent"
                             completionHandler:^(_Nullable id response, NSError *_Nullable error) {
                [GrowingDispatchManager dispatchInGrowingThread:^{
                    if (error || !response) {
                        GIOLogError(@"[GrowingAdvertising] WKWebView evaluateJavaScript load UA error:%@", error);
                        block(nil);
                    } else {
                        weakSelf.userAgent = response;
                        block(response);
                    }
                }];
                weakSelf.wkWebView = nil;
            }];
        } @catch (NSException *exception) {
            GIOLogDebug(@"[GrowingAdvertising] loadUserAgentWithCompletion crash :%@", exception);
            [GrowingDispatchManager dispatchInGrowingThread:^{
                block(nil);
            }];
        }
    });
}

- (void)loadClipboard {
    [GrowingDispatchManager dispatchInGrowingThread:^{
        // 不直接在GrowingThread执行是因为UIPasteboard调用**可能**会卡死线程，实测在主线程调用有卡死案例
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([self SDKDoNotTrack]) {
                return;
            }
            if (self.isActivateSended) {
                // activate在同一安装周期内仅需发送一次
                return;
            }
            if (!self.readClipBoardEnabled) {
                GIOLogDebug(@"[GrowingAdvertising] readClipBoardEnabled is false");
                [self sendActivateEvent:nil];
                return;
            }
            
            NSString *clipboardContent = [UIPasteboard generalPasteboard].string;
            NSDictionary *clipboardDict = [GrowingAdUtils dictFromPasteboard:clipboardContent];
            if (clipboardDict.count == 0
                || ![clipboardDict[@"typ"] isEqualToString:@"gads"]
                || ![clipboardDict[@"scheme"] isEqualToString:self.urlScheme]) {
                [self sendActivateEvent:nil];
                return;
            }
            
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            dictM[@"link_id"] = clipboardDict[@"link_id"];
            dictM[@"click_id"] = clipboardDict[@"click_id"];
            dictM[@"tm_click"] = clipboardDict[@"tm_click"];
            dictM[@"cl"] = @"defer";
            [self sendActivateEvent:dictM.copy];
            
            NSString *customStr = @"";
            NSDictionary *v1 = clipboardDict[@"v1"];
            if ([v1 isKindOfClass:[NSDictionary class]]) {
                customStr = v1[@"custom_params"] ?: @"";
            }
            NSDictionary *customParams = [GrowingAdUtils URLDecodedString:customStr].growingHelper_dictionaryObject;
            NSString *reengageType = @"universal_link";
            [self sendReengageEvent:dictM reengageType:reengageType customParams:customParams startDate:nil callback:nil];
            
            if ([[UIPasteboard generalPasteboard].string isEqualToString:clipboardContent]) {
                [UIPasteboard generalPasteboard].string = @"";
            }
        });
    }];
}

#pragma mark - Event handler

- (void)sendActivateEvent:(nullable NSDictionary *)clipboardParams {
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }
        if (self.isActivateSended) {
            // activate在同一安装周期内仅需发送一次
            return;
        }
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"ua"] = userAgent;
        [dictM addEntriesFromDictionary:clipboardParams];
        GrowingActivateBuilder *builder = GrowingActivateEvent.builder.setExtraParams(dictM);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        self.activateSended = YES;
    }];
}

- (void)sendReengageEvent:(NSDictionary *)parameters
             reengageType:(NSString *)reengageType
             customParams:(nullable NSDictionary *)customParams
                startDate:(nullable NSDate *)startDate
                 callback:(nullable GrowingAdDeepLinkCallback)callback {
    [self accessUserAgent:^(NSString *userAgent) {
        if ([self SDKDoNotTrack]) {
            return;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"rngg_mch"] = reengageType;
        params[@"ua"] = userAgent;
        params[@"link_id"] = [parameters objectForKey:@"link_id"];
        params[@"click_id"] = [parameters objectForKey:@"click_id"];
        params[@"tm_click"] = [parameters objectForKey:@"tm_click"];
        params[@"var"] = customParams ?: @{};
        GrowingReengageBuilder *builder = GrowingReengageEvent.builder.setExtraParams(params);
        [[GrowingEventManager sharedInstance] postEventBuilder:builder];
        
        [self handleDeepLinkCallback:callback reengageType:reengageType customParams:customParams ?: @{} startDate:startDate];
    }];
}

- (void)handleDeepLinkError:(NSError *)error
                   callback:(nullable GrowingAdDeepLinkCallback)callback
                  startDate:(nullable NSDate *)startDate {
    if (!callback && !self.deepLinkCallback) {
        return;
    }
    if (!callback) {
        callback = self.deepLinkCallback;
    }
    
    [GrowingDispatchManager dispatchInMainThread:^{
        if (callback) {
            callback(nil, startDate ? [[NSDate date] timeIntervalSinceDate:startDate] : 0.0, error);
        }
    }];
}

- (void)handleDeepLinkCallback:(nullable GrowingAdDeepLinkCallback)callback
                  reengageType:(NSString *)reengageType
                  customParams:(NSDictionary *)customParams
                     startDate:(nullable NSDate *)startDate {
    if (!callback && !self.deepLinkCallback) {
        return;
    }
    if (!callback) {
        callback = self.deepLinkCallback;
    }
    
    NSError *error = nil;
    if (customParams.count == 0) {
        error = self.noQueryError;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:customParams];
    if ([dict objectForKey:@"_gio_var"]) {
        [dict removeObjectForKey:@"_gio_var"];
    }
    if (![dict objectForKey:@"+deeplink_mechanism"]) {
        [dict setObject:reengageType forKey:@"+deeplink_mechanism"];
    }
    
    [GrowingDispatchManager dispatchInMainThread:^{
        if (callback) {
            callback(dict, startDate ? [[NSDate date] timeIntervalSinceDate:startDate] : 0.0, error);
        }
    }];
}

#pragma mark - Error

- (NSError *)noQueryError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingNoQueryError
                           userInfo:@{NSLocalizedDescriptionKey : @"no custom parameters"}];
}

- (NSError *)illegalURLError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingIllegalURLError
                           userInfo:@{NSLocalizedDescriptionKey : @"this is not GrowingIO DeepLink URL"}];
}

- (NSError *)requestFailedError {
    return [NSError errorWithDomain:GrowingAdvertisingErrorDomain
                               code:GrowingAdvertisingRequestFailedError
                           userInfo:@{NSLocalizedDescriptionKey : @"pre-request failed"}];
}

@end
