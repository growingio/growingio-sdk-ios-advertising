//
// GrowingAdvertising.h
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

#import <Foundation/Foundation.h>
#import "GrowingAdvertConfiguration.h"
#import "GrowingModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GrowingAdvertising : NSObject <GrowingModuleProtocol>

@property (nonatomic, copy, readonly) NSString *projectId;
@property (nonatomic, copy, readonly) NSString *urlScheme;

/// 初始化GrowingAdvertising，请确保在GrowingAnalytics初始化代码之前
/// @param configuration 配置信息
+ (void)startWithConfiguration:(GrowingAdvertConfiguration *)configuration;

/// 单例获取
+ (instancetype)sharedInstance;

/// 打开或关闭activate、reengage数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;

/// 打开或关闭剪贴板读取
/// @param enabled 打开或者关闭
- (void)setReadClipBoardEnabled:(BOOL)enabled;

/// 根据传入的url，手动触发GrowingIO的deeplink处理逻辑
/// @param url 对应需要处理的GrowingIO deeplink或applink url
/// @param callback 处理结果的回调, 如果callback为null, 回调会使用初始化时传入的默认deepLinkCallback
/// @return url是否是GrowingIO的deeplink链接格式
- (BOOL)doDeeplinkByUrl:(NSURL *)url callback:(GrowingAdDeepLinkCallback)callback;

@end

NS_ASSUME_NONNULL_END
