//
//  ClassMRC.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ObjcCreate_MRC.h"
#import <objc/runtime.h>
#import "Father.h"

@implementation ObjcCreate_MRC


/**
在指定的位置(bytes)创建类实例。
 */
- (id)createInstance
{
    size_t objSize = class_getInstanceSize([Father class]);
    size_t allocSize = 2 * objSize;
    uintptr_t ptr = (uintptr_t)calloc(allocSize, 1);
    id obj = objc_constructInstance([Father class], &ptr);
    NSLog(@"%@",[obj class]);
    return obj;
}


/**
 销毁一个类的实例，但不会释放并移除任何与其相关的引用。
 */
- (void)class_destoryInstance
{
    Father *tempPerson = [[Father alloc] init];
    tempPerson.name = @"Lee";
    // 释放后 无法取得name的值
    NSLog(@"before 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    objc_destructInstance(tempPerson);
    NSLog(@"after 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    
    //上面的destructInstance 并没有将对象也给释放
    [tempPerson release];
}


/**
 假设我们有类A和类B，且类B是类A的子类。类B通过添加一些额外的属性来扩展类A。
 现在我们创建了一个A类的实例对象，并希望在运行时将这个对象转换为B类的实例对象，
 这样可以添加数据到B类的属性中。这种情况下，我们没有办法直接转换，
 因为B类的实例会比A类的实例更大，没有足够的空间来放置对象。此时，我们就要以使用以上几个函数来处理这种情况
 */
- (void)copyAtoBWithClass
{
    NSObject *a = [[NSObject alloc] init];
    //返回指定对象的一份拷贝
    id newB = object_copy(a, class_getInstanceSize(Father.class));
    
    object_setClass(newB, Father.class);
    NSLog(@"%@",newB);
    // 释放指定对象占用的内存
    object_dispose(a);
}

@end
