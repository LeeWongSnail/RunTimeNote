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

先看一下Method的结构:

```objc
struct objc_method {
    SEL _Nonnull method_name    OBJC2_UNAVAILABLE;
    char * _Nullable method_types   OBJC2_UNAVAILABLE;
    IMP _Nonnull method_imp         OBJC2_UNAVAILABLE;
}  
```

实际上相当于在SEL和IMP之间作了一个映射。有了SEL，我们便可以找到对应的IMP，从而调用方法的实现代码.

#### method_invoke

`id method_invoke(void /* id receiver, Method m, ... */ ) `

作用: 调用指定方法的实现
参数: 方法调用消息的接收者(参数receiver不能为空),Method调用的方法
返回值: 返回的是实际实现的返回值。

`这个方法的效率会比method_getImplementation和method_getName更快`

示例:

```objc
- (void)invoke_test
{
    Method md = class_getInstanceMethod([self class], @selector(methodTest));
    if (md) {
        method_invoke(self, md);
    }
}
```

打印结果:

```c
2018-04-27 10:23:52.498539+0800 Runtime_MsgSend[27737:52143275] -[Runtime_Method methodTest]
```

`注意`:Xcode中使用method_invoke或者objc_msgSend()报错Too many arguments to function call ,expected 0,have3 在工程-Build Settings  中将Enable Strict Checking of objc_msgSend Calls 设置为NO即可

#### method_invoke_stret

`void method_invoke_stret(<#id  _Nullable receiver#>, <#Method  _Nonnull m, ...#>)`

基本上与method_invoke作用相同,用法也相同。返回值为void

#### method_getName

`SEL method_getName(Method m) `

作用: 获取一个方法的名称SEL
参数: 目标Method(`不可以为nil`)
返回值: 方法的名称

示例:

```objc
- (void)getMethodName
{
    Method md = class_getInstanceMethod([self class], @selector(methodTest));
    SEL mdName = method_getName(md);
    NSLog(@"%p--%s",mdName,sel_getName(mdName));
    
}
```

打印结果:

```objc
2018-04-27 10:28:17.581638+0800 Runtime_MsgSend[27907:52160556] 0x10f1d61d1--methodTest
```


PS：来看一下具体实现,在一个类中SEL是可以唯一确定一个方法的因此我们可以直接根据方法的名字判断是否是要查找的那个然后返回.
如果想获取方法名的C字符串，可以使用`sel_getName(method_getName(method))`。

```objc
SEL method_getName(Method m)
{
    if (!m) return nil;

    assert(m->name == sel_registerName(sel_getName(m->name)));
    return m->name;
}
```

#### method_getImplementation

`IMP _Nonnull method_getImplementation(Method _Nonnull m) `

作用: 获取方法的实现IMP
参数: 目标的Method对象 
返回值: 方法的具体实现的地址入口

示例:

```objc
- (void)getMethodIMP
{
    Method md = class_getInstanceMethod([self class], @selector(methodTest));
    IMP imp = method_getImplementation(md);
    //可以直接向执行C语言一样执行
    if (imp) {
        imp();
    }
}

```

打印结果:

```c
2018-04-27 10:38:50.207840+0800 Runtime_MsgSend[28323:52200145] -[Runtime_Method methodTest]
```

`注意`: 要`imp()`可以直接运行`Enable Strict Checking of objc_msgSend Calls`,需要设置成YES。

PS: 其实就是直接取属性。

```objc
IMP method_getImplementation(Method m)
{
    return m ? m->imp : nil;
}
```

#### method_getTypeEncoding

`const char * _Nullable method_getTypeEncoding(Method _Nonnull m) `

作用: 获取一个方法的类型编码(`参数+返回值`)
参数: 目标方法
返回值: 目标方法的类型编码的字符串

示例:

```objc
- (void)getTypeEncoding
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    NSLog(@"%s",method_getTypeEncoding(md));
}
```

打印结果:

```objc
2018-04-27 10:56:52.416998+0800 Runtime_MsgSend[29072:52266578] v40@0:8@16@24q32
```

`注意`:具体关于类型编码每一部分对应的意义,可以查阅官方文档,网上也有很多总结.可以用到时 随时查阅。

#### method_getReturnType

`void method_getReturnType(Method _Nonnull m, char * _Nonnull dst, size_t dst_len)`

作用: 通过引用返回方法的返回值类型字符串
参数: 目标方法 返回类型的字符串 dst可以存放的最大字节数

示例：

```objc
- (void)getReturnType
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    char str ;
    method_getReturnType(md, &str, sizeof(char));
    NSLog(@"%c",str);
}
```

打印结果:

```c
2018-04-27 11:08:32.097028+0800 Runtime_MsgSend[29572:52311764] v
```


#### method_copyReturnType

`char * _Nonnull method_copyReturnType(Method _Nonnull m)`

作用: 获取目标方法的返回类型
参数: 目标方法
返回值: 目标方法的返回类型的字符串

示例:

```objc
- (void)copyReturnType
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    NSLog(@"%s",method_copyReturnType(md));
}
```

打印结果:

```objc
2018-04-27 10:59:46.281572+0800 Runtime_MsgSend[29195:52277343] v
```

`v--void`

#### method_getNumberOfArguments

` unsigned int method_getNumberOfArguments(Method _Nonnull m)`

作用: 获取目标方法的参数个数
参数: 目标方法
返回值: 目标方法的参数个数

示例:
跟`method_copyArgumentType`放一起。

#### method_getArgumentType

`void method_getArgumentType(Method _Nonnull m, unsigned int index, 
                       char * _Nullable dst, size_t dst_len) `
                       
作用: 获取目标方法 在某个位置的某个参数类型
参数: 目标方法 要获取参数的位置 引用字符串用于存储获取的值,dst能存放的最大字符数

示例:

```objc
- (void)getArguemtnType
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    char str[10] ;
    unsigned int outCount = method_getNumberOfArguments(md);
    method_getArgumentType(md, outCount-1, str, 10);
    NSLog(@"%s",str);
}
```

打印结果:

```c
2018-04-27 11:25:45.474497+0800 Runtime_MsgSend[30379:52378402] q
```

#### method_copyArgumentType

`char * _Nullable method_copyArgumentType(Method _Nonnull m, unsigned int index) `

作用: 获取方法的指定位置参数的类型字符串
参数: Method目标方法,index 获取哪个位置的参数
返回值: 对应位置参数的字符串

示例:

```objc
- (void)copyArguType
{
//    返回方法的参数的个数
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    unsigned int outCount = method_getNumberOfArguments(md);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"%s",method_copyArgumentType(md, i));
    }
}
```

打印结果:

```objc
2018-04-27 11:04:30.992715+0800 Runtime_MsgSend[29402:52296009] @
2018-04-27 11:04:30.992858+0800 Runtime_MsgSend[29402:52296009] :
2018-04-27 11:04:30.992970+0800 Runtime_MsgSend[29402:52296009] @
2018-04-27 11:04:30.993080+0800 Runtime_MsgSend[29402:52296009] @
2018-04-27 11:04:30.993197+0800 Runtime_MsgSend[29402:52296009] q
```

#### method_getDescription

`struct objc_method_description * _Nonnull method_getDescription(Method _Nonnull m) `

作用: 获取一个方法的描述(包含方法名和类型编码)
参数: 目标方法
返回值:` objc_method_description`结构体包含 `name`和`types`

示例:

```objc
- (void)getMethodDescription
{
    Method md = class_getInstanceMethod([self class], @selector(complexMethod:location:age:));
    struct objc_method_description *desc = method_getDescription(md);
    NSLog(@"name:%s--- types:%s",sel_getName(desc->name),desc->types);
}
```

打印结果:

```c
2018-04-27 11:29:28.232234+0800 Runtime_MsgSend[30553:52392586] name:complexMethod:location:age:--- types:v40@0:8@16@24q32
```

#### method_setImplementation

`IMP _Nonnull method_setImplementation(Method _Nonnull m, IMP _Nonnull imp) `

作用: 设置某个方法的实现
参数: 目标方法 以及目标方法新的实现的母口
返回值: 新的目标方法

示例:

```objc
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
```

打印结果：

```c
2018-04-27 11:34:46.089701+0800 Runtime_MsgSend[30767:52412988]  this is a block
```

PS:我们来看一下内部实现，其实就是讲 method的imp做了修改 就实现了方法的`重写`(新的实现)

```objc
static IMP 
_method_setImplementation(Class cls, method_t *m, IMP imp)
{
    runtimeLock.assertWriting();

    if (!m) return nil;
    if (!imp) return nil;

    IMP old = m->imp;
    m->imp = imp;

    // Cache updates are slow if cls is nil (i.e. unknown)
    // RR/AWZ updates are slow if cls is nil (i.e. unknown)
    // fixme build list of classes whose Methods are known externally?

    flushCaches(cls);

    updateCustomRR_AWZ(cls, m);

    return old;
}
```

#### method_exchangeImplementations

`void method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2) `

作用: 交换两个方法的实现
参数: 需要被交换的两个方法
返回值: void

示例:

```objc
- (void)exchangeMethod
{
    Method md = class_getInstanceMethod([self class], @selector(method2));
    Method md1 = class_getInstanceMethod([self class], @selector(methodTest));

    method_exchangeImplementations(md, md1);
    
    [self methodTest];
}
```

打印结果:

```c
2018-04-27 11:38:06.796713+0800 Runtime_MsgSend[30911:52425851] -[Runtime_Method method2]
```

`注意`: 如果两个方法的参数不一致 那么会报错。

根据上面重设方法实现,我们可以看出这个方法交换实际也是讲Method的IMP交换了一下。


