//
//  ViewController.m
//  Runtime_Other
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "MsgSendSuper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)superDemo
{
    MsgSendSuper *sender = [[MsgSendSuper alloc] init];
    [sender someInstanceMethod];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self superDemo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
