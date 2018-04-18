//
//  ViewController.m
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "ClassMRC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)objc_mrcTest
{
    ClassMRC *mrc = [[ClassMRC alloc] init];
//    [mrc createInstance];
    [mrc class_destoryInstance];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
