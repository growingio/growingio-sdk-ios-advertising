//
// GrowingActivateEvent.m
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

#import "GrowingAdvertising/Event/GrowingActivateEvent.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

@implementation GrowingActivateEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingActivateBuilder *subBuilder = (GrowingActivateBuilder *)builder;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
    }
    return self;
}

+ (GrowingActivateBuilder *)builder {
    return [[GrowingActivateBuilder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionary];
    dataDictM[@"u"] = self.deviceId;
    dataDictM[@"t"] = self.eventType;
    dataDictM[@"tm"] = @(self.timestamp);
    dataDictM[@"d"] = self.domain;
    dataDictM[@"dm"] = self.deviceModel;
    dataDictM[@"osv"] = self.platformVersion;
    dataDictM[@"iv"] = self.idfv;
    dataDictM[@"ui"] = self.idfa;
    dataDictM[@"gesid"] = @(self.globalSequenceId);
    dataDictM[@"esid"] = @(self.eventSequenceId);
    [dataDictM addEntriesFromDictionary:self.extraParams];
    return dataDictM;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation GrowingActivateBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

- (GrowingBaseEvent *)build {
    return [[GrowingActivateEvent alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return @"activate";
}

- (GrowingActivateBuilder *(^)(NSString *value))setIdfa {
    return ^(NSString *value) {
        self->_idfa = value;
        return self;
    };
}
- (GrowingActivateBuilder *(^)(NSString *value))setIdfv {
    return ^(NSString *value) {
        self->_idfv = value;
        return self;
    };
}

@end
#pragma clang diagnostic pop
