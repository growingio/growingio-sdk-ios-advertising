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
}

@end
