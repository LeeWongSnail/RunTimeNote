//
//  ViewController.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "ResolveMethod.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)resolveMethod
{
    ResolveMethod *method = [[ResolveMethod alloc] init];
    [method noIMPInstanceMethod];
    [ResolveMethod noIMPClassMethod];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self resolveMethod];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end