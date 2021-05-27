//
// GrowingActivateEvent.m
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

#import "GrowingActivateEvent.h"

@implementation GrowingActivateEvent

+ (GrowingActivateBuilder *_Nonnull)builder {
    return [[GrowingActivateBuilder alloc] init];
}

- (NSString *)eventType {
    return @"activate";
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dataDictM = [NSMutableDictionary dictionary];
    dataDictM[@"u"] = self.deviceId;
    dataDictM[@"t"] = self.eventType;
    dataDictM[@"d"] = self.domain;
    dataDictM[@"dm"] = self.deviceModel;
    dataDictM[@"osv"] = self.platformVersion;
    dataDictM[@"tm"] = @(self.timestamp);
    dataDictM[@"iv"] = self.idfv;
    dataDictM[@"ui"] = self.idfa;
    dataDictM[@"gesid"] = @(self.globalSequenceId);
    dataDictM[@"esid"] = @(self.eventSequenceId);
    [dataDictM addEntriesFromDictionary:self.extraParams];
    return dataDictM;
}

@end

@implementation GrowingActivateBuilder

- (NSString *)eventType {
    return @"activate";
}

- (GrowingBaseEvent *)build {
    return [[GrowingActivateEvent alloc] initWithBuilder:self];
}

@end