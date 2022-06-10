//
//  GrowingAdvertisingRequestHeaderAdapter.m
//  GrowingAdvertising
//
//  Created by YoloMao on 2022/6/9.
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

#import "GrowingAdvertising/Request/Adapter/GrowingAdvertisingRequestHeaderAdapter.h"
#import "GrowingTrackerCore/Utils/GrowingTimeUtil.h"

@interface GrowingAdvertisingRequestHeaderAdapter ()

@property (nonatomic, weak) id <GrowingRequestProtocol> request;
@property (nonatomic, copy) NSDictionary *header;

@end

@implementation GrowingAdvertisingRequestHeaderAdapter

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request {
    return [self adapterWithRequest:request header:nil];
}

+ (instancetype)adapterWithRequest:(id <GrowingRequestProtocol>)request
                            header:(NSDictionary * _Nullable)header {
    GrowingAdvertisingRequestHeaderAdapter *adapter = [[self alloc] init];
    adapter.request = request;
    adapter.header = header;
    return adapter;
}

- (NSMutableURLRequest *)adaptedURLRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest *needAdaptReq = request;
    
    [needAdaptReq setValue:[NSString stringWithFormat:@"%lld",[GrowingTimeUtil currentTimeMillis]]
        forHTTPHeaderField:@"X-Timestamp"];
    [needAdaptReq setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (!self.header.count) {
        return needAdaptReq;
    }
    
    for (NSString *key in self.header) {
        [needAdaptReq setValue:self.header[key] forHTTPHeaderField:key];
    }

    return needAdaptReq;
}

- (NSUInteger)priority {
    return 0;
}

@end
