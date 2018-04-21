//
//  MsgSendSuper.m
//  Runtime_Other
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "MsgSendSuper.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation MsgSendSuper


/**
objc中super是编译器标示符，并不像self一样是一个对象，遇到向super发的方法时会转译成objc_msgSendSuper(...)，
 而参数中的对象还是self，于是从父类开始沿继承链寻找- class这个方法，最后在NSObject中找到（若无override），
 此时，[self class]和[super class]已经等价了

 @return 对象本身
 */
- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}


/**
 模拟 [super someInstanceMethod]的调用过程
 如果要看这个方法的运行过程 请在buildsetting中
 将Enable Strict Checking of objc_msgSend Calls改为NO
 */
//- (void)someInstanceMethod
//{
//    struct objc_super superclass = {
//        .receiver    = self,    //方法的接受者 这个表明 调用这个方法最终的接受者 还是当前类
//        .super_class = class_getSuperclass(object_getClass(self))
//    };
//    //从objc_super结构体指向的superClass的方法列表开始查找viewDidLoad的selector，找到后以objc->receiver去调用这个selector，
//    objc_msgSendSuper(&superclass, @selector(someInstanceMethod));
//    NSLog(@"%s",__func__);
//}

+ (void)someClassMethod
{
    [super someClassMethod];
    NSLog(@"%s",__func__);
}

@end
