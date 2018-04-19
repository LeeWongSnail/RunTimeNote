//
//  ViewController.m
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "TypeEncoding.h"
#import "Objc_Property.h"
#import "Objc_Ivar.h"
#import "AssociatedObject.h"
#import "DataMap.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)typeEncoding_test
{
    TypeEncoding *typeE = [[TypeEncoding alloc] init];
    [typeE getTypeEncoding];
}

- (void)objcIvar_test
{
    Objc_Ivar *var = [[Objc_Ivar alloc] init];
    [var getIvarName];
}

- (void)objcProperty_test
{
    Objc_Property *prop = [[Objc_Property alloc] init];
    [prop getProperty];
}

- (void)associateObject_test
{
    AssociatedObject *view = [[AssociatedObject alloc] init];
    view.backgroundColor = [UIColor redColor];
    [view setTapActionWithBlock:^{
        NSLog(@"------");
    }];
    
    view.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:view];
}

- (void)dataMap_test
{
    
    NSDictionary *dict = @{@"name1": @"张三", @"status1": @"start"};
    NSDictionary *dict2 = @{@"name2": @"李四", @"status2": @"end"};
    DataMap *data = [[DataMap alloc] init];
    [data setDataWithDic:dict];
    DataMap *data2 = [[DataMap alloc] init];
    [data2 setDataWithDic:dict2];
    
    NSLog(@"data --- name=%@  status=%@",data.name,data.status);
    NSLog(@"data2 --- name=%@ status=%@",data2.name,data2.status);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self dataMap_test];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
