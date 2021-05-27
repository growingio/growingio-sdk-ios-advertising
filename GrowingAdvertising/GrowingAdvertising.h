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

NS_ASSUME_NONNULL_BEGIN

@interface GrowingAdvertising : NSObject

@property (nonatomic, strong, readonly) GrowingTrackConfiguration *configuration;
///如果你想额外处理deeplink的custom_params参数
@property (nonatomic, copy) void (^deeplinkHandler)(NSDictionary *params, NSTimeInterval processTime, NSError *error);

+ (void)startWithConfiguration:(GrowingTrackConfiguration *)configuration;

+ (instancetype)shareInstance;

/// 打开或关闭数据采集
/// @param enabled 打开或者关闭
- (void)setDataCollectionEnabled:(BOOL)enabled;



@end

NS_ASSUME_NONNULL_END
