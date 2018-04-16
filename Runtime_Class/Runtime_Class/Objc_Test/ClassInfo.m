//
//  ClassInfo.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassInfo.h"
#import <objc/runtime.h>

@implementation ClassInfo

/**
 获取类名

 @return 返回类名
 */
- (NSString *)getClassName
{
    return [NSString stringWithFormat:@"current class name : %s",class_getName([self class])];
}


/**
 返回类的版本

 @return 类的版本号
 */
- (long)getClassVersion
{
    NSLog(@"current class version %d",class_getVersion([self class]));
    return class_getVersion([self class]);
}


/**
 设置类的版本
 我们可以使用这个字段来提供类的版本信息。这对于对象的序列化非常有用，它可是让我们识别出不同类定义版本中实例变量布局的改变
 */
- (void)setClassVersion
{
    NSLog(@"add version");
    class_setVersion([self class], class_getVersion([self class])+1);
}


/**
 获取实例对象的大小

 @return 实例对象的大小
 */
- (long)getInstanceSize
{
    NSLog(@"class instance size = %ld",class_getInstanceSize([self class]));
    return class_getInstanceSize([self class]);
}

@end
