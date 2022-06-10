//
// GrowingDeepLinkRequest.m
// GrowingAdvertising
//
//  Created by sheng on 2021/5/12.
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

#import "GrowingAdvertising/Request/GrowingAdvertisingPreRequest.h"
#import "GrowingAdvertising/Request/Adapter/GrowingAdvertisingRequestHeaderAdapter.h"
#import "GrowingAdvertising/Public/GrowingAdvertising.h"

#import "GrowingTrackerCore/Network/Request/Adapter/GrowingRequestAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/Helpers/NSString+GrowingHelper.h"

@implementation GrowingAdvertisingPreRequest

static NSString *const kGrowingTemporaryHost = @"https://t.growingio.com";

- (GrowingHTTPMethod)method {
    return GrowingHTTPMethodGET;
}

- (NSURL *)absoluteURL {
    NSString *baseUrl = [[GrowingAdvertising sharedInstance].configuration.dataCollectionServerHost
                            isEqualToString:kGrowingDefaultDataCollectionServerHost]
                            ? kGrowingTemporaryHost
                            : [GrowingAdvertising sharedInstance].configuration.dataCollectionServerHost;
    if (!baseUrl.length) {
        return nil;
    }
    NSString *absoluteURLString = [baseUrl growingHelper_absoluteURLStringWithPath:self.path andQuery:self.query];
    return [NSURL URLWithString:absoluteURLString];
}

- (NSString *)path {
    NSString *accountId = [GrowingAdvertising sharedInstance].configuration.projectId ?: @"";
    NSString *bundleId = [GrowingDeviceInfo currentDeviceInfo].bundleID;
    NSString *path = [NSString stringWithFormat:@"app/at6/%@/ios/%@/%@/%@", self.isManual ? @"inapp" : @"defer",
                                                accountId, bundleId, self.hashId];
    return path;
}

- (NSArray<id<GrowingRequestAdapter>> *)adapters {
    NSDictionary *headers = @{@"Content-Type" : @"application/json",
                              @"User-Agent" : self.userAgent};
    GrowingAdvertisingRequestHeaderAdapter *basicHeaderAdapter = [GrowingAdvertisingRequestHeaderAdapter adapterWithRequest:self
                                                                                                                     header:headers];
    GrowingRequestMethodAdapter *methodAdapter = [GrowingRequestMethodAdapter adapterWithRequest:self];
    NSMutableArray *adapters = [NSMutableArray arrayWithObjects:basicHeaderAdapter, methodAdapter, nil];
    return adapters;
}

@end
