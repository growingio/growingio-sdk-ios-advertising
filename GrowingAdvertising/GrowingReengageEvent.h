//
// GrowingReengageEvent.h
// GrowingAnalytics-0cad4c59
//
//  Created by sheng on 2021/5/21.
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
//  limitations under the vLicense.

#import "GrowingBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN
@class GrowingReengageBuilder;

@interface GrowingReengageEvent : GrowingBaseEvent

@property (nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property (nonatomic, copy, readonly) NSString *_Nonnull idfv;

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

+ (GrowingReengageBuilder *_Nonnull)builder;

@end

@interface GrowingReengageBuilder : GrowingBaseBuilder

@property (nonatomic, copy, readonly) NSString *_Nonnull idfa;
@property (nonatomic, copy, readonly) NSString *_Nonnull idfv;

// new set methods
- (GrowingReengageBuilder * (^)(NSString *value))setIdfa;
- (GrowingReengageBuilder * (^)(NSString *value))setIdfv;

// override
- (GrowingReengageBuilder *_Nonnull (^)(NSDictionary *_Nonnull))setExtraParams;
@end

NS_ASSUME_NONNULL_END
