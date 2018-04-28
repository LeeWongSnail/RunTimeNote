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

### 调用存在的方法--类本身实现的方法

 `[prop performSelector:@selector(protocolEqual)];`
 
 一直prop对象是已经实现了protocolEqual方法的,因此 我们通过这个调用来看一下 方法的调用都经过了哪些过程！
 
因为我们使用`performSelector`的是的方式调用的 因此第一步肯定是直接调用这个方法

```objc
- (id)performSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL))objc_msgSend)(self, sel);
}
``` 

如果你传入的sel为空,那么会直接调用`doesNotRecognizeSelector`找不到方法,如果不为空会调用objc_msgSend进入消息发送的环节。

接下来,通过objc_msgSend直接就找到了,我们实现的方法

```objc
- (void)protocolEqual
{
    if (protocol_isEqual(@protocol(Protocol2), @protocol(Protocol1))) {
        NSLog(@"协议相等");
    }
}
```
### 调用存在的方法--父类实现的方法 

```objc
[prop performSelector:@selector(class)];
```

额！
直接调用父类的方法

```objc
- (Class)class {
    return object_getClass(self);
}
```

看不到内部的调用呀,先接着看下面的！

### 调用不存在的方法

```objc
RuntimeTest *test = [[RuntimeTest alloc] init];
[test noIMPMethod];
```

我们紧跟这个操作

```objc
IMP _class_lookupMethodAndLoadCache3(id obj, SEL sel, Class cls)
{
    return lookUpImpOrForward(cls, sel, obj, 
                              YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
}
```

这个方法的参数为

```objc
Printing description of obj:
(RuntimeTest *) obj = 0x0000000104b21730
objc[56720]: rwlock incorrectly not unlocked
Printing description of sel:
(SEL) sel = "noIMPMethod"
Printing description of cls:
(Class) cls = RuntimeTest
```

看一下这个方法的解释

```c
* _class_lookupMethodAndLoadCache.
* Method lookup for dispatchers ONLY. OTHER CODE SHOULD USE lookUpImp().
* This lookup avoids optimistic cache scan because the dispatcher 
* already tried that.
```

`这种查找避免了乐观的缓存扫描，因为调度程序已经尝试过。`

接下来 再看看这个方法`lookUpImpOrForward`:

```objc
/***********************************************************************
* lookUpImpOrForward.
* The standard IMP lookup. 
* initialize==NO tries to avoid +initialize (but sometimes fails)
* cache==NO skips optimistic unlocked lookup (but uses cache elsewhere)
* Most callers should use initialize==YES and cache==YES.
* inst is an instance of cls or a subclass thereof, or nil if none is known. 
*   If cls is an un-initialized metaclass then a non-nil inst is faster.
* May return _objc_msgForward_impcache. IMPs destined for external use 
*   must be converted to _objc_msgForward or _objc_msgForward_stret.
*   If you don't want forwarding at all, use lookUpImpOrNil() instead.
**********************************************************************/
IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                       bool initialize, bool cache, bool resolver)
{
    IMP imp = nil;
    bool triedResolver = NO;

    runtimeLock.assertUnlocked();

    // Optimistic cache lookup 先在缓存里查找,当然需要你传入是否需要(一般是NO)
    if (cache) {
        imp = cache_getImp(cls, sel);
        if (imp) return imp;
    }

    // runtimeLock is held during isRealized and isInitialized checking
    // to prevent races against concurrent realization.

    // runtimeLock is held during method search to make
    // method-lookup + cache-fill atomic with respect to method addition.
    // Otherwise, a category could be added but ignored indefinitely because
    // the cache was re-filled with the old value after the cache flush on
    // behalf of the category.

    runtimeLock.read();

    //类是否被实现
    if (!cls->isRealized()) {
        // Drop the read-lock and acquire the write-lock.
        // realizeClass() checks isRealized() again to prevent
        // a race while the lock is down.
        runtimeLock.unlockRead();
        runtimeLock.write(); 
        // 执行cls类的第一次初始化包含分配读写数据返回一个类的结构示例
        realizeClass(cls);

        runtimeLock.unlockWrite();
        runtimeLock.read();
    }

    // * class_initialize.  Send the '+initialize' message on demand to any
    // * uninitialized class. Force initialization of superclasses first.
    if (initialize  &&  !cls->isInitialized()) {
        runtimeLock.unlockRead();
        _class_initialize (_class_getNonMetaClass(cls, inst));
        runtimeLock.read();
        // If sel == initialize, _class_initialize will send +initialize and 
        // then the messenger will send +initialize again after this 
        // procedure finishes. Of course, if this is not being called 
        // from the messenger then it won't happen. 2778172
    }

//重试
 retry:    
    runtimeLock.assertReading();

    // 尝试从缓存中获取
    imp = cache_getImp(cls, sel);
    // 如果缓存中有 那么直接跳转到完成
    if (imp) goto done;

    // 尝试在类的方法列表中查找
    {
        Method meth = getMethodNoSuper_nolock(cls, sel);
        if (meth) {
            log_and_fill_cache(cls, meth->imp, sel, inst, cls);
            imp = meth->imp;
            goto done;
        }
    }

    // 尝试在父类的的缓存和方法列表中查找
    {
        unsigned attempts = unreasonableClassCount();
        for (Class curClass = cls->superclass;
             curClass != nil;
             curClass = curClass->superclass)
        {
            // 这个地方是为了避免死循环
            if (--attempts == 0) {
                _objc_fatal("Memory corruption in class list.");
            }
            
            // 父类的cache中查找
            imp = cache_getImp(curClass, sel);
            if (imp) {
                if (imp != (IMP)_objc_msgForward_impcache) {
                    // 如果在父类的缓存中找到要把这个方法放到当前类的缓存中
                    log_and_fill_cache(cls, imp, sel, inst, curClass);
                    goto done;
                }
                else {
                    // Found a forward:: entry in a superclass.
                    // Stop searching, but don't cache yet; call method 
                    // resolver for this class first.
                    break;
                }
            }
            
            // 父类的方法列表
            Method meth = getMethodNoSuper_nolock(curClass, sel);
            if (meth) {
               // 如果在父类的方法列表中找到 也要先缓存到当前类的列表中
                log_and_fill_cache(cls, meth->imp, sel, inst, curClass);
                imp = meth->imp;
                goto done;
            }
        }
    }

    // No implementation found. Try method resolver once.
    // 没有发现方法的实现 尝试一次方法的解析(resolver)默认是yes
    if (resolver  &&  !triedResolver) {
        runtimeLock.unlockRead();
        // 终于看到老熟人了
        _class_resolveMethod(cls, sel, inst);
        runtimeLock.read();
        // Don't cache the result; we don't hold the lock so it may have 
        // changed already. Re-do the search from scratch instead.
        //修改为YES保证之查找一次
        triedResolver = YES;
        goto retry;
    }

    // 没有找到方法实现 方法解析也失败 那么开始转发
    imp = (IMP)_objc_msgForward_impcache;
    cache_fill(cls, sel, imp, inst);

 done:
    runtimeLock.unlockRead();

    return imp;
}
```



下面我们来实现以下消息转发的那几个方法看看执行的过程！

首先 我们实现了 消息解析 动态给这个类添加一个方法

```objc
void functionForInstanceMethod(id self,SEL cmd)
{
    NSLog(@"实例方法的替代方法");
}


+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *selectorStr = NSStringFromSelector(sel);
    if ([selectorStr isEqualToString:@"noIMPMethod"]) {
        class_addMethod([self class], @selector(noIMPInstanceMethod), (IMP)functionForInstanceMethod, "@:");
    }
    
    return [super resolveClassMethod:sel];
}
```

在开始方法解析的时候 调用 `_class_resolveMethod` 

```objc
// 根据是否为元类调用+resolveClassMethod或者+resolveInstanceMethod
void _class_resolveMethod(Class cls, SEL sel, id inst)
{
    if (! cls->isMetaClass()) {
        _class_resolveInstanceMethod(cls, sel, inst);
    } 
    else {
        // try [nonMetaClass resolveClassMethod:sel]
        // and [cls resolveInstanceMethod:sel]
        //如果是元类 
        _class_resolveClassMethod(cls, sel, inst);
        //这算是递归调用吧外面的方法吧 不过注意 参数initialize和resolver变为了NO
        if (!lookUpImpOrNil(cls, sel, inst, 
                            NO/*initialize*/, YES/*cache*/, NO/*resolver*/)) 
        {
            _class_resolveInstanceMethod(cls, sel, inst);
        }
    }
}

```

在执行到这个方法的时候 我们的参数是:

```objc
Printing description of cls:
RuntimeTest
Printing description of sel:
(SEL) sel = "noIMPMethod"
Printing description of inst:
<RuntimeTest: 0x104b21730>
```

因为我们这里是实例方法,那么我们进一步看看`_class_resolveInstanceMethod`这个方法的实现:

```objc
static void _class_resolveInstanceMethod(Class cls, SEL sel, id inst)
{
    //先去找这个类的的元类是否实现了这个方法
    if (! lookUpImpOrNil(cls->ISA(), SEL_resolveInstanceMethod, cls, 
                         NO/*initialize*/, YES/*cache*/, NO/*resolver*/)) 
    {
        // Resolver not implemented.
        return;
    }

    // 这里非常重要了
    BOOL (*msg)(Class, SEL, SEL) = (__typeof__(msg))objc_msgSend;
    // 直接调用这个类的SEL_resolveInstanceMethod方法 不管是否实现
    bool resolved = msg(cls, SEL_resolveInstanceMethod, sel);

    //这里如果实现了SEL_resolveInstanceMethod 那么resolved会是yes
    // 在此查找 因为我们一般在resolveInstanceMethod方法中会给类新增一个方法来实现
    IMP imp = lookUpImpOrNil(cls, sel, inst, 
                             NO/*initialize*/, YES/*cache*/, NO/*resolver*/);
    //如果实现了resolveInstanceMethod方法 那么上面的查找会找到新增的那个方法
    if (resolved  &&  PrintResolving) {
        if (imp) {
            _objc_inform("RESOLVE: method %c[%s %s] "
                         "dynamically resolved to %p", 
                         cls->isMetaClass() ? '+' : '-', 
                         cls->nameForLogging(), sel_getName(sel), imp);
        }
        else {
            // Method resolver didn't add anything?
            _objc_inform("RESOLVE: +[%s resolveInstanceMethod:%s] returned YES"
                         ", but no new implementation of %c[%s %s] was found",
                         cls->nameForLogging(), sel_getName(sel), 
                         cls->isMetaClass() ? '+' : '-', 
                         cls->nameForLogging(), sel_getName(sel));
        }
    }
}
```


这里我们就可以通过给类新增一个方法达到了 通过方法解析避免崩溃!

下面我们在来看一下 如果我们不实现方法解析,而是让他转发的方式

这里我没有找到forward方法的入口,不过`lookUpImpOrNil`方法 返回了nil。然后直接调用了

```objc
BOOL class_respondsToSelector(Class cls, SEL sel)
{
    return class_respondsToSelector_inst(cls, sel, nil);
}
```

我们先看一下参数:

```objc
Printing description of cls: RuntimeTest
Printing description of sel: (SEL) sel = "forwardingTargetForSelector:"
```
可以肯定的是这里在判断我们的类 是否实现了`forwardingTargetForSelector`这个方法,不过上一步是在哪里,我暂时没有找到入口。调试跟踪在了汇编里

![](http://og0h689k8.bkt.clouddn.com/18-4-28/67881966.jpg)


我们继续往后看,判断类是否实现了这个方法

```objc
bool class_respondsToSelector_inst(Class cls, SEL sel, id inst)
{
    IMP imp;

    if (!sel  ||  !cls) return NO;

    //查找是否实现这个方法
    imp = lookUpImpOrNil(cls, sel, inst, 
                         NO/*initialize*/, YES/*cache*/, YES/*resolver*/);
    return bool(imp);
}
```

这里我们是在类中实现了这个方法,因此这里可以找到对应的IMP,在调试走到倒数第二行的时候我们打印一下查找的结果

```
(IMP) imp = 0x0000000100002230 (debug-objc`-[RuntimeTest forwardingTargetForSelector:] at RuntimeTest.m:44)
```

很明显runtime已经找到了我们实现的方法,那么这个方法会返回yes

紧接着下一步就是调用这个方法 但是 方法的入口仍然在汇编中

![](http://og0h689k8.bkt.clouddn.com/18-4-28/63562715.jpg)


这里因为我们返回了一个可以相应这个方法的对象 那么 runtime会重启对这个对象的方法的查找

![](http://og0h689k8.bkt.clouddn.com/18-4-28/61231822.jpg)

这次我们可以利用lookUpImpOrNil方法找到我们转发target的那个方法然后执行!


如果前面讲的这两个方法都不实现,我们去实现最后一步 消息转发

```objc
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([Runtime_Target instancesRespondToSelector:aSelector]) {
            signature = [Runtime_Target instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selName = NSStringFromSelector(anInvocation.selector);
    if ([selName isEqualToString:@"noIMPMethod"]) {
        [anInvocation invokeWithTarget:self.target];
    }
    
}
```

先看方法的入口:

![](http://og0h689k8.bkt.clouddn.com/18-4-28/62171371.jpg)

接下来会调用哪个方法呢

![](http://og0h689k8.bkt.clouddn.com/18-4-28/81924777.jpg)


