//
//  ViewController.m
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "ObjcCreate_MRC.h"
#import "Objcect_Instance_MRC.h"
#import "Objc_ClassList.h"
#import "ObjcClass.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)objc_mrcTest
{
    ObjcCreate_MRC *mrc = [[ObjcCreate_MRC alloc] init];
//    [mrc createInstance];
    [mrc class_destoryInstance];
    
//    [mrc copyAtoBWithClass];
}

- (void)object_method
{
    Objcect_Instance_MRC *mrc = [[Objcect_Instance_MRC alloc] init];
//    [mrc setInstanceValue];
//    [mrc getInstanceValue];
//    [mrc getIvarAtIndex];
//    [mrc getIvarValue];
    [mrc setIvarValue];
}

- (void)objc_Class
{
    ObjcClass *cls = [[ObjcClass alloc] init];
//    [cls getClassName];
//    [cls getClass];
    [cls setObjClass];
}

- (void)objc_classList
{
    Objc_ClassList *list = [[Objc_ClassList alloc] init];
//    [list getClassList];
//    [list copyClassList];
    [list getSpecificClass];
//    [list getMetaClass];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self objc_classList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
