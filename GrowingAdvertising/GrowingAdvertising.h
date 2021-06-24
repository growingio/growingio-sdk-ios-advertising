//
// GrowingAdvertisingParser.h
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


#import <Foundation/Foundation.h>
#import "GrowingTrackConfiguration.h"
#import "GrowingModuleProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface GrowingAdvertising : NSObject <GrowingModuleProtocol>

@property (nonatomic, strong, readonly) GrowingTrackConfiguration *configuration;
///如果你想额外处理deeplink的custom_params参数
@property (nonatomic, copy) void (^deeplinkHandler)(NSDictionary *params, NSTimeInterval processTime, NSError *error);
@property (nonatomic, copy, readonly) NSString *urlScheme;

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration
                     urlScheme:(NSString *)urlScheme
                      callback:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))handler;

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration
                     urlScheme:(NSString *)urlScheme;

+ (instancetype)sharedInstance;

/// 打开或关闭数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;


/**
 * 手动触发GrowingIO的deeplink处理逻辑， 根据传入的url
 * 处理GrowingIO的相应结果参数格式与错误信息见{@link DeepLinkCallback}
 *
 * @param url      对应需要处理的GrowingIO deeplink或applink url
 * @param handler 处理结果的回调, 如果handler为null, 回调会使用初始化时传入的默认deeplinkHandler
 * @return true: url是GrowingIO的deeplink链接格式 false: url不是GrowingIO的deeplink链接格式
 */
- (void)doDeeplinkByUrl:(NSURL *)url callback:(void (^)(NSDictionary *params, NSTimeInterval processTime, NSError *error))handler;

@end

NS_ASSUME_NONNULL_END
