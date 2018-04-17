//
//  ClassMethod.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassMethod.h"
#import <objc/runtime.h>
#import "Son.h"
@implementation ClassMethod


/**
 获取一个类指定的 对象方法
 注意: 如果这个方法只是声明但是并没有具体的实现 那么这里拿到的method将会是null
  这个函数都会去搜索父类的实现
 */
- (void)getInstanceMethod
{
  Method method = class_getInstanceMethod([self class], @selector(method1));
    if (method != NULL) {
        NSLog(@"method %s", method_getName(method));
        
    }
}


/**
 获取类的类方法
 同样如果只是声明并未实现这个方法 那么这里获取的Method为null
 这个函数都会去搜索父类的实现
 */
- (void)getClassMethod
{
    Method method = class_getClassMethod([self class], @selector(myClassMethod));
    if (method != NULL) {
        NSLog(@"method %s", method_getName(method));
    }
}

/**
 获取类的方法列表(不包含父类的)
 在获取到列表后，我们需要使用free()方法来释放它。
 */
- (void)getMethodList
{
    unsigned int outCount = 0;
    Method *list = class_copyMethodList([Son class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Method m = list[i];
        if (m != NULL) {
            NSLog(@"method %s", method_getName(m));
        }
    }
    free(list);
}


/**
 替换方法的实现 将method2的实现IMP指向 Method1的实现
 这样在执行method2的时候 相当于执行method1
 如果类中不存在name指定的方法，则类似于class_addMethod函数一样会添加方法；如果类中已存在name指定的方法，则类似于method_setImplementation一样替代原方法的实现。
 */
- (void)replaceMethodImplementation
{
    Method method = class_getInstanceMethod([self class], @selector(method1));
    class_replaceMethod([self class], @selector(method2), method_getImplementation(method), method_getTypeEncoding(method));
    [self method1];
    [self method2];
}


/**
 获取方法的具体实现 可以通过这个方法去交换两个方法的实现
 获取的IMP实际指向一个方法的实现 因为是一个C函数 因此可以直接通过调用imp调用这个方法
 */
- (void)getMethodImplementation
{
    IMP imp = class_getMethodImplementation([self class], @selector(method1));
    imp();
}


/**
 获取方法的实现 功能与class_getMethodImplementation相同只是返回的
 */
- (void)getMethodImplementation_stret
{
    IMP imp = class_getMethodImplementation_stret([self class], @selector(method1));
}

- (void)class_respondsToSelector
{
    if (class_respondsToSelector([self class], @selector(method1))) {
        NSLog(@"method1 has responds");
    } else {
        NSLog(@"method1 has no responds");
    }
}


void TestMetaClass(id self, SEL _cmd) {
    NSLog(@"testMetaClass");
}


/**
 动态的为一个类添加一个方法 这个方法在getMethodList中获取不到 但是可以通过performselector可以执行这个方法
 class_addMethod的实现会覆盖父类的方法实现，但不会取代本类中已存在的实现，如果本类中包含一个同名的实现，则函数会返回NO
 */
- (void)addClassMethod
{
    [self getMethodList];
    BOOL suc = class_addMethod([self class], @selector(TestMetaClass), (IMP)TestMetaClass, "v@:");
    if (suc) {
        NSLog(@"add success");
        NSLog(@"---------after add method-------------");
        [self getMethodList];
        //如果添加成功会调用这个方法
        [self performSelector:@selector(TestMetaClass)];
    } else {
        NSLog(@"add failed");
    }

    
}



- (void)method1
{
    NSLog(@"%s",__func__);
}

- (void)method2
{
    NSLog(@"%s",__func__);
}

+ (void)myClassMethod
{
    NSLog(@"%s",__func__);
}

@end
