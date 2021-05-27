//
//  GrowingAdvertisingRequestJsonBodyAdpter.m
//  GrowingAdvertising
//
//  Created by sheng on 2021/5/27.
//

#import "GrowingAdvertisingRequestJsonBodyAdpter.h"
#import "NSData+GrowingHelper.h"
@interface GrowingAdvertisingRequestJsonBodyAdpter ()

@property (nonatomic, strong) NSArray <NSString *> *events;
@property (nonatomic, assign, readwrite) unsigned long long timestamp;
@property (nonatomic, copy) void(^outsizeBlock)(unsigned long long) ;

@end

@implementation GrowingAdvertisingRequestJsonBodyAdpter

+ (instancetype)eventJsonBodyAdpter:(NSArray<NSString *> *)events
                          timestamp:(unsigned long long)timestamp
                       outsizeBlock:(nonnull void (^)(unsigned long long))outsizeBlock {
    GrowingAdvertisingRequestJsonBodyAdpter *bodyAdapter = [[GrowingAdvertisingRequestJsonBodyAdpter alloc] init];
    bodyAdapter.events = events;
    bodyAdapter.timestamp = timestamp;
    bodyAdapter.outsizeBlock = outsizeBlock;
    return bodyAdapter;
}

// on 2.0 version, must encrypt
- (NSMutableURLRequest *)adaptedRequest:(NSMutableURLRequest *)request {
    if (!self.events.count) {
        return nil;
    }
    NSData *JSONData = nil;
    @autoreleasepool {
        // jsonString malloc to much
        NSString *jsonString = [self buildJSONStringWithEvents:self.events];
        JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        JSONData = [JSONData growingHelper_LZ4String];
        JSONData = [JSONData growingHelper_xorEncryptWithHint:(self.timestamp & 0xFF)];
    }
    if (self.outsizeBlock) {
        self.outsizeBlock(JSONData.length);
    }
    NSMutableURLRequest *needAdaptReq = request;
    needAdaptReq.HTTPBody = JSONData;
    
    return needAdaptReq;
}

- (NSString *)buildJSONStringWithEvents:(NSArray<NSString *> *)events {
    return [NSString stringWithFormat:@"[%@]", [events componentsJoinedByString:@","]];
}

@end
