//
//  ViewController.m
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "Runtime_Category.h"
#import "Category+Demo.h"
#import "Runtime_Protocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)categoryTest
{
    Runtime_Category *cate = [[Runtime_Category alloc] init];
    [cate getInstanceMethods];
    
//    [cate getClassMethods];
}


- (void)protocol_test
{
    Runtime_Protocol *prop = [[Runtime_Protocol alloc] init];
//    [prop getProtocol];
//    [prop getProtocolList];
    [prop addProtocolDurRuntime];
//    [prop copyProtocolPropertyList];
//    [prop protocolEqual];
//    [prop getSpecificProperty];
    
//    [prop protocolConformProtocol];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self protocol_test];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
