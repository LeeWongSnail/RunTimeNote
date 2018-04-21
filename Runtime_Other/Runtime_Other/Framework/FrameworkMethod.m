//
//  FrameworkMethod.m
//  Runtime_Other
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "FrameworkMethod.h"
#import <objc/runtime.h>

@implementation FrameworkMethod


/**
获取所有加载的Objective-C框架和动态库的名称
 */
- (void)copyImageName
{
    unsigned int outCount = 0;
    const char **names = objc_copyImageNames(&outCount);
    for (int i = 0; i < outCount; i++) {
        char *name = names[i];
        NSLog(@"%s",*names);
    }
}


/**
 获取指定库或框架中所有类的类名
 */
- (void)getFrameworkInfo
{
    NSLog(@"获取指定类所在动态库");
    //获取指定类所在动态库
    NSLog(@"UIView's Framework: %s", class_getImageName(NSClassFromString(@"UIView")));
    NSLog(@"获取指定库或框架中所有类的类名");
    unsigned int outCount = 0;
    const char ** classes = objc_copyClassNamesForImage(class_getImageName(NSClassFromString(@"UIView")), &outCount);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"class name: %s", classes[i]);
    }
}

@end
