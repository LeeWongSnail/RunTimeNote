//
//  Ivar.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassIvar.h"
#import <objc/runtime.h>
#import "Son.h"

@implementation ClassIvar


/**
 它返回一个指向包含name指定的成员变量信息的objc_ivar结构体的指针(Ivar)。
 */
- (void)getInstanceVariable
{
    Ivar var = class_getInstanceVariable([self class], "_name");
    NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
}


/**
 啥是类变量
 目前没有找到关于Objective-C中类变量的信息，一般认为Objective-C不支持类变量。注意，返回的列表不包含父类的成员变量和属性
 */
- (void)getClassVariable
{
    
}


/**
 获取实例变量的列表
 它返回一个指向成员变量信息的数组，数组中每个元素是指向该成员变量信息的objc_ivar结构体的指针。
 这个数组不包含在父类中声明的变量。outCount指针返回数组的大小。需要注意的是，我们必须使用free()来释放这个数组。
 */
- (void)getIvarList
{
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList([Son class], &count);
    for (int i = 0 ; i <count; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
    free(vars);
}


/**
 只有在运行时添加的类 才可以条件成员变量
 Objective-C不支持往已存在的类中添加实例变量，因此不管是系统库提供的提供的类，还是我们自定义的类，都无法动态添加成员变量。
 但如果我们通过运行时来创建一个类的话，又应该如何给它添加成员变量呢？这时我们就可以使用class_addIvar函数了。
 不过需要注意的是，这个方法只能在objc_allocateClassPair函数与objc_registerClassPair之间调用。
 另外，这个类也不能是元类。成员变量的按字节最小对齐量是1<<alignment。这取决于ivar的类型和机器的架构。
 如果变量的类型是指针类型，则传递log2(sizeof(pointer_type))。
 */
- (void)addIvarDynamic
{
    Class cls = objc_allocateClassPair(NSObject.class, "Person", 0);
    class_addIvar(cls, "_nickname", sizeof(NSString *), log(sizeof(NSString *)), "i");
    objc_registerClassPair(cls);
    id instance = [[cls alloc] init];
    
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList([instance class], &count);
    for (int i = 0 ; i <count; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
    free(vars);
}

@end
