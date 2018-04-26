## Method

### SEL

```c
typedef struct objc_selector *SEL;

```

#### sel_registerName

`SEL sel_registerName(const char * str)`

作用:在Runtime系统中注册一个方法,将方法名映射到一个选择器并返回这个选择器
参数名: 方法名
返回值: 方法名对应的方法选择器


示例:

```objc
- (void)getSEL
{
    SEL sel = NSSelectorFromString(@"method1");
    NSLog(@"%p",sel);
    
    SEL sel1 = @selector(method1);
    
    NSLog(@"%p",sel1);
    
    SEL sel2 = sel_registerName("method2");

}
```

打印结果:

```objc
2018-04-26 18:25:53.823001+0800 Runtime_MsgSend[19586:51308708] 0x101a80728
2018-04-26 18:25:53.823113+0800 Runtime_MsgSend[19586:51308708] 0x101a80728

```

#### sel_getName

` const char *sel_getName(SEL sel)`

作用: 获取某一个方法选择器的方法名
参数: 目标方法选择器
返回值: 目标方法选择器的方法名

示例:

```objc
- (void)getSELName
{
    SEL sel = @selector(method);
    NSLog(@"%s",sel_getName(sel));
}
```

打印结果:

```objc
2018-04-26 19:46:16.176856+0800 Runtime_MsgSend[21705:51519793] method
```

具体实现: 这里我们可以看出其实sel就是方法的名称 

```objc
const char *sel_getName(SEL sel) 
{
    if (!sel) return "<null selector>";
    return (const char *)(const void*)sel;
}
```

`注意`:

![sel](http://og0h689k8.bkt.clouddn.com/18-4-26/71781933.jpg)

上图我们可以看出:两个类之间，不管它们是父类与子类的关系，还是之间没有这种关系，只要方法名相同，那么方法的SEL就是一样的.每一个方法都对应着一个SEL。所以在Objective-C同一个类(及类的继承体系)中，不能存在2个同名的方法，即使参数类型不同也不行。相同的方法只能对应一个SEL不同的类可以拥有相同的selector，这个没有问题。不同类的实例对象执行相同的selector时，会在各自的方法列表中去根据selector去寻找自己对应的IMP

工程中的所有的SEL组成一个Set集合，Set的特点就是唯一，因此SEL是唯一的。因此，如果我们想到这个方法集合中查找某个方法时，只需要去找到这个方法对应的SEL就行了，SEL实际上就是根据方法名hash化了的一个字符串，而对于字符串的比较仅仅需要比较他们的地址就可以了，可以说速度上无语伦比！！但是，有一个问题，就是数量增多会增大hash冲突而导致的性能下降（或是没有冲突，因为也可能用的是perfect hash）。但是不管使用什么样的方法加速，如果能够将总量减少（多个方法可能对应同一个SEL），那将是最犀利的方法。那么，我们就不难理解，为什么SEL仅仅是函数名了。

 本质上，SEL只是一个指向方法的指针（准确的说，只是一个根据方法名hash化了的KEY值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度。这个查找过程我们将在下面讨论。

#### sel_getUid

`SEL sel_getUid(const char * str)`

作用:类似于sel_registerName

示例:

```objc
- (void)getUID
{
    SEL sel = sel_getUid("method");
    [self performSelector:sel withObject:nil afterDelay:0];
}
```

打印结果:

```c
2018-04-26 19:57:10.690108+0800 Runtime_MsgSend[22124:51562036] -[Runtime_SEL method]
```

#### sel_isEqual

`BOOL sel_isEqual(SEL lhs, SEL rhs) `

作用: 判断两个SEL是否相等
参数: 要比较的两个SEL
返回值: 是否相等

示例:

```objc
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
```

打印结果:

```c
2018-04-26 19:55:14.356815+0800 Runtime_MsgSend[22029:51553898] 两个方法的sel不相等
2018-04-26 19:55:14.356949+0800 Runtime_MsgSend[22029:51553898] 不同对象的同一个方法是相等的
2018-04-26 19:55:14.357046+0800 Runtime_MsgSend[22029:51553898] 不同对象的同一个方法是相等的
```

### IMP

`id (*IMP)(id, SEL, ...)`

第一个参数是指向self的指针(如果是实例方法，则是类实例的内存地址；如果是类方法，则是指向元类的指针)，

第二个参数是方法选择器(selector)，接下来是方法的实际参数列表。

SEL就是为了查找方法的最终实现IMP的。由于每个方法对应唯一的SEL，因此我们可以通过SEL方便快速准确地获得它所对应的IMP，
 
查找过程将在下面讨论。取得IMP后，我们就获得了执行这个方法代码的入口点，此时，我们就可以像调用普通的C语言函数一样来使用这个函数指针了。


### Method



