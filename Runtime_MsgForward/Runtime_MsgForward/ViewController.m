//
//  ViewController.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import "ResolveMethod.h"
#import "ForwardTarget.h"
#import "ForwardInvocation.h"
#import "MultipleInheritance.h"

#import "SomeClass.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)resolveMethod
{
    ResolveMethod *method = [[ResolveMethod alloc] init];
    [method noIMPInstanceMethod];
    [ResolveMethod noIMPClassMethod];
}

- (void)forwardTarget
{
    ForwardTarget *target = [[ForwardTarget alloc] init];
//    [target noIMPInstanceMethod];
    [ForwardTarget noIMPClassMethod];
}

- (void)invokeWithInvocation
{
    ForwardInvocation *invo = [[ForwardInvocation alloc] init];
//    [invo noIMPInstanceMethod];
    [ForwardInvocation noIMPClassMethod];
}


/**
 模拟多继承
 */
- (void)multiInherit
{
    MultipleInheritance *mh = [[MultipleInheritance alloc] init];
    [mh eat];
    
    if ([mh isKindOfClass:[SomeClass class]]) {
        NSLog(@"mh 是 SomeClass 类型的");
    }
    
    if ([mh isKindOfClass:[Father class]]) {
        NSLog(@"mh 是 Father 类型的");
    }
    
    if ([mh respondsToSelector:@selector(drink)]) {
        NSLog(@"mh 实现了drink方法");
        [mh performSelector:@selector(drink)];
    }
    
    if ([mh respondsToSelector:@selector(eat)]) {
        NSLog(@"mh 实现了eat方法");
        [mh performSelector:@selector(eat)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self multiInherit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
