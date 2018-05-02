## 方法交换

`Method Swizzling`是改变一个`selector`的实际实现的技术。通过这一技术，我们可以在运行时通过修改类的分发表中selector对应的函数，来修改方法的实现。

### 简介

例如，我们想跟踪在程序中每一个view controller展示给用户的次数：当然，我们可以在每个view controller的viewDidAppear中添加跟踪代码；但是这太过麻烦，需要在每个view controller中写重复的代码。创建一个子类可能是一种实现方式，但需要同时创建UIViewController, UITableViewController, UINavigationController及其它UIKit中view controller的子类，这同样会产生许多重复的代码。

这种情况下，我们就可以使用Method Swizzling。

在这里，我们通过method swizzling修改了UIViewController的@selector(viewWillAppear:)对应的函数指针，使其实现指向了我们自定义的xxx_viewWillAppear的实现。这样，当UIViewController及其子类的对象调用viewWillAppear时，都会打印一条日志信息

`注意`: 以上内容摘自[Objective-C Runtime 运行时之四：Method Swizzling](http://southpeak.github.io/2014/11/06/objective-c-runtime-4/)

### 内部实现

我们在简单的了解了Method Swizzling的实现之后,下面来看看具体的实现

实际上 方法交换 最核心的方法是:

`method_exchangeImplementations`

下面我们来看一下这个方法的实现:

```objc
void method_exchangeImplementations(Method m1, Method m2)
{
    if (!m1  ||  !m2) return;

    rwlock_writer_t lock(runtimeLock);

    //直接修改Method中的imp指针指向的位置
    IMP m1_imp = m1->imp;
    m1->imp = m2->imp;
    m2->imp = m1_imp;

    flushCaches(nil);

    updateCustomRR_AWZ(nil, m1);
    updateCustomRR_AWZ(nil, m2);
}
```

代码非常简单,将两个method中的IMP指向做了一个简单的交换。 

下面我们在来看一下 `flushCaches` 这个方法是什么意思？

```objc
static void flushCaches(Class cls)
{
    runtimeLock.assertWriting();

    mutex_locker_t lock(cacheUpdateLock);

    if (cls) {
        foreach_realized_class_and_subclass(cls, ^(Class c){
            cache_erase_nolock(c);
        });
    }
    else {
        foreach_realized_class_and_metaclass(^(Class c){
            cache_erase_nolock(c);
        });
    }
}
```

因为参数cls=nil因此会走下半部分。我们看到这句代码的意思是 对于所有实现的class和metaclass将缓存清除。

因为方法的实现改变了,因此这里必须将方法的缓存清空,否则可能导致由于方法缓存而导致方法调用异常的情况。

接下来我们继续看：

```objc
updateCustomRR_AWZ(nil, m1);
updateCustomRR_AWZ(nil, m2);
```

updateCustomRR_AWZ 这个方法做了什么呢？

```objc
/***********************************************************************
* Update custom RR and AWZ when a method changes its IMP
**********************************************************************/
static void
updateCustomRR_AWZ(Class cls, method_t *meth)
{
    // In almost all cases, IMP swizzling does not affect custom RR/AWZ bits. 
    // Custom RR/AWZ search will already find the method whether or not 
    // it is swizzled, so it does not transition from non-custom to custom.
    // 
    // The only cases where IMP swizzling can affect the RR/AWZ bits is 
    // if the swizzled method is one of the methods that is assumed to be 
    // non-custom. These special cases are listed in setInitialized().
    // We look for such cases here.

    if (isRRSelector(meth->name)) {
        
        if ((classNSObject()->isInitialized() && 
             classNSObject()->hasCustomRR())  
            ||  
            ClassNSObjectRRSwizzled) 
        {
            // already custom, nothing would change
            return;
        }

        bool swizzlingNSObject = NO;
        if (cls == classNSObject()) {
            swizzlingNSObject = YES;
        } else {
            // Don't know the class. 
            // The only special case is class NSObject.
            for (const auto& meth2 : classNSObject()->data()->methods) {
                if (meth == &meth2) {
                    swizzlingNSObject = YES;
                    break;
                }
            }
        }
        if (swizzlingNSObject) {
            if (classNSObject()->isInitialized()) {
                classNSObject()->setHasCustomRR();
            } else {
                // NSObject not yet +initialized, so custom RR has not yet 
                // been checked, and setInitialized() will not notice the 
                // swizzle. 
                ClassNSObjectRRSwizzled = YES;
            }
        }
    }
    else if (isAWZSelector(meth->name)) {
        Class metaclassNSObject = classNSObject()->ISA();

        if ((metaclassNSObject->isInitialized() && 
             metaclassNSObject->hasCustomAWZ())  
            ||  
            MetaclassNSObjectAWZSwizzled) 
        {
            // already custom, nothing would change
            return;
        }

        bool swizzlingNSObject = NO;
        if (cls == metaclassNSObject) {
            swizzlingNSObject = YES;
        } else {
            // Don't know the class. 
            // The only special case is metaclass NSObject.
            for (const auto& meth2 : metaclassNSObject->data()->methods) {
                if (meth == &meth2) {
                    swizzlingNSObject = YES;
                    break;
                }
            }
        }
        if (swizzlingNSObject) {
            if (metaclassNSObject->isInitialized()) {
                metaclassNSObject->setHasCustomAWZ();
            } else {
                // NSObject not yet +initialized, so custom RR has not yet 
                // been checked, and setInitialized() will not notice the 
                // swizzle. 
                MetaclassNSObjectAWZSwizzled = YES;
            }
        }
    }
}
```

这是一个非常长的方法,下面我们来一部分一部分的说:

虽然方法很长,但是方法的内容被一个if else if分开 我们来看一下判断条件

`if (isRRSelector(meth->name)) `

下面我们来具体的看一下这个条件:

```objc
// Return YES if sel is used by retain/release implementors
static bool 
isRRSelector(SEL sel)
{
    return (sel == SEL_retain          ||  sel == SEL_release              ||  
            sel == SEL_autorelease     ||  sel == SEL_retainCount          ||  
            sel == SEL_tryRetain       ||  sel == SEL_retainWeakReference  ||  
            sel == SEL_isDeallocating  ||  sel == SEL_allowsWeakReference);
}
```

类似的我们看一下 后面的条件

`if (isAWZSelector(meth->name))`

这个条件的具体实现是:

```objc
//Return YES if sel is used by alloc or allocWithZone implementors
static bool 
isAWZSelector(SEL sel)
{
    return (sel == SEL_allocWithZone  ||  sel == SEL_alloc);
}
```

从先 从命名上 最难懂的部分 `RR = retain release`  `AWZ = allocwithzone`

也就是说 如果我们交换的方法是 这两个条件下的这些方法的时候,我们需要做一个update！


### 注意点

Swizzling应该总是在+load中执行
Swizzling应该总是在dispatch_once中执行
 

## 总结
 
 以上就是 `Method Swizzling` 的解析！


