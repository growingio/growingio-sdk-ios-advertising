//
// GrowingReengageEvent.m
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

#import "GrowingAdvertising/Event/GrowingReengageEvent.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"

@implementation GrowingReengageEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingReengageBuilder *subBuilder = (GrowingReengageBuilder *)builder;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
    }
    return self;
}

+ (GrowingReengageBuilder *_Nonnull)builder {
    return [[GrowingReengageBuilder alloc] init];
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
    dataDictM[@"ui"] = self.idfa;
    dataDictM[@"iv"] = self.idfv;
    dataDictM[@"gesid"] = @(self.globalSequenceId);
    dataDictM[@"esid"] = @(self.eventSequenceId);
    [dataDictM addEntriesFromDictionary:self.extraParams];
    return dataDictM;
}

@end

@implementation GrowingReengageBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

- (GrowingBaseEvent *)build {
    return [[GrowingReengageEvent alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return @"reengage";
}

- (GrowingReengageBuilder *(^)(NSString *value))setIdfa {
    return ^(NSString *value) {
        self->_idfa = value;
        return self;
    };
}
- (GrowingReengageBuilder *(^)(NSString *value))setIdfv {
    return ^(NSString *value) {
        self->_idfv = value;
        return self;
    };
}

@end
