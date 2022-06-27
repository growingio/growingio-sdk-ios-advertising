//
//  GrowingAdvertConfiguration.h
//  GrowingAdvertising
//
//  Created by YoloMao on 2022/6/22.
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , GrowingAdvertisingError) {
    GrowingAdvertisingNoQueryError = 500, /// 无自定义参数
    GrowingAdvertisingIllegalURLError,    /// 非法URL
    GrowingAdvertisingRequestFailedError, /// 短链请求失败
};

extern NSString *const GrowingAdvertisingErrorDomain;

typedef void(^_Nullable GrowingAdDeepLinkCallback)(NSDictionary * _Nullable params,
                                                   NSTimeInterval processTime,
                                                   NSError * _Nullable error);

@interface GrowingAdvertConfiguration : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *projectId;
@property (nonatomic, copy, readonly) NSString *urlScheme;
@property (nonatomic, copy) GrowingAdDeepLinkCallback deepLinkCallback;
@property (nonatomic, assign) BOOL dataCollectionEnabled;
@property (nonatomic, assign) BOOL readClipBoardEnabled;

- (instancetype)initWithProjectId:(NSString *)projectId urlScheme:(NSString *)urlScheme;

+ (instancetype)configurationWithProjectId:(NSString *)projectId urlScheme:(NSString *)urlScheme;

@end

NS_ASSUME_NONNULL_END
