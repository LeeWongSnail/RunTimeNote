//
//  Runtime_SEL.m
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Runtime_SEL.h"
#import <objc/runtime.h>
#import "SomeClass.h"
#import "Father.h"
#import "Son.h"

/*
方法的selector用于表示运行时方法的名字。Objective-C在编译时，会依据每一个方法的名字、参数序列，
 生成一个唯一的整型标识(Int类型的地址)，这个标识就是SEL
*/

@implementation Runtime_SEL

- (void)method1
{
    NSLog(@"%s",__func__);
}

- (void)getSEL
{
    SEL sel = NSSelectorFromString(@"method1");
    NSLog(@"%p",sel);
    
    SEL sel1 = @selector(method1);
    
    NSLog(@"%p",sel1);
    
    SEL sel2 = sel_registerName("method2");

}


/*
这两个方法编译器默认会提示方法重复
两个类之间，不管它们是父类与子类的关系，还是之间没有这种关系，只要方法名相同，那么方法的SEL就是一样的。
每一个方法都对应着一个SEL。所以在Objective-C同一个类(及类的继承体系)中，不能存在2个同名的方法，即使参数类型不同也不行。
相同的方法只能对应一个SEL
不同的类可以拥有相同的selector，这个没有问题。不同类的实例对象执行相同的selector时，会在各自的方法列表中去根据selector去寻找自己对应的IMP
*/

//- (void)setWidth:(int)width{}
//- (void)setWidth:(double)width{}

/*
 工程中的所有的SEL组成一个Set集合，Set的特点就是唯一，因此SEL是唯一的。因此，如果我们想到这个方法集合中查找某个方法时，只需要去找到这个方法对应的SEL就行了，SEL实际上就是根据方法名hash化了的一个字符串，而对于字符串的比较仅仅需要比较他们的地址就可以了，可以说速度上无语伦比！！但是，有一个问题，就是数量增多会增大hash冲突而导致的性能下降（或是没有冲突，因为也可能用的是perfect hash）。但是不管使用什么样的方法加速，如果能够将总量减少（多个方法可能对应同一个SEL），那将是最犀利的方法。那么，我们就不难理解，为什么SEL仅仅是函数名了。
 
 本质上，SEL只是一个指向方法的指针（准确的说，只是一个根据方法名hash化了的KEY值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度。这个查找过程我们将在下面讨论。
 **/

- (void)getSELName
{
    SEL sel = @selector(method);
    NSLog(@"%s",sel_getName(sel));
}



/**
比较两个选择器
 实际证明 只要两个方法的名字相同
 */
- (void)compareSEL
{
    SEL sel = NSSelectorFromString(@"method");
    SEL sel1 = NSSelectorFromString(@"method1");
    if (sel_isEqual(sel, sel1)) {
        NSLog(@"两个方法的sel相等");
    } else {
        NSLog(@"两个方法的sel不相等");
    }
    
    Method method1 = class_getInstanceMethod([Father class], @selector(eat));
    Method method2 = class_getInstanceMethod([Son class], @selector(eat));
    
    if (sel_isEqual(method_getName(method1), method_getName(method2))) {
        NSLog(@"不同对象的同一个方法是相等的");
    } else {
        NSLog(@"不同对象的同一个方法是不相等的");
    }

    Method method3 = class_getInstanceMethod([Father class], @selector(eat));
    Method method4 = class_getInstanceMethod([SomeClass class], @selector(eat));
    
    if (sel_isEqual(method_getName(method3), method_getName(method4))) {
        NSLog(@"不同对象的同一个方法是相等的");
    } else {
        NSLog(@"不同对象的同一个方法是不相等的");
    }
    
}




- (void)method {
    NSLog(@"%s",__func__);
}


@end

@implementation OtherSEL
- (void)method {
    NSLog(@"%s",__func__);
}

- (void)method1 {
    NSLog(@"%s",__func__);
}
@end
