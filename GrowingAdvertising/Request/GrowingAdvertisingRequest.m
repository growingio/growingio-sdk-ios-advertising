//
// GrowingAdvertisingRequest.m
// GrowingAdvertising
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

#import "GrowingAdvertising/Request/GrowingAdvertisingRequest.h"
#import "GrowingAdvertising/Request/Adapter/GrowingAdvertisingRequestAdapter.h"
#import "GrowingAdvertising/Request/Adapter/GrowingAdvertisingRequestHeaderAdapter.h"
#import "GrowingAdvertising/Public/GrowingAdvertising.h"

#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

static NSString *const kGrowingTemporaryHost = @"https://t.growingio.com";

@implementation GrowingAdvertisingRequest
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
    NSString *baseUrl = [[GrowingAdvertising sharedInstance].configuration.dataCollectionServerHost
                            isEqualToString:kGrowingDefaultDataCollectionServerHost]
                            ? kGrowingTemporaryHost
                            : [GrowingAdvertising sharedInstance].configuration.dataCollectionServerHost;
    ;
    if (!baseUrl.length) {
        return nil;
    }
    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *accountId = [GrowingAdvertising sharedInstance].configuration.projectId ?: @"";
    NSString *path = [NSString stringWithFormat:@"app/%@/ios/ctvt", accountId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    // on 2.0 server, content-type must be application/octet-stream
    NSDictionary *headers = @{@"Content-Type" : @"application/octet-stream"};
    GrowingAdvertisingRequestHeaderAdapter *basicHeaderAdapter = [GrowingAdvertisingRequestHeaderAdapter adapterWithRequest:self
                                                                                                                     header:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    GrowingAdvertisingRequestAdapter *bodyAdapter = [GrowingAdvertisingRequestAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, bodyAdapter, nil];
    return adapters;
}

- (NSDictionary *)query {
    NSString *stm = [NSString stringWithFormat:@"%llu", self.stm];
    return @{@"stm" : stm};
}

@end
