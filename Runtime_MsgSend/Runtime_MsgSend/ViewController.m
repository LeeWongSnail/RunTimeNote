//
//  ViewController.m
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "Runtime_SEL.h"
#import "Runtime_Method.h"
#import "Runtime_MsgSend.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)sel_test
{
    Runtime_SEL *sel = [[Runtime_SEL alloc] init];
//    [sel getSEL];
    [sel compareSEL];
}

- (void)method_test
{
    Runtime_Method *m = [[Runtime_Method alloc] init];
//    [m invoke_test];
//    [m getMethodName];
//    [m getTypeEncoding];
//    [m copyReturnType];
//    [m copyArguType];
//    [m setIMP];
//    [m exchangeMethod];
}

- (void)sendMsg
{
    Runtime_MsgSend *send = [[Runtime_MsgSend alloc] init];
//    [send msgSend_test];
    [send getMethodAddress];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self sendMsg];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
