//
//  ViewController.m
//  GrowingAdvertising
//
//  Created by YoloMao on 2022/6/27.
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


#import "ViewController.h"
#import "GrowingAdvertising.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectZero];
    hint.text = @"这是一个Example，\n用于测试activate,reengage,vst";
    hint.numberOfLines = 0;
    hint.textAlignment = NSTextAlignmentCenter;
    [hint sizeToFit];
    [self.view addSubview:hint];
    CGPoint center0 = self.view.center;
    center0.y -= 100.0f;
    hint.center = center0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 110, 40);
    button.layer.cornerRadius = 5.0f;
    button.backgroundColor = UIColor.systemBlueColor;
    button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [button setTitle:@"Do DeepLink" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    CGPoint center = hint.center;
    center.y += 100.0f;
    button.center = center;
    button.tag = 1;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 0, 110, 40);
    button2.layer.cornerRadius = 5.0f;
    button2.backgroundColor = UIColor.systemBlueColor;
    button2.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [button2 setTitle:@"Do UniversalLink" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    CGPoint center2 = button.center;
    center2.y += 50.0f;
    button2.center = center2;
    button2.tag = 2;
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(0, 0, 110, 40);
    button3.layer.cornerRadius = 5.0f;
    button3.backgroundColor = UIColor.systemBlueColor;
    button3.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [button3 setTitle:@"Manual Test" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(copyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    CGPoint center3 = button2.center;
    center3.y += 50.0f;
    button3.center = center3;
}

- (void)buttonAction:(UIButton *)button {
    NSString *url = button.tag == 1
    ? @"growing.54e804b6de39cd4a://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937&tm_click=1654775879497&custom_params=%7B%22key%22%3A%22value%22%2C%22key2%22%3A%22value2%22%7D"
    : @"https://datayi.cn/v8dsd7MWy";
    
    __weak typeof(self) weakSelf = self;
    [[GrowingAdvertising sharedInstance] doDeeplinkByUrl:[NSURL URLWithString:url] callback:^(NSDictionary * _Nullable params,
                                                                                              NSTimeInterval processTime,
                                                                                              NSError * _Nullable error) {
        NSLog(@"预置doDeeplinkByUrl点击 params is : %@",params);
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"手动触发inapp"
                                                                            message:[NSString stringWithFormat:@"%@", params]
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf.view.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)copyButtonAction {
    NSString *string = @"\n"
    @"圈选：\n"
    @"growing.54e804b6de39cd4a://growingio/webservice?serviceType=circle&wsUrl=ws://uat-gdp.growingio.com/app/weDq7mpE/circle/f1bcb578cdc347fc872192b55d2bb764\n"
    @"\n"
    @"短链1-无参数：\n"
    @"https://datayi.cn/v8dsd2kdN\n"
    @"\n"
    @"短链2-带参数:\n"
    @"https://datayi.cn/v8dsd7MWy\n"
    @"\n"
    @"长链-urlscheme无参数：\n"
    @"growing.54e804b6de39cd4a://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937&tm_click=1654775879497&custom_params=%7B%7D\n"
    @"\n"
    @"长链-urlscheme带参数：\n"
    @"growing.54e804b6de39cd4a://growing?link_id=dMbpE&click_id=85b9310f-d903-4b02-ae7d-3b696e730937&tm_click=1654775879497&custom_params=%7B%22key%22%3A%22value%22%2C%22key2%22%3A%22value2%22%7D\n"
    @"\n"
    @"长链-universallink无参数：\n"
    @"https://datayi.cn/u/AP3BJMA3/d2kdN?link_id=d2kdN&click_id=4878009c-dd0a-4d77-b70f-b003d3bea610&tm_click=1655971050477&custom_params=%7B%7D\n"
    @"\n"
    @"长链-universallink带参数：\n"
    @"https://datayi.cn/u/AP3BJMA3/dPrj8?link_id=dPrj8&click_id=e943b0fe-6fdd-4187-a8d3-a411e8f503fb&tm_click=1655898560655&custom_params=%7B%22key3%22%3A%22value3%22%2C%22key4%22%3A%22value4%22%7D\n";
    UIPasteboard.generalPasteboard.string = string;

    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"拷贝完成"
                                                                        message:@"请粘贴到备忘录后，进行测试"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"mobilenotes://"];
        if ([UIApplication.sharedApplication canOpenURL:url]) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [self.view.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
