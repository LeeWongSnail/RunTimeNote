## 方法调用

我们都知道在OC中方法的调用最终都会转为消息发送(msg_send)的形式,那么在这个过程中到底都做了哪些操作呢？ 这篇文章我们主要研究一下这个问题！

### 消息发送的方法

首先我们来看一下msg_send相关的方法：

#### objc_msgSend

`id _Nullable objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)`

作用: 对象调用一个方法
参数: 一个类的实例用于接受消息,要调用的方法,方法的参数
返回值: 一个方法调用的返回值

先看一下官方的备注:

```
 * @note When it encounters a method call, the compiler generates a call to one of the
 *  functions \c objc_msgSend, \c objc_msgSend_stret, \c objc_msgSendSuper, or \c objc_msgSendSuper_stret.
 *  Messages sent to an object’s superclass (using the \c super keyword) are sent using \c objc_msgSendSuper; 
 *  other messages are sent using \c objc_msgSend. Methods that have data structures as return values
 *  are sent using \c objc_msgSendSuper_stret and \c objc_msgSend_stret.
```

当一个方法被调用,编译器会调用 `objc_msgSend`,`objc_msgSend_stret`,`objc_msgSendSuper`,`objc_msgSendSuper_stret` 这几个方法中的一个,当调用对象是super关键字的时候 会调用 `objc_msgSendSuper`这个方法，其他的消息放松使用`objc_msgSend`.如果方法有返回值那么使用`objc_msgSendSuper_stret`,和 `objc_msgSend_stret`


### objc_msgSendSuper

`void objc_msgSendSuper(void /* struct objc_super *super, SEL op, ... */ )`

作用: 给父类的实例发送一个消息(调用父类的某个方法)
参数: struct objc_super类型的父类,调用的方法,方法的参数
返回值: void

下面来看一下这个`objc_super`的结构

```c
struct objc_super {
    /// Specifies an instance of a class.
    __unsafe_unretained _Nonnull id receiver;

    /// Specifies the particular superclass of the instance to message. 
#if !defined(__cplusplus)  &&  !__OBJC2__
    /* For compatibility with old objc-runtime.h header */
    __unsafe_unretained _Nonnull Class class;
#else
    __unsafe_unretained _Nonnull Class super_class;
#endif
    /* super_class is the first class to search */
};
#endif
```

### 使用

下面我们来看一下相关的小例子：

请问下面这段代码,输出的是什么？

```objc
// Class MsgSendSuper.m
- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}
```

--------------------------------分割线 自己想想----------------------------------

打印结果:

```c
2018-04-27 17:37:30.101186+0800 Runtime_Other[39278:53237633] MsgSendSuper
2018-04-27 17:37:30.101326+0800 Runtime_Other[39278:53237633] MsgSendSuper
```

输出是相同的 WTF!!!

相信大家对`[self class]`打印出的结果没啥怀疑 关键是`super` 为什么是这个结果。

对于`[super class]`,根据上面的介绍

`当调用对象是super关键字的时候 会调用 objc_msgSendSuper这个方法`

那么 在调用的过程中实际上是调用`objc_msgSendSuper(id,sel,argus)` 这个方法。

对于这个方法 后面的两个参数 我们都很清楚,那么我们重点观察第一个参数: `objc_super`

上面介绍了这个结构体主要包含 `receiver` 和 `super_class` 这两个参数：

* receiver：即消息的实际接收者
* superClass：指针当前类的父类

那么我们在调用的时候 这两个值是什么呢？

* receiver: 消息的接受者,很明显 self在做这个操作那么 这个消息的接受者是self
* superClass: 当前类的父类(要去调用谁的方法)

分析清楚了这两个参数的值,我们清楚了objc_msgSendSuper方法的意义：

`直接调用superClass中的方法 并将调用的结果返回给receiver`

而且 翻译之后的`objc_mgSendSuper` 就相当于:

`objc_msgSend(objc_super->receiver, @selector(init))`

这样看就很清晰了。

另外 我们还可以做一个验证 模拟一下super的调用：

```objc
- (void)someInstanceMethod
{
    struct objc_super superclass = {
        .receiver    = self,    //方法的接受者 这个表明 调用这个方法最终的接受者 还是当前类
        .super_class = class_getSuperclass(object_getClass(self))
    };
    //从objc_super结构体指向的superClass的方法列表开始查找viewDidLoad的selector，找到后以objc->receiver去调用这个selector，
    objc_msgSendSuper(&superclass, @selector(someInstanceMethod));
    NSLog(@"%s",__func__);
}
```

`注意`:这段代码运行需要将Enable Strict Checking of objc_msgSend Calls改为NO

其实我们就直接自己创建了一个objc_super 然后设置了这个结构体里的内容 然后利用这个结构体去调用对应的方法,结果跟上面所说的一样,也进一步验证了上面的说法。


鉴于objc_msgSend 内部就直接调用汇编的方法了,因此我们不在深入的去讨论这个方法了！

## 消息发送流程

当我们调用某个对象方法或者类方法的时候,编译器是怎么找到这个方法并顺利调用或者报错呢？



