//
//  Objc_Instance.m
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Objcect_Instance_MRC.h"
#import "Father.h"
#import <objc/runtime.h>

@implementation Objcect_Instance_MRC

/**
 修改类实例的实例变量的值
 注意 不要修改实例变量的类型 如果你在这个方法中修改了name属性的值 但是因为name属性默认是NSCFString的类型 你改了之后
 会变成NSString类型 因此可能会导致野指针
 */
- (void)setInstanceValue
{
    self.dict = @{@"name":@"Lee"};
    
    NSDictionary *dict1 = @{@"name":@"LeeWong"};
    
    object_setInstanceVariable(self, "_dict", dict1);

    NSLog(@"%@",self.dict);
}




/**
 获取一个实例变量的值
 内部实现是先通过object_getInstanceVariable获取Ivar，然后调用object_getIvar获取Ivar的值，并把值赋值给outValue，然后返回Ivar
 */
- (void)getInstanceValue
{
    self.name = @"LeeWong";
    NSString *getName = @"copy";
    //obj 需要获取的实例变量的类的对象。 name 变量的名字。outValue 指向实例变量值的指针
    object_getInstanceVariable(self, "_name", (void *)&getName);
    NSLog(@"%@",getName);
}


/**
 创建ivar时，runtime会在ivar的内存存储区域后面再分配一点额外的空间，
 也就是id class_createInstance(Class cls, size_t extraBytes)中的extraBytes。
 这个而函数用于获取extraBytes。利用这块空间的起始指针可以索引实例变量（ivars）。
 */
- (void)getIvarAtIndex
{
    NSArray *arrT = @[@"1",@"2",@"3"];
    void *ivar = object_getIndexedIvars(arrT);
    
    NSLog(@"%@", *(id *)(ivar + 0));
    NSLog(@"%@", *(id *)(ivar + sizeof(NSArray*)));
    NSLog(@"%@", *(id *)(ivar + sizeof(NSArray*)*2));
    
}


/**
 读取变量的值
 */
- (void)getIvarValue
{
    self.name = @"LeeWong";
    //object 包含该变量的对象。ivar 需要被读取的变量
    //在已经知道ivar的情况下，这个函数比object_getInstanceVariable更快
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    NSLog(@"%@",object_getIvar(self, ivar));
}


/**
 设置变量的值。
 在已经知道ivar的情况下，这个函数比object_setInstanceVariable更快
 */
- (void)setIvarValue
{
    self.name = @"123";
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    //object 包含该变量的对象。 ivar 需要赋值的变量。value 变量新的值。
    object_setIvar(self, ivar, @"LeeWong");
    NSLog(@"%@",self.name);
}

@end
