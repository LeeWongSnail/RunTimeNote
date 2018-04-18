//
//  Objc_ClassList.m
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Objc_ClassList.h"
#import <objc/runtime.h>

@implementation Objc_ClassList

/**
 函数是为了获取到当前注册的所有类的总个数
 第一个参数 buffer ：已分配好内存空间的数组
 第二个参数 bufferCount ：数组中可存放元素的个数，返回值是注册的类的总数
 当参数 bufferCount 值小于注册的类的总数时，获取到的是注册类的集合的任意子集
 第一个参数传 NULL 时将会获取到当前注册的所有的类，此时可存放元素的个数为0，因此第二个参数可传0，返回值为当前注册的所有类的总数。
 */
- (void)getClassList
{
    int outCount = 0;
    int newNumClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    while (outCount < newNumClasses) {
        outCount = newNumClasses;
        classes = (Class *)realloc(classes, sizeof(Class) * outCount);
        newNumClasses = objc_getClassList(classes, outCount);
        
        for (int i = 0; i < outCount; i++) {
            const char *className = class_getName(classes[i]);
            NSLog(@"%s", className);
        }
        
    }
    free(classes);

}


/**
 该函数的作用是获取所有已注册的类，和上述函数 objc_getClassList 参数传入 NULL 和  0 时效果一样，代码相对简单
 */
- (void)copyClassList
{
    unsigned int outCount = 0;
    Class *clss =objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"%s",class_getName(clss[i]));
    }
}


/**
 返回指定类的类定义
 */
- (void)getSpecificClass
{
    //而objc_lookUpClass获取指定的类，如果没有注册则返回nil
    Class cls = objc_lookUpClass("Father");
    NSLog(@"%s",class_getName(cls));
    //而objc_getClass会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil
    cls = objc_getClass("Son");
    NSLog(@"%s",class_getName(cls));
    
    //如果获取的类不存在会崩溃
    cls = objc_getRequiredClass("Son");
    NSLog(@"%s",class_getName(cls));
}


/**
 如果指定的类没有注册，则该函数会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil。
 不过，每个类定义都必须有一个有效的元类定义，所以这个函数总是会返回一个元类定义，不管它是否有效。
 */
- (void)getMetaClass
{
    Class cls = objc_getMetaClass("Son");
    NSLog(@"%s",class_getName(cls));

}

@end
