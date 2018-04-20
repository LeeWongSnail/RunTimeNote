//
//  Runtime_Method.m
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

/*
 typedef struct objc_method *Method;
 struct objc_method {
 SEL method_name                    OBJC2_UNAVAILABLE;    // 方法名
 char *method_types                    OBJC2_UNAVAILABLE;
 IMP method_imp                         OBJC2_UNAVAILABLE;    // 方法实现
 }
 
 实际上相当于在SEL和IMP之间作了一个映射。有了SEL，我们便可以找到对应的IMP，从而调用方法的实现代码
 **/


#import "Runtime_Method.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation Runtime_Method


/**
 调用指定方法的实现
 返回的是实际实现的返回值。参数receiver不能为空。这个方法的效率会比method_getImplementation和method_getName更快
 
 Xcode中使用method_invoke或者objc_msgSend()报错Too many arguments to function call ,expected 0,have3
 在工程-Build Settings  中将Enable Strict Checking of objc_msgSend Calls 设置为NO即可

 */
//- (void)invoke_test
//{
//    Method md = class_getInstanceMethod([self class], @selector(methodTest));
//    if (md) {
//        method_invoke(self, md);
//    }
//}


/**
 以为SEL 对一个类来说是唯一的 因此 我们可以直接通过判断SEL的地址来判断不同的SEL
 如果想获取方法名的C字符串，可以使用sel_getName(method_getName(method))。
 */
- (void)getMethodName
{
    Method md = class_getInstanceMethod([self class], @selector(methodTest));
    SEL mdName = method_getName(md);
    NSLog(@"%p--%s",mdName,sel_getName(mdName));
}


/**
 获取方法的实现
 */
- (void)getMethodIMP
{
    Method md = class_getInstanceMethod([self class], @selector(methodTest));
    IMP imp = method_getImplementation(md);
    //可以直接向执行C语言一样执行
//    imp();
}


/**
 获取描述方法参数和返回值类型的字符串
 */
- (void)getTypeEncoding
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    NSLog(@"%s",method_getTypeEncoding(md));
}


/**
 获取方法的返回值类型的字符串
 */
- (void)copyReturnType
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    NSLog(@"%s",method_copyReturnType(md));
}


/**
 获取方法的指定位置参数的类型字符串
 */
- (void)copyArguType
{
//    返回方法的参数的个数
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    unsigned int outCount = method_getNumberOfArguments(md);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"%s",method_copyArgumentType(md, i));
    }
}


/**
 通过引用返回方法的返回值类型字符串
 */
- (void)getReturnType
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    char str ;
    method_getReturnType(md, &str, sizeof(char));
    NSLog(@"%c",str);
}


/**
 设置方法的实现
 */
- (void)setIMP
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    //实现一个IMP
    IMP imp = imp_implementationWithBlock(^(){
        NSLog(@" this is a block");
    });
    
    //设置一个method对应的IMP
    method_setImplementation(md, imp);
    
    [self complexMethod:nil location:nil age:0];
}


/**
 交换两个方法的实现
 如果两个方法的参数不一致 那么会报错
 */
- (void)exchangeMethod
{
    Method md = class_getInstanceMethod([self class], @selector(method2));
    Method md1 = class_getInstanceMethod([self class], @selector(methodTest));

    method_exchangeImplementations(md, md1);
    
    [self methodTest];
}


- (void)methodTest
{
    NSLog(@"%s",__func__);
}

- (void)method2
{NSLog(@"%s",__func__);}

- (void)complexMethod:(NSString *)aStr location:(NSDictionary *)aDict age:(NSInteger)age
{
    NSLog(@"%s",__func__);
}
@end
