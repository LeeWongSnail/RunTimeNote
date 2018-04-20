//
//  ForwardInvocation.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ForwardInvocation.h"
#import <objc/runtime.h>

@interface ForwardInvocation()
@property (nonatomic, strong) ForwardInvocationBak *target;
@end

@implementation ForwardInvocation

- (instancetype)init
{
    if (self = [super init]) {
        self.target = [[ForwardInvocationBak alloc] init];
    }
    return self;
}


/**
 消息转发机制使用从这个方法中获取的信息来创建NSInvocation对象。因此我们必须重写这个方法，为给定的selector提供一个合适的方法签名

 @param aSelector <#aSelector description#>
 @return <#return value description#>
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([ForwardInvocationBak instancesRespondToSelector:aSelector]) {
            signature = [ForwardInvocationBak instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

//跟对象方法对应的类方法
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([ForwardInvocationBak respondsToSelector:aSelector]) {
            signature = [ForwardInvocationBak methodSignatureForSelector:aSelector];
        }
    }
    return signature;
}


/**
 对象会创建一个表示消息的NSInvocation对象，把与尚未处理的消息有关的全部细节都封装在anInvocation中，包括selector，目标(target)和参数。我们可以在forwardInvocation方法中选择将消息转发给其它对象
 
 定位可以响应封装在anInvocation中的消息的对象。这个对象不需要能处理所有未知消息。
 使用anInvocation作为参数，将消息发送到选中的对象。anInvocation将会保留调用结果，运行时系统会提取这一结果并将其发送到消息的原始发送者。

 @param anInvocation 被调用方法的全部信息
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selName = NSStringFromSelector(anInvocation.selector);
    if ([selName isEqualToString:@"noIMPInstanceMethod"]) {
        [anInvocation invokeWithTarget:self.target];
    }
    
}

//跟对象方法对应的类方法
+ (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selName = NSStringFromSelector(anInvocation.selector);
    if ([selName isEqualToString:@"noIMPClassMethod"]) {
        [anInvocation invokeWithTarget:[ForwardInvocationBak class]];
    }
    
}

@end



@implementation ForwardInvocationBak

- (void)noIMPInstanceMethod
{
    NSLog(@"%s",__func__);
}

+ (void)noIMPClassMethod
{
    NSLog(@"%s",__func__);
}



@end
