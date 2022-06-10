//
// GrowingAdvertisingVisitEvent.m
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

#import "GrowingAdvertising/Event/GrowingAdvertisingVisitEvent.h"
#import "GrowingTrackerCore/Utils/GrowingDeviceInfo.h"
#import "GrowingTrackerCore/GrowingRealTracker.h"

@implementation GrowingAdvertisingVisitEvent

- (instancetype)initWithBuilder:(GrowingBaseBuilder *)builder {
    if (self = [super initWithBuilder:builder]) {
        GrowingAdvertisingVisitBuilder *subBuilder = (GrowingAdvertisingVisitBuilder *)builder;
        _idfa = subBuilder.idfa;
        _idfv = subBuilder.idfv;
    }
    return self;
}

+ (GrowingAdvertisingVisitBuilder *_Nonnull)builder {
    return [[GrowingAdvertisingVisitBuilder alloc] init];
}

- (GrowingEventSendPolicy)sendPolicy {
    return GrowingEventSendPolicyInstant;
}

#pragma mark GrowingEventTransformable

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionary];
    if (self.extraParams.count > 0) {
        [dataDictM addEntriesFromDictionary:self.extraParams];
    }
    dataDictM[@"u"] = self.deviceId;
    dataDictM[@"s"] = self.sessionId;
    dataDictM[@"t"] = self.eventType;
    dataDictM[@"tm"] = @(self.timestamp);
    dataDictM[@"av"] = GrowingTrackerVersionName;
    dataDictM[@"d"] = self.domain;
    dataDictM[@"sh"] = @(self.screenHeight);
    dataDictM[@"sw"] = @(self.screenWidth);
    dataDictM[@"db"] = self.deviceBrand;
    dataDictM[@"dm"] = self.deviceModel;
    dataDictM[@"ph"] = self.deviceType;
    dataDictM[@"os"] = self.platform;
    dataDictM[@"osv"] = self.platformVersion;
    dataDictM[@"cv"] = self.appVersion;
    dataDictM[@"l"] = self.language;
    dataDictM[@"lat"] = ABS(self.latitude) > 0 ? @(self.latitude) : nil;
    dataDictM[@"lng"] = ABS(self.longitude) > 0 ? @(self.longitude) : nil;
    dataDictM[@"gesid"] = @(self.globalSequenceId);
    dataDictM[@"esid"] = @(self.eventSequenceId);
    dataDictM[@"ui"] = self.idfa;
    dataDictM[@"iv"] = self.idfv;
    dataDictM[@"cs1"] = self.userId;
    dataDictM[@"v"] = self.urlScheme;
    return dataDictM;
}

@end

@implementation GrowingAdvertisingVisitBuilder

- (void)readPropertyInTrackThread {
    [super readPropertyInTrackThread];
    GrowingDeviceInfo *deviceInfo = [GrowingDeviceInfo currentDeviceInfo];
    _idfa = deviceInfo.idfa;
    _idfv = deviceInfo.idfv;
}

- (GrowingBaseEvent *)build {
    return [[GrowingAdvertisingVisitEvent alloc] initWithBuilder:self];
}

- (NSString *)eventType {
    return @"vst";
}

- (GrowingAdvertisingVisitBuilder *(^)(NSString *value))setIdfa {
    return ^(NSString *value) {
        self->_idfa = value;
        return self;
    };
}
- (GrowingAdvertisingVisitBuilder *(^)(NSString *value))setIdfv {
    return ^(NSString *value) {
        self->_idfv = value;
        return self;
    };
}

@end
