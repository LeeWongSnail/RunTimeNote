//
//  Runtime_IMP.m
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

/*
 id (*IMP)(id, SEL, ...)
第一个参数是指向self的指针(如果是实例方法，则是类实例的内存地址；如果是类方法，则是指向元类的指针)，
第二个参数是方法选择器(selector)，接下来是方法的实际参数列表。
 
 SEL就是为了查找方法的最终实现IMP的。由于每个方法对应唯一的SEL，因此我们可以通过SEL方便快速准确地获得它所对应的IMP，
 查找过程将在下面讨论。取得IMP后，我们就获得了执行这个方法代码的入口点，
 此时，我们就可以像调用普通的C语言函数一样来使用这个函数指针了。
 **/


#import "Runtime_IMP.h"

@implementation Runtime_IMP

@end
