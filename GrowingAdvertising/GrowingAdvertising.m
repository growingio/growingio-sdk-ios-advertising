//
// GrowingAdvertisingParser.m
// GrowingAnalytics
//
//  Created by sheng on 2021/5/11.
//  Copyright (C) 2017 Beijing Yishu Technology Co., Ltd.
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

#import "GrowingAdvertising.h"

#import <WebKit/WebKit.h>

#import "GrowingActivateEvent.h"
#import "GrowingAdvertisingPreRequest.h"
#import "GrowingAdvertisingRequest.h"
#import "GrowingAdvertisingVisitEvent.h"
#import "GrowingAdvertisingVstRequest.h"
#import "GrowingAppLifecycle.h"
#import "GrowingCocoaLumberjack.h"
#import "GrowingDeepLinkHandler.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventManager.h"
#import "GrowingNetworkManager.h"
#import "GrowingReengageEvent.h"
#import "NSData+GrowingHelper.h"
#import "NSDictionary+GrowingHelper.h"
#import "NSString+GrowingHelper.h"
#import "NSURL+GrowingHelper.h"
#import "GrowingEventChannel.h"
#import "GrowingDeepLinkHandler.h"

@interface GrowingAdvertising () <GrowingDeepLinkHandlerProtocol, GrowingEventInterceptor,GrowingAppLifecycleDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong, readwrite) GrowingTrackConfiguration *configuration;
/// 是否已经发了activate，也表示是否第一次启动
@property (nonatomic, assign) BOOL isAlreadySendActivate;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, strong) NSDictionary *externParam;
@end

@implementation GrowingAdvertising

static GrowingAdvertising *advertisingObj = nil;

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!advertisingObj) {
            advertisingObj = [[GrowingAdvertising alloc] init];
            [[GrowingEventManager shareInstance] addInterceptor:advertisingObj];
            [[GrowingAppLifecycle sharedInstance] addAppLifecycleDelegate:advertisingObj];
            [[GrowingDeepLinkHandler sharedInstance] addHandlersObject:advertisingObj];
        }
    });
    advertisingObj.configuration = configuration;
    [advertisingObj loadClipboardCompletion:^(NSDictionary *dict) {
        advertisingObj.externParam = dict;
        [advertisingObj sendActivateEvent];
    }];
    
}

+ (instancetype)shareInstance {
    if (!advertisingObj) {
        @throw [NSException exceptionWithName:@"GrowingAdvertising未初始化" reason:@"请在applicationDidFinishLaunching中调用startWithConfiguration函数,并且确保在主线程中" userInfo:nil];
    }
    return advertisingObj;
}

- (void)setDataCollectionEnabled:(BOOL)enabled {
    self.configuration.dataCollectionEnabled = enabled;
}

- (void)setIsAlreadySendActivate:(BOOL)isAlreadySendActivate {
    [[NSUserDefaults standardUserDefaults] setObject:@(isAlreadySendActivate) forKey:@"GrowingAdvertisingIsAlreadySendActivate"];
}

- (BOOL)isAlreadySendActivate {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrowingAdvertisingIsAlreadySendActivate"];
    if (number) {
        return YES;
    }
    return NO;
}

- (BOOL)growingHandlerUrl:(NSURL *)url {
    if (!url || !self.configuration.projectId) {
        return NO;
    }

    ///使用何种方式唤醒 app
    NSString *reengageType = nil;
    if ([url.scheme hasPrefix:@"growing."]) {
        reengageType = @"url_scheme";
    } else {
        reengageType = @"universal_link";
    }
    // short chain
    if ([self isUrlShortChain:url]) {
        NSDate *startData = [NSDate date];
        NSString *hashId = [url.path componentsSeparatedByString:@"/"].lastObject;
        [self accessUserAgent:^(NSString *userAgent) {
            GrowingAdvertisingPreRequest *eventRequest = nil;
            eventRequest = [[GrowingAdvertisingPreRequest alloc] init];
            eventRequest.hashId = hashId;
            eventRequest.isManual = NO;
            eventRequest.userAgent = userAgent;
            eventRequest.query = [url.query growingHelper_dictionaryObject];
            [[GrowingNetworkManager shareManager]
             sendRequest:eventRequest
             success:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data) {
                NSDictionary *dataDict = [[data growingHelper_dictionaryObject] objectForKey:@"data"];
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[@"rngg_mch"] = reengageType;
                params[@"ua"] = userAgent;
                params[@"link_id"] = [dataDict objectForKey:@"link_id"];
                params[@"click_id"] = [dataDict objectForKey:@"click_id"];
                params[@"tm_click"] = [dataDict objectForKey:@"tm_click"];
                NSDictionary *dict = [dataDict objectForKey:@"custom_params"];
                if (dict.count > 0) {
                    params[@"var"] = dict;
                }
                GrowingReengageBuilder *builder = GrowingReengageEvent.builder.setExtraParams(params);
                [self postEventBuidler:builder];
                
                if (self.deeplinkHandler) {
                    // 处理参数回调
                    NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
                    if ([dictInfo objectForKey:@"_gio_var"]) {
                        [dictInfo removeObjectForKey:@"_gio_var"];
                    }
                    if (![dictInfo objectForKey:@"+deeplink_mechanism"]) {
                        [dictInfo setObject:reengageType forKey:@"+deeplink_mechanism"];
                    }
                    
                    NSError *err = nil;
                    if (dict.count == 0) {
                        // 默认错误
                        err = [NSError errorWithDomain:@"com.growingio.deeplink" code:1 userInfo:@{@"error" : @"no custom_params"}];
                    }
                    
                    if (self.deeplinkHandler) {
                        NSDate *endDate = [NSDate date];
                        NSTimeInterval processTime = [endDate timeIntervalSinceDate:startData];
                        self.deeplinkHandler(dictInfo, processTime, err);
                    }
                }
            }
             failure:^(NSHTTPURLResponse *_Nonnull httpResponse, NSData *_Nonnull data, NSError *_Nonnull error){
                
            }];
        }];
        return YES;
    }
    ///如果是长链
    NSDictionary *params = url.growingHelper_queryDict;
    if (params[@"link_id"]) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:params];
        [self accessUserAgent:^(NSString *userAgent) {
            dictM[@"var"] = dictM[@"custom_params"];
            // custom_params 对应key应该为var
            [dictM removeObjectForKey:@"custom_params"];
            dictM[@"rngg_mch"] = reengageType;
            dictM[@"ua"] = userAgent;
            GrowingReengageBuilder *builder = GrowingReengageEvent.builder.setExtraParams(dictM);
            [self postEventBuidler:builder];
            
            if (self.deeplinkHandler) {
                NSString *custom_params_str = params[@"custom_params"];
                NSArray *pair = [custom_params_str componentsSeparatedByString:@"="];
                if (pair.count > 1) {
                    NSString *encodeJsonStr = pair[1];
                    if (encodeJsonStr.length > 0) {
                        NSError *err = nil;
                        NSString *jsonStr = [self URLDecodedString:encodeJsonStr];
                        NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                        NSMutableDictionary *dicInfo  = [NSMutableDictionary dictionaryWithDictionary:info] ;
                        if ([dicInfo objectForKey:@"_gio_var"]) {
                            [dicInfo removeObjectForKey:@"_gio_var"];
                        }
                        if (![dicInfo objectForKey:@"+deeplink_mechanism"]) {
                            [dicInfo setObject:reengageType forKey:@"+deeplink_mechanism"];
                        }
                        info = dicInfo;
                        if (!info) {
                            GIOLogDebug(@"%s error : %@", __FUNCTION__,err);
                        }
                        if (!info && !err) {
                            // 默认错误
                            err = [NSError errorWithDomain:@"com.growingio.deeplink" code:1 userInfo:@{@"error" : @"no custom_params"}];
                        }
                        self.deeplinkHandler(info, 0.0, err);
                    }
                }
            }
        }];
        return YES;
    }
    return NO;
}


- (NSString *)URLDecodedString:(NSString *)urlString {
    urlString = [urlString
    stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                    (__bridge CFStringRef)urlString,
                                                                                                                    CFSTR(""),
                                                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

/// WKWebview 获取 User Agent
/// @param block 获取后的回调函数
- (void)accessUserAgent:(void (^)(NSString *userAgent))block {
    if (self.userAgent) {
        if (block) block(self.userAgent);
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // WKWebView的initWithFrame方法偶发崩溃，这里@try@catch保护
        @try {
            weakSelf.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
            [weakSelf.wkWebView evaluateJavaScript:@"navigator.userAgent"
                                 completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                                     if (error || !response) {
                                         GIOLogError(@"WKWebView evaluateJavaScript load UA error:%@", error);
                                         if (block) block(nil);
                                     } else {
                                         weakSelf.userAgent = response;
                                         if (block) block(response);
                                     }
                                     weakSelf.wkWebView = nil;
                                 }];
        } @catch (NSException *exception) {
            GIOLogDebug(@"loadUserAgentWithCompletion crash :%@", exception);
            if (block) block(nil);
        }
    });
}

#pragma mark - Event handler

- (void)loadClipboardCompletion:(void(^)(NSDictionary *dict))block {
    
    if (self.isAlreadySendActivate) {
        return;
    }
    
    NSString *clipboardContent = [UIPasteboard generalPasteboard].string;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *clipboardDict = [self dictFromPastboard:clipboardContent];
        if (clipboardDict.count == 0) {
            if (block) block(nil);
            return;
        }

        if (![clipboardDict[@"typ"] isEqualToString:@"gads"] ||
            ![clipboardDict[@"scheme"] isEqualToString:[GrowingDeviceInfo currentDeviceInfo].urlScheme]) {
            if (block) block(nil);
            return;
        }
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"link_id"] = clipboardDict[@"link_id"];
        dictM[@"click_id"] = clipboardDict[@"click_id"];
        dictM[@"tm_click"] = clipboardDict[@"tm_click"];
        dictM[@"cl"] = clipboardDict[@"defer"];
        
        
        NSString *customStr = clipboardDict[@"v1"][@"custom_params"]?:@"";
        NSDictionary *customParams = customStr.growingHelper_dictionaryObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /// send reenagate
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [self accessUserAgent:^(NSString *userAgent) {
                [params addEntriesFromDictionary:dictM];
                params[@"var"] = customParams;
                params[@"rngg_mch"] = @"universal_link";
                params[@"ua"] = userAgent;
                GrowingReengageBuilder *builder = GrowingReengageEvent.builder.setExtraParams(params);
                [self postEventBuidler:builder];
            }];
            
            if ([[UIPasteboard generalPasteboard].string isEqualToString:clipboardContent]) {
                [UIPasteboard generalPasteboard].string = @"";
            }
            if (block) {
                block([dictM copy]);
            }
        });
    });
    
}

- (void)sendActivateEvent {
    if (self.isAlreadySendActivate) {
        return;
    }
    
    if (!self.configuration.dataCollectionEnabled) {
        return;
    }
    
    [self accessUserAgent:^(NSString *userAgent) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        dictM[@"ua"] = userAgent;
        [dictM addEntriesFromDictionary:self.externParam];
        GrowingActivateBuilder *builder = GrowingActivateEvent.builder.setExtraParams(dictM);
        self.isAlreadySendActivate = YES;
        [self postEventBuidler:builder];
    }];
    
}

- (void)postEventBuidler:(GrowingBaseBuilder *)builder {
    if (!self.configuration.dataCollectionEnabled) {
        return;
    }
    
    if (!self.isAlreadySendActivate) {
        [self sendActivateEvent];
    }
    
    [[GrowingEventManager shareInstance] postEventBuidler:builder];
}
/// 由于vst 以及 reenage activate，发送地址和3.0不一致，需要另创建2个channel来发送
- (void)growingEventManagerChannels:(NSMutableArray<GrowingEventChannel *> *)channels {
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[@"vst"]
                                                            urlTemplate:@"v3/%@/ios/pv?stm=%llu"
                                                          isCustomEvent:NO]];
    [channels addObject:[GrowingEventChannel eventChannelWithEventTypes:@[@"reengage",@"activate"]
                                                             urlTemplate:@"app/%@/ios/ctvt"
                                                           isCustomEvent:NO]];
}

/// 拦截visit事件，并发出广告sdk的vst
- (void)growingEventManagerEventWillBuild:(GrowingBaseBuilder *_Nullable)builder {
    if (builder.eventType == GrowingEventTypeVisit) {
        GrowingAdvertisingVisitEvent *event = [[GrowingAdvertisingVisitEvent alloc] initWithBuilder:builder];
        [[GrowingEventManager shareInstance] writeToDatabaseWithEvent:event];
    }
}

- (id<GrowingRequestProtocol> _Nullable)growingEventManagerRequestWithChannel:(GrowingEventChannel *_Nullable)channel {
    if ([channel.eventTypes indexOfObject:@"vst"] != NSNotFound) {
        return [[GrowingAdvertisingVstRequest alloc] init];
    }

    if ([channel.eventTypes indexOfObject:@"reengage"] != NSNotFound) {
        return [[GrowingAdvertisingRequest alloc] init];
    }
    return nil;
}

#pragma mark - url extern

- (BOOL)isUrlShortChain:(NSURL *)url {
    if (!url) {
        return NO;
    }

    BOOL isShortChainUlink = ([url.host isEqualToString:@"gio.ren"] || [self isV1Url:url]) &&
                             [url.path componentsSeparatedByString:@"/"].count == 2;
    return isShortChainUlink;
}

- (BOOL)isV1Url:(NSURL *)url {
    return ([url.host isEqualToString:@"datayi.cn"] || [url.host hasSuffix:@".datayi.cn"]);
}
#pragma mark - extern

- (NSDictionary *)dictFromPastboard:(NSString *)clipboardString {
    if (clipboardString.length > 2000 * 16) {
        return nil;
    }
    NSString *binaryList = @"";
    for (int i = 0; i < clipboardString.length; i++) {
        char a = [clipboardString characterAtIndex:i];
        NSString *charString = @"";
        if (a == (char)020014) {
            charString = @"0";
        } else {
            charString = @"1";
        }
        binaryList = [binaryList stringByAppendingString:charString];
    }
    NSInteger binaryListLength = binaryList.length;
    NSInteger SINGLE_CHAR_LENGTH = 16;
    if (binaryListLength % SINGLE_CHAR_LENGTH != 0) {
        return nil;
    }
    NSMutableArray *bs = [NSMutableArray array];
    int i = 0;
    while (i < binaryListLength) {
        [bs addObject:[binaryList substringWithRange:NSMakeRange(i, SINGLE_CHAR_LENGTH)]];
        i += SINGLE_CHAR_LENGTH;
    }
    NSString *listString = @"";
    for (int i = 0; i < bs.count; i++) {
        NSString *partString = bs[i];
        long long part = [partString longLongValue];
        int partInt = [self convertBinaryToDecimal:part];
        listString = [listString stringByAppendingString:[NSString stringWithFormat:@"%C", (unichar)partInt]];
    }
    NSDictionary *dict = listString.growingHelper_jsonObject;
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}

- (int)convertBinaryToDecimal:(long long)n {
    int decimalNumber = 0, i = 0, remainder;
    while (n != 0) {
        remainder = n % 10;
        n /= 10;
        decimalNumber += remainder * pow(2, i);
        ++i;
    }
    return decimalNumber;
}

@end
