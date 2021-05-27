//
// GrowingAdvertisingVstRequest.m
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
//  limitations under the License.

#import "GrowingAdvertisingVstRequest.h"

#import "GrowingAdvertising.h"
#import "GrowingConfigurationManager.h"
#import "GrowingDeviceInfo.h"
#import "GrowingEventRequestAdapter.h"
#import "GrowingNetworkConfig.h"
#import "GrowingRequestAdapter.h"
#import "GrowingAdvertisingRequestJsonBodyAdpter.h"
#import "GrowingTimeUtil.h"
#import "NSString+GrowingHelper.h"

static NSString *const kGrowingTemporaryHost = @"https://api.growingio.com";

@implementation GrowingAdvertisingVstRequest
@synthesize events;
@synthesize outsize;
@synthesize stm;

- (instancetype)init {
    if (self = [super init]) {
        self.stm = [GrowingTimeUtil currentTimeMillis];
    }
    return self;
}

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodPOST;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = [[GrowingAdvertising shareInstance].configuration.dataCollectionServerHost
                            isEqualToString:defaultDataCollectionServerHost]
                            ? kGrowingTemporaryHost
                            : [GrowingAdvertising shareInstance].configuration.dataCollectionServerHost;
    ;
    if (!baseUrl.length) {
        return nil;
    }
    NSString *absoluteURLString = [baseUrl absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *accountId = [GrowingAdvertising shareInstance].configuration.projectId ?: @"";
    NSString *path = [NSString stringWithFormat:@"v3/%@/ios/pv", accountId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    // on 2.0 server, content-type muste be application/octet-stream, but application/json in 3.0
    headers[@"Content-Type"] = @"application/octet-stream";
    headers[@"X-Compress-Codec"] = @"3";
    headers[@"X-Crypt-Codec"] = @"1";
    headers[@"X-Timestamp"] = [NSString stringWithFormat:@"%lld", [GrowingTimeUtil currentTimeMillis]];
    GrowingRequestHeaderAdapter *basicHeaderAdapter = [GrowingRequestHeaderAdapter headerAdapterWithHeader:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter methodAdpterWithMethod:self.method];
    GrowingAdvertisingRequestJsonBodyAdpter *bodyAdapter =
        [GrowingAdvertisingRequestJsonBodyAdpter eventJsonBodyAdpter:self.events
                                                     timestamp:self.stm
                                                  outsizeBlock:^(unsigned long long bodySize) {
                                                      self.outsize = bodySize;
                                                  }];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, bodyAdapter, nil];
    return adapters;
}

- (NSDictionary *)query {
    NSString *stm = [NSString stringWithFormat:@"%llu", self.stm];
    return @{@"stm" : stm};
}

@end
