//
//  GrowingAdvertConfiguration.m
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

#import "GrowingAdvertising/Public/GrowingAdvertConfiguration.h"

NSString *const GrowingAdvertisingErrorDomain = @"com.growingio.advertising";

@implementation GrowingAdvertConfiguration

- (instancetype)initWithProjectId:(NSString *)projectId urlScheme:(NSString *)urlScheme {
    self = [super init];
    if (self) {
        _projectId = [projectId copy];
        _urlScheme = [urlScheme copy];
        _deepLinkCallback = nil;
        _dataCollectionEnabled = YES;
        _readClipBoardEnabled = YES;
    }

    return self;
}

+ (instancetype)configurationWithProjectId:(NSString *)projectId urlScheme:(NSString *)urlScheme {
    return [[self alloc] initWithProjectId:projectId urlScheme:urlScheme];
}

- (id)copyWithZone:(NSZone *)zone {
    GrowingAdvertConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration->_projectId = [_projectId copy];
    configuration->_urlScheme = [_urlScheme copy];
    configuration->_deepLinkCallback = [_deepLinkCallback copy];
    configuration->_dataCollectionEnabled = _dataCollectionEnabled;
    configuration->_readClipBoardEnabled = _readClipBoardEnabled;
    return configuration;
}

@end
