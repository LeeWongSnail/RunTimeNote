## Runtime 之Objc

### Object

一个对象在内存中的结构是：

```c
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};
```

#### object_copy

`id object_copy(id obj, size_t size)`

作用: 拷贝一个对象
参数: obj 要被拷贝的对象, size 被拷贝对象的大小
返回值: 一个新的对象

示例:

```objc
- (void)copyAtoBWithClass
{
    NSObject *a = [[NSObject alloc] init];
    //返回指定对象的一份拷贝
    id newB = object_copy(a, class_getInstanceSize(Father.class));
    
    object_setClass(newB, Father.class);
    NSLog(@"%@",newB);
    // 释放指定对象占用的内存
    object_dispose(a);
}
```

打印结果:

```c
2018-04-26 14:54:04.195180+0800 Runtime_Objc[12086:50541839] <Father: 0x600000230e60>
```

使用场景:

 假设我们有类A和类B，且类B是类A的子类。类B通过添加一些额外的属性来扩展类A。
 现在我们创建了一个A类的实例对象，并希望在运行时将这个对象转换为B类的实例对象，
 这样可以添加数据到B类的属性中。这种情况下，我们没有办法直接转换，
 因为B类的实例会比A类的实例更大，没有足够的空间来放置对象。此时，我们就要以使用以上几个函数来    
 处理这种情况

#### object_dispose

`id object_dispose(id obj)`

作用: 释放对象的内存，销毁对象
参数: 需要被释放的对象
返回值: nil

示例:

同`object_copy`

`注意`:ARC下不可用。该函数的实现是先调用objc_destructInstance销毁对象，再调用free()释放内存。

### Create Class

#### objc_allocateClassPair

`Class objc_allocateClassPair(Class super, const char *name, size_t extraBytes)`

作用: 创建一个新的类和元类
参数: super 父类。如果想创建一个基类，就传入Nil;name 类名;extraBytes 字面理解是额外字节数一般传0就可以。
返回值：返回新的类，如果创建失败则返回Nil(已经有相同名字的类)

示例:
跟下面的一起

#### objc_registerClassPair

`void objc_registerClassPair(Class cls)`

作用:注册一个类，在objc_allocateClassPair之后调用
参数:要注册的目标类
返回值:void

示例:
跟后面的放一起


#### objc_disposeClassPair

`void objc_disposeClassPair(Class cls)`

作用：销毁类和它的元类
参数：要被销毁的类

`注意`: 被销毁的类，必须是通过objc_allocateClassPair创建的。如果该类有子类或者实例存在，请不要调用这个方法。

示例：

```objc
- (void)createNewClassInRuntime
{
    //新建一个类
    //如果我们要创建一个根类，则superclass指定为Nil。extraBytes通常指定为0，该参数是分配给类和元类对象尾部的索引ivars的字节数。
    Class cls = objc_allocateClassPair(NSObject.class, "MyClass", 0);
    
    //添加类的对象方法
    class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
    class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
    
    //添加类的实例变量
    class_addIvar(cls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");

    //添加属性
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_addProperty(cls, "property2", attrs, 3);
    
    //注册类
    objc_registerClassPair(cls);

    NSLog(@"-------------vertify-----------------");
    [NSString stringWithFormat:@"current class name : %s",class_getName(NSClassFromString(@"MyClass"))];
    
    NSLog(@"-----------method list -----------------");
    unsigned int outCount = 0;
    Method *list = class_copyMethodList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0; i < outCount; i++) {
        Method m = list[i];
        if (m != NULL) {
            NSLog(@"method %s", method_getName(m));
        }
    }
    free(list);
    
    
    NSLog(@"-------------ivar---------------");
    outCount = 0;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0 ; i < outCount; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
    free(vars);
    
    
    NSLog(@"-----------property-----------------");
    outCount = 0;
    objc_property_t *props = class_copyPropertyList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        objc_property_t prop = props[i];
        NSLog(@"ivar name = %s  ivar type = %s",property_getName(prop),property_getAttributes(prop));
    }
    free(props);
    
    objc_disposeClassPair(cls);
}
```

打印结果：

```c
2018-04-26 15:17:51.952374+0800 Runtime_Class[12852:50630820] -------------vertify-----------------
2018-04-26 15:17:51.953355+0800 Runtime_Class[12852:50630820] -----------method list -----------------
2018-04-26 15:17:51.954224+0800 Runtime_Class[12852:50630820] method method1
2018-04-26 15:17:51.955036+0800 Runtime_Class[12852:50630820] method submethod1
2018-04-26 15:17:51.955854+0800 Runtime_Class[12852:50630820] -------------ivar---------------
2018-04-26 15:17:51.956737+0800 Runtime_Class[12852:50630820] ivar name = _ivar1  ivar type = i
2018-04-26 15:17:51.957694+0800 Runtime_Class[12852:50630820] -----------property-----------------
2018-04-26 15:17:51.959363+0800 Runtime_Class[12852:50630820] ivar name = property2  ivar type = T@"NSString",C,V_ivar1
```


### Create Instance

#### class_createInstance

`id class_createInstance(Class cls, size_t extraBytes)`

作用:创建类cls的实例。实际上这是一个创建objc_object结构体的过程，把objc_object的isa指向类cls
参数: 创建实例的类;extraBytes 定义需要额外申请的内存大小通常是0
返回值: 一个cls类型的实例

示例:

```objc
- (void)createInstance
{
    //创建的是对象类型而不是字符串常量类型
    id instance = class_createInstance([NSString class], sizeof(unsigned));
    NSLog(@"新创建了一个%s",class_getName([instance class]));
    
    
    id str1 = [instance init];
    NSLog(@"%@", [str1 class]);
    id str2 = [[NSString alloc] initWithString:@"test"];
    NSLog(@"%@", [str2 class]);
}
```

打印结果:

```c
2018-04-26 15:25:44.456149+0800 Runtime_Class[13120:50660035] 新创建了一个NSString
2018-04-26 15:25:44.457052+0800 Runtime_Class[13120:50660035] NSString
2018-04-26 15:25:44.458241+0800 Runtime_Class[13120:50660035] __NSCFConstantString
```

`注意`: 在ARC环境下不可用

#### objc_constructInstance

`id objc_constructInstance(Class cls, void *bytes)`

作用:在指定位置创建实例
参数:指定位置
返回值:创建的实例

示例:

```objc
- (id)createInstance
{
    size_t objSize = class_getInstanceSize([Father class]);
    size_t allocSize = 2 * objSize;
    uintptr_t ptr = (uintptr_t)calloc(allocSize, 1);
    id obj = objc_constructInstance([Father class], &ptr);
    NSLog(@"%@",[obj class]);
    return obj;
}
```

打印结果:

```
2018-04-26 15:30:48.523134+0800 Runtime_Objc[13313:50680272] Father
```

#### objc_destructInstance

`void * objc_destructInstance(id obj)`

作用:销毁一个实例，但是不会释放内存。
参数: 需要销毁的实例
返回值: void

示例:

```objc
- (void)class_destoryInstance
{
    Father *tempPerson = [[Father alloc] init];
    tempPerson.name = @"Lee";
    // 释放后 无法取得name的值
    NSLog(@"before 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    objc_destructInstance(tempPerson);
    NSLog(@"after 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    
    //上面的destructInstance 并没有将对象也给释放
    [tempPerson release];
}
```

打印结果:

```c
2018-04-26 15:34:41.769145+0800 Runtime_Objc[13449:50695497] before 销毁类实例---<Father: 0x60c000019920> destruct result Lee
2018-04-26 15:34:41.769286+0800 Runtime_Objc[13449:50695497] after 销毁类实例---<Father: 0x60c000019920> destruct result (null)
```

`注意`:在ARC下不可用,如果参数obj是nil的话，什么都不干直接return。

PS:我们来看一下这个方法

```objc
* objc_destructInstance 
* Destroys an instance without freeing memory.  销毁这个对象但是没有释放所占用的控件
* Calls C++ destructors.
* Calls ARC ivar cleanup.
* Removes associative references.
* Returns `obj`. Does nothing if `obj` is nil.

void *objc_destructInstance(id obj) 
{
    if (obj) {
        // Read all of the flags at once for performance.
        bool cxx = obj->hasCxxDtor();   //是否有C++相关的对象
        bool assoc = obj->hasAssociatedObjects(); //是否有关联对象

        // This order is important. 这里顺序非常重要
        if (cxx) object_cxxDestruct(obj); //先释放C++对象
        if (assoc) _object_remove_assocations(obj); //释放关联对象
        obj->clearDeallocating(); //这里会清除weak弱引用 清除这个对象dealloc
    }

    return obj;
}
```


### Ivar

#### object_setInstanceVariable

`Ivar object_setInstanceVariable(id obj, const char *name, void *value)`

作用:改变变量的值
参数:obj 需要被改变的实例变量的类的对象。name 需要被改变变量的名字。value 新的值
返回值:修改之后的ivar

示例:

```objc
- (void)setInstanceValue
{
    self.dict = @{@"name":@"Lee"};
    
    NSDictionary *dict1 = @{@"name":@"LeeWong"};
    
    object_setInstanceVariable(self, "_dict", dict1);

    NSLog(@"%@",self.dict);
}
```

打印结果:

```c
2018-04-26 15:38:40.952969+0800 Runtime_Objc[13615:50711924] {
    name = LeeWong;
}
```

PS:我们来看一下这个方法的实现,实际上最终是调用的_object_setIvar方法 后面我们在细说

```objc
Ivar _object_setInstanceVariable(id obj, const char *name, void *value, 
                                 bool assumeStrong)
{
    Ivar ivar = nil;

    if (obj  &&  name  &&  !obj->isTaggedPointer()) {
        if ((ivar = _class_getVariable(obj->ISA(), name))) {
            _object_setIvar(obj, ivar, (id)value, assumeStrong);
        }
    }
    return ivar;
}
```

#### object_getInstanceVariable

`Ivar object_getInstanceVariable(id obj, const char *name, void **outValue)`

作用:获取实例变量的值
参数:obj 需要获取的实例变量的类的对象。 name 变量的名字。outValue 指向实例变量值的指针
返回值: 获取到的实例变量

示例:

```objc
- (void)getInstanceValue
{
    self.name = @"LeeWong";
    NSString *getName = @"copy";
    //obj 需要获取的实例变量的类的对象。 name 变量的名字。outValue 指向实例变量值的指针
    object_getInstanceVariable(self, "_name", (void *)&getName);
    NSLog(@"%@",getName);
}
```

打印结果:

```c
2018-04-26 15:49:11.106286+0800 Runtime_Objc[13955:50751727] LeeWong
```

PS:我们来看一下内部实现,实际上是先使用`class_getInstanceVariable`获取到这个ivar,然后在调用object_getIvar获取ivar对应的值。

```objc
Ivar object_getInstanceVariable(id obj, const char *name, void **value)
{
    if (obj  &&  name  &&  !obj->isTaggedPointer()) {
        Ivar ivar;
        if ((ivar = class_getInstanceVariable(obj->ISA(), name))) {
            if (value) *value = (void *)object_getIvar(obj, ivar);
            return ivar;
        }
    }
    if (value) *value = nil;
    return nil;
}
```

#### object_getIndexedIvars

`OBJC_EXPORT void *object_getIndexedIvars(id obj)`

作用:创`ivar`时，runtime会在`ivar`的内存存储区域后面再分配一点额外的空间，也就是`id class_createInstance(Class cls, size_t extraBytes)`中的`extraBytes`。这个而函数用于获取`extraBytes`。利用这块空间的起始指针可以索引实例变量（ivars）

参数:目标对象
返回值: void

示例:

```objc
- (void)getIvarAtIndex
{
    NSArray *arrT = @[@"1",@"2",@"3"];
    void *ivar = object_getIndexedIvars(arrT);
    
    NSLog(@"%@", *(id *)(ivar + 0));
    NSLog(@"%@", *(id *)(ivar + sizeof(NSArray*)));
    NSLog(@"%@", *(id *)(ivar + sizeof(NSArray*)*2));
    
}
```

打印结果:

```c
2018-04-26 15:54:36.590647+0800 Runtime_Objc[14138:50772412] 1
2018-04-26 15:54:36.590754+0800 Runtime_Objc[14138:50772412] 2
2018-04-26 15:54:36.590840+0800 Runtime_Objc[14138:50772412] 3
```

附上官方对于这个方法的解释:

```
 * @note This function returns a pointer to any extra bytes allocated with the instance
 *  (as specified by \c class_createInstance with extraBytes>0). This memory follows the
 *  object's ordinary ivars, but may not be adjacent to the last ivar.
 * @note The returned pointer is guaranteed to be pointer-size aligned, even if the area following
 *  the object's last ivar is less aligned than that. Alignment greater than pointer-size is never
 *  guaranteed, even if the area following the object's last ivar is more aligned than that.
 * @note In a garbage-collected environment, the memory is scanned conservatively.
```

#### object_getIvar

`id object_getIvar(id object, Ivar ivar)`

作用:读取变量的值(getInstanceVariable实际就是调用这个方法,因此 在已经知道ivar的情况下，这个函数比object_getInstanceVariable更快。)
参数: object 目标对象 ivar 目标实例变量
返回值: 获取到的实例变量的值

示例:

```objc
- (void)getIvarValue
{
    self.name = @"LeeWong";
    //object 包含该变量的对象。ivar 需要被读取的变量
    //在已经知道ivar的情况下，这个函数比object_getInstanceVariable更快
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    NSLog(@"%@",object_getIvar(self, ivar));
}
```

打印结果:

```c
2018-04-26 16:05:54.568081+0800 Runtime_Objc[14479:50813121] LeeWong
```

#### object_setIvar

`void object_setIvar(id object, Ivar ivar, id value)`

作用：设置变量的值
参数：object 包含该变量的对象。 ivar 需要赋值的变量。value 变量新的值
返回值：void

示例：

```objc
- (void)setIvarValue
{
    self.name = @"123";
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    //object 包含该变量的对象。 ivar 需要赋值的变量。value 变量新的值。
    object_setIvar(self, ivar, @"LeeWong");
    NSLog(@"%@",self.name);
}
```

打印结果：

```c
2018-04-26 16:09:39.835387+0800 Runtime_Objc[14642:50827694] LeeWong
```

`注意`：在已经知道ivar的情况下，这个函数比object_setInstanceVariable更快。

### Object_Class

### object_getClassName

`const char *object_getClassName(id obj)`

作用:获取对象的类名
参数: 目标对象
返回值: 类的名称字符串

示例：

```objc
- (void)getClassName
{
    Father *father = [[Father alloc] init];
    NSLog(@"father的类名是：%s",object_getClassName(father));
}
```

打印结果:

```
2018-04-26 16:14:17.305130+0800 Runtime_Objc[14810:50845616] father的类名是：Father
```

#### object_getClass

`Class object_getClass(id object)`

作用: 获取对象的类
参数: 目标对象
返回值: 目标对象的Class

示例:

```objc
- (void)getClass
{
    Father *father = [[Father alloc] init];
    Class cls = object_getClass(father);
    NSLog(@"%s",class_getName(cls));
}
```

打印结果:

```c
2018-04-26 16:16:59.619951+0800 Runtime_Objc[14924:50856651] Father
```

PS:我们来看一下这个方法的具体实现：获取object的类，也就是isa指针，然后传给`class_getName(Class cls)`函数

```objc
Class object_getClass(id obj)
{
    if (obj) return obj->getIsa();
    else return Nil;
}
```

#### object_setClass

`Class object_setClass(id object, Class cls)`

作用: 设置对象的类
参数: object 需要设置类的对象 cls 需要设置的类
返回值:返回object之前的类或者Nil

示例:

```objc
- (void)setObjClass
{
    NSObject *obj = [[NSObject alloc] init];
    //object 需要设置类的对象。 cls 需要设置的类
    NSLog(@"%@",object_setClass(obj, [Father class]));
    NSLog(@"%@",obj);
}
```

打印结果:

```c
2018-04-26 16:23:14.212155+0800 Runtime_Objc[15193:50881939] NSObject
2018-04-26 16:23:14.212352+0800 Runtime_Objc[15193:50881939] <Father: 0x6040000037d0>
```

`注意`:这里obj不要设置为nil,任何类都不可能是nil类型的。

PS：我们来看一下这个方法的具体实现,其实修改某个obj的class 主要就是修改他的ISA指针

```objc
Class object_setClass(id obj, Class cls)
{
    if (!obj) return nil;

    // Prevent a deadlock between the weak reference machinery
    // and the +initialize machinery by ensuring that no 
    // weakly-referenced object has an un-+initialized isa.
    // Unresolved future classes are not so protected.
    if (!cls->isFuture()  &&  !cls->isInitialized()) {
        _class_initialize(_class_getNonMetaClass(cls, nil));
    }

    return obj->changeIsa(cls); //主要的就是修改这个obj的ISA指针
}
```

#### objc_getClassList

`int objc_getClassList(Class *buffer, int bufferCount)`

作用:获取到当前注册的有类的总个数
参数:  buffer已分配好内存空间的数组,bufferCount数组中可存放元素的个数，返回值是注册的类的总数
返回值: 总个数

示例:

```objc
- (void)getClassList
{
    int outCount = 0;
    int newNumClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    while (outCount < newNumClasses) {
        outCount = newNumClasses;
        classes = (Class *)realloc(classes, sizeof(Class) * outCount);
        newNumClasses = objc_getClassList(classes, outCount);
        for (int i = 0; i < outCount; i++) {
            const char *className = class_getName(classes[i]);
            NSLog(@"%s", className);
        }
        
    }
    free(classes);

}
```

打印结果:

```c
2018-04-26 16:39:02.403348+0800 Runtime_Objc[15761:50936675] _CNZombie_
2018-04-26 16:39:02.403525+0800 Runtime_Objc[15761:50936675] JSExport
2018-04-26 16:39:02.403640+0800 Runtime_Objc[15761:50936675] NSLeafProxy
2018-04-26 16:39:02.403741+0800 Runtime_Objc[15761:50936675] NSProxy
2018-04-26 16:39:02.403836+0800 Runtime_Objc[15761:50936675] _UITargetedProxy
2018-04-26 16:39:02.403940+0800 Runtime_Objc[15761:50936675] _UIViewServiceReplyControlTrampoline
2018-04-26 16:39:02.404045+0800 Runtime_Objc[15761:50936675] _UIViewServiceReplyAwaitingTrampoline
2018-04-26 16:39:02.404145+0800 Runtime_Objc[15761:50936675] _UIViewServiceUIBehaviorProxy
2018-04-26 16:39:02.404239+0800 Runtime_Objc[15761:50936675] _UIViewServiceImplicitAnimationDecodingProxy
2018-04-26 16:39:02.404337+0800 Runtime_Objc[15761:50936675] _UIViewServiceImplicitAnimationEncodingProxy
2018-04-26 16:39:02.404431+0800 Runtime_Objc[15761:50936675] _UIUserNotificationRestrictedAlertViewProxy
2018-04-26 16:39:02.404526+0800 Runtime_Objc[15761:50936675] _UIUserNotificationAlertViewRestrictedTextField
2018-04-26 16:39:02.404619+0800 Runtime_Objc[15761:50936675] _UIQueueingProxy
2018-04-26 16:39:02.404727+0800 Runtime_Objc[15761:50936675] _UIViewServiceFencingControlProxy
2018-04-26 16:39:02.404903+0800 Runtime_Objc[15761:50936675] _UIViewControllerControlMessageDeputy
2018-04-26 16:39:02.405095+0800 Runtime_Objc[15761:50936675] _UIViewServiceViewControllerDeputy
2018-04-26 16:39:02.405274+0800 Runtime_Objc[15761:50936675] _UIActivityPlaceholderItemProxy

........省略了好多

```

`注意`:第一个参数传 NULL 时将会获取到当前注册的所有的类，此时可存放元素的个数为0，因此第二个参数可传0，返回值为当前注册的所有类的总数 

#### objc_copyClassList

`Class *objc_copyClassList(unsigned int *outCount)`

作用: 获取所有已注册的类，和上述函数 objc_getClassList 参数传入 NULL 和  0 时效果一样
参数: 一个unsigned int的值 函数内部会设置表示 类的总数
返回值: 指向所有已注册类的数组的指针

示例:

```objc
- (void)copyClassList
{
    unsigned int outCount = 0;
    Class *clss =objc_copyClassList(&outCount);
    
    for (int i = 0; i < outCount; i++) {
        NSLog(@"%s",class_getName(clss[i]));
    }
}
```

打印结果:

与objc_getClassList相同

#### objc_lookUpClass objc_getClass objc_getRequiredClass

`Class objc_lookUpClass(const char * name)`
`Class objc_getClass(const char * name)`
`Class objc_getRequiredClass(const char *name)`

作用: 返回指定类的类定义
参数: 指定类的类名
返回: 指定类的类定义

示例:

```c
- (void)getSpecificClass
{
    //而objc_lookUpClass获取指定的类，如果没有注册则返回nil
    Class cls = objc_lookUpClass("Father");
    NSLog(@"%s",class_getName(cls));
    //而objc_getClass会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil
    cls = objc_getClass("Son");
    NSLog(@"%s",class_getName(cls));
    
    //如果获取的类不存在会崩溃
    cls = objc_getRequiredClass("Son");
    NSLog(@"%s",class_getName(cls));
}
```

结果:

```c
2018-04-26 16:56:46.547208+0800 Runtime_Objc[16487:51004134] Father
2018-04-26 16:56:46.547319+0800 Runtime_Objc[16487:51004134] Son
2018-04-26 16:56:46.547404+0800 Runtime_Objc[16487:51004134] Son
```

再来看一下官网的解释:

objc_lookUpClass:

```
 * @note \c objc_getClass is different from this function in that if the class is not
 *  registered, \c objc_getClass calls the class handler callback and then checks a second
 *  time to see whether the class is registered. This function does not call the class handler callback.
```

objc_getRequiredClass:

```c
 * @note This function is the same as \c objc_getClass, but kills the process if the class is not found.
 * @note This function is used by ZeroLink, where failing to find a class would be a compile-time link error without ZeroLink.
```

#### objc_getMetaClass

`Class objc_getMetaClass(const char * name)`

作用: 获取某个类的元类
参数: 类名字符串
返回值: 获取到的元类

示例：

```objc
- (void)getMetaClass
{
    Class fatherMeta = objc_getMetaClass(class_getName([Father class]));
    NSLog(@"%s's meta-class is %s", class_getName([Father class]), class_getName(fatherMeta));
    
    
    Class sonMeta = objc_getMetaClass(class_getName([Son class]));
    NSLog(@"%s's meta-class is %s", class_getName([Son class]), class_getName(sonMeta));

    Class objMeta = objc_getMetaClass(class_getName([NSObject class]));
    NSLog(@"%s's meta class : %s",class_getName([NSObject class]), class_getName(objMeta));

    Class fatherSuperMeta = objc_getMetaClass(class_getName([Father superclass]));
    NSLog(@"%s's meta class : %s",class_getName([Father superclass]), class_getName(fatherSuperMeta));
}
```

打印结果:

```c
2018-04-26 17:03:40.805771+0800 Runtime_Class[16807:51031799] Father's meta-class is Father
2018-04-26 17:03:40.806740+0800 Runtime_Class[16807:51031799] Son's meta-class is Son
2018-04-26 17:03:40.807570+0800 Runtime_Class[16807:51031799] NSObject's meta class : NSObject
2018-04-26 17:03:40.808440+0800 Runtime_Class[16807:51031799] NSObject's meta class : NSObject
```

`注意`:每一个类都有一个自己的元类 存放着这个类对应的所有类方法。 非根类的元类的元类指向着根类的元类
 根类的元类指向类本身

PS: 看一下这个方法的实现,实际上是返回这个类的ISA指针指向的对象

```objc
Class objc_getMetaClass(const char *aClassName)
{
    Class cls;

    if (!aClassName) return Nil;

    cls = objc_getClass (aClassName);
    if (!cls)
    {
        _objc_inform ("class `%s' not linked into application", aClassName);
        return Nil;
    }

    return cls->ISA();
}
```




