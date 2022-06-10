//
//  ViewController.m
//  Example
//
//  Created by sheng on 2021/5/27.
//

#import "ViewController.h"

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
    hint.center = self.view.center;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 110, 50);
    button.layer.cornerRadius = 5.0f;
    button.backgroundColor = UIColor.systemBlueColor;
    button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [button setTitle:@"Send Reengage" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    CGPoint center = hint.center;
    center.y += 100.0f;
    button.center = center;
}

- (void)buttonAction {
    NSString *url = @"growing.54e804b6de39cd4a://growing?link_id=dMbpE"
                    @"&click_id=85b9310f-d903-4b02-ae7d-3b696e730937&tm_click=1654775879497&custom_params=%7B%7D";
    Class cls = NSClassFromString(@"GrowingDeepLinkHandler");
    SEL selector = NSSelectorFromString(@"handlerUrl:");
    [cls performSelector:selector withObject:[NSURL URLWithString:url]];
}

@end
