## Category

下面看看Category的内部结构

```c
struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};
```

## Protocol

Protocol的定义：

 `typedef struct objc_object Protocol;`
 
 下面是protocol的内部结构
 
 ```c
 struct protocol_t : objc_object {
    const char *mangledName;
    struct protocol_list_t *protocols;
    method_list_t *instanceMethods;
    method_list_t *classMethods;
    method_list_t *optionalInstanceMethods;
    method_list_t *optionalClassMethods;
    property_list_t *instanceProperties;
    uint32_t size;   // sizeof(protocol_t)
    uint32_t flags;
    // Fields below this point are not always present on disk.
    const char **_extendedMethodTypes;
    const char *_demangledName;
    property_list_t *_classProperties;

    const char *demangledName();

    const char *nameForLogging() {
        return demangledName();
    }

    bool isFixedUp() const;
    void setFixedUp();

#   define HAS_FIELD(f) (size >= offsetof(protocol_t, f) + sizeof(f))

    bool hasExtendedMethodTypesField() const {
        return HAS_FIELD(_extendedMethodTypes);
    }
    bool hasDemangledNameField() const {
        return HAS_FIELD(_demangledName);
    }
    bool hasClassPropertiesField() const {
        return HAS_FIELD(_classProperties);
    }

#   undef HAS_FIELD

    const char **extendedMethodTypes() const {
        return hasExtendedMethodTypesField() ? _extendedMethodTypes : nil;
    }

    property_list_t *classProperties() const {
        return hasClassPropertiesField() ? _classProperties : nil;
    }
};
 ```
 
#### protocol_getName
 
 `const char * _Nonnull protocol_getName(Protocol * _Nonnull proto)`

作用: 获取一个protocol的name
参数: 目标Protocol(如果参数为nil直接返回nil)
返回值: 协议名的字符串

示例： 跟下面`objc_getProtocol`一起

PS: 看一下内部实现

```objc
const char *
protocol_getName(Protocol *proto)
{
    if (!proto) return "nil";
    else return newprotocol(proto)->demangledName();
}
```

#### objc_getProtocol

`Protocol * _Nullable objc_getProtocol(const char * _Nonnull name)`

作用: 根据一个字符串 获取这个字符串名称对应的协议
参数: 协议名称字符串
返回值: 根据字符串名称对应的协议(如果协议没找到返回NULL)

示例:

```objc
- (void)getProtocol
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    Protocol *prop1 = objc_getProtocol("RuntimeProtocol2");

    
    NSLog(@"%s",protocol_getName(prop));
    NSLog(@"%s",protocol_getName(prop1));

}
```

打印结果:

```c
2018-04-27 14:49:32.240592+0800 Runtime_ProtocolCategory[33265:52674595] RuntimeProtocol1
2018-04-27 14:49:32.240713+0800 Runtime_ProtocolCategory[33265:52674595] RuntimeProtocol2
```

`注意`: `objc_getProtocol`这个方法获取到 这个协议的前提是 这个协议必须被注册到全局的协议列表中,如果你只是声明了一个协议但是并未有任何类遵守且这个协议的名字并没有以protocol的形式出现(如果你代码中使用了@protocol(name)这种形式,也会注册到全局的协议列表中)。

PS:

```objc
static Protocol *getProtocol(const char *name)
{
    runtimeLock.assertLocked();

    // Try name as-is.
    //其实就是从一个哈希表中根据协议的名称去获取这个对应的协议
    Protocol *result = (Protocol *)NXMapGet(protocols(), name);
    if (result) return result;

    // Try Swift-mangled equivalent of the given name.
    if (char *swName = copySwiftV1MangledName(name, true/*isProtocol*/)) {
        result = (Protocol *)NXMapGet(protocols(), swName);
        free(swName);
        return result;
    }

    return nil;
}
```


#### objc_copyProtocolList

`Protocol * __unsafe_unretained _Nonnull * _Nullable objc_copyProtocolList(unsigned int * _Nullable outCount)`

作用: 获取全局的protocol
参数: 一个引用无符号整数 用户存放全局协议的总数
返回值: 一个协议的数组可以通过outCount遍历这个数组获取所有的协议

示例:

```objc
- (void)getProtocolList
{
    unsigned int outCount = 0;
    Protocol * __unsafe_unretained *props = objc_copyProtocolList(&outCount);
    for (int i = 0; i < outCount; i++) {
        Protocol *p = props[i];
        NSLog(@"%s",protocol_getName(p));
    }
}
```

打印结果:

```c
2018-04-27 15:02:24.306379+0800 Runtime_ProtocolCategory[33639:52719039] SCNAnimation
2018-04-27 15:02:24.306504+0800 Runtime_ProtocolCategory[33639:52719039] _CDPModel
2018-04-27 15:02:24.306598+0800 Runtime_ProtocolCategory[33639:52719039] NSFetchRequestResult
2018-04-27 15:02:24.306726+0800 Runtime_ProtocolCategory[33639:52719039] UIAdaptivePresentationControllerDelegate
2018-04-27 15:02:24.306828+0800 Runtime_ProtocolCategory[33639:52719039] INDoubleResolutionResultExport
2018-04-27 15:02:24.306968+0800 Runtime_ProtocolCategory[33639:52719039] VKImageCanvasDelegate
2018-04-27 15:02:24.307070+0800 Runtime_ProtocolCategory[33639:52719039] CNAvatarViewController_Private
2018-04-27 15:02:24.307156+0800 Runtime_ProtocolCategory[33639:52719039] _UISharingPublicController
2018-04-27 15:02:24.307245+0800 Runtime_ProtocolCategory[33639:52719039] _CNBufferingStrategy

.......省略.......
```

`注意`: 如果你使用`getProtocol`获取不到某个协议那么可以使用这个方法,看一下你要获取的协议是否在这个协议列表中,如果不在那么`getProtocol`是肯定获取不到的。

#### protocol_isEqual

`BOOL protocol_isEqual(Protocol * _Nullable proto, Protocol * _Nullable other)`

作用: 比较两个协议是否相等
参数: 要比较的两个协议
返回值: 是否相等

示例:

```objc
- (void)protocolEqual
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    Protocol *prop1 = objc_getProtocol("RuntimeProtocol2");
    if (protocol_isEqual(prop, prop1)) {
        NSLog(@"prop equal to prop1");
    } else {
        NSLog(@"prop not equal to prop1");
    }
    
    
    Protocol *prop2 = objc_getProtocol("RuntimeProtocol2");
    if (protocol_isEqual(prop2, prop1)) {
        NSLog(@"prop2 equal to prop1");
    }else {
        NSLog(@"prop2 not equal to prop1");
    }
    
}
```

打印结果:

```c
2018-04-27 15:19:26.738894+0800 Runtime_ProtocolCategory[34230:52778779] prop not equal to prop1
2018-04-27 15:19:26.739012+0800 Runtime_ProtocolCategory[34230:52778779] prop2 equal to prop1
```

PS:来看一下具体的实现，从实现我们可以看出 协议相等 包含另一种情况就是这两个协议互相遵守！
```objc
BOOL protocol_isEqual(Protocol *self, Protocol *other)
{
    if (self == other) return YES;  //直接用等号判断
    if (!self  ||  !other) return NO;

    //如果这两个协议互相遵守彼此 那么这两个协议也相等
    if (!protocol_conformsToProtocol(self, other)) return NO;
    if (!protocol_conformsToProtocol(other, self)) return NO;

    return YES;
}
```

#### protocol_conformsToProtocol

`protocol_conformsToProtocol(Protocol * _Nullable proto,Protocol * _Nullable other)`

作用: 判断一个协议是否遵守另外一个协议
参数: proto 被判断的协议  other 被遵守的协议
返回值: 是否遵守

示例:

```objc
- (void)protocolConformProtocol
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    Protocol *prop1 = objc_getProtocol("RuntimeProtocol2");
    if (protocol_conformsToProtocol(prop1, prop)) {
        NSLog(@"RuntimeProtocol2 遵守了 RuntimeProtocol1");
    }
}

```

打印结果:

```c
2018-04-27 15:34:52.879961+0800 Runtime_ProtocolCategory[34867:52834129] RuntimeProtocol2 遵守了 RuntimeProtocol1
```

#### protocol_copyPropertyList

`objc_property_t _Nonnull * _Nullable
protocol_copyPropertyList(Protocol * _Nonnull proto,unsigned int * _Nullable outCount)`

作用: 获取协议中的属性列表
参数: proto目标协议,outCount协议中属性的个数
返回值:objc_property_t的一个属性数组

示例:

```objc
- (void)copyProtocolPropertyList
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    unsigned int  outCount = 0;
    objc_property_t *property = protocol_copyPropertyList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t p = property[i];
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
}
```

打印结果:

```c
2018-04-27 15:40:29.241719+0800 Runtime_ProtocolCategory[35101:52855125] name
2018-04-27 15:40:29.241834+0800 Runtime_ProtocolCategory[35101:52855125] T@"NSString",&,N
```

#### protocol_getProperty

`objc_property_t _Nullable protocol_getProperty(Protocol * _Nonnull proto,
                     const char * _Nonnull name,
                     BOOL isRequiredProperty, BOOL isInstanceProperty)`
                     
作用: 获取协议中指定的属性
参数: proto目标参数,name要获取属性的名称,isRequiredProperty是否为必须的Property，isInstanceProperty是否为对象属性(就没有类属性吧)
返回值: objc_property_t 协议中对应的那个属性

示例:

```objc
- (void)getSpecificProperty
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    //获取指定的属性
    objc_property_t p = protocol_getProperty(prop, "name", YES, YES);
    if (p) {
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
}
```

打印结果:

```
2018-04-27 15:46:14.257494+0800 Runtime_ProtocolCategory[35302:52875892] name
2018-04-27 15:46:14.257628+0800 Runtime_ProtocolCategory[35302:52875892] T@"NSString",&,N
```

#### protocol_addProperty

`void
protocol_addProperty(Protocol * _Nonnull proto, const char * _Nonnull name,
                     const objc_property_attribute_t * _Nullable attributes,
                     unsigned int attributeCount,
                     BOOL isRequiredProperty, BOOL isInstanceProperty)`
                     
作用: 为协议添加一个属性
参数: proto 目标协议,name新添加的属性名,attributes 属性的属性,attributeCount是attributes的个数,isRequiredProperty是否为必须实现的property,isInstanceProperty是否为实例属性。
返回值: void

示例: 跟后面一起

`注意`: 先看一下官方给这个方法的备注

```objc
 * Adds a property to a protocol. The protocol must be under construction. 
```

只有在protocol正在被创建的时候(还没有被注册)的时候才能使用这个方法给协议添加属性。具体那么到底什么时候能使用呢,我们下面会一起讲。

#### protocol_addProtocol

`void
protocol_addProtocol(Protocol * _Nonnull proto, Protocol * _Nonnull addition)`

作用: 给一个协议添加一个协议(当前协议遵守这个协议) 
参数: proto目标协议，addition 需要添加的协议(这个协议必须是已经注册的)
返回值: void

示例: 还是跟后面一起

`注意`: 与添加属性类似 这个方法只能在proto还未被注册的时候添加,同时要求addition已经被注册了。下面是官方的解释

```
 * Adds an incorporated protocol to another protocol. The protocol being
 * added to must still be under construction, while the additional protocol
 * must be already constructed.
```

#### protocol_addMethodDescription

` void
protocol_addMethodDescription(Protocol * _Nonnull proto, SEL _Nonnull name,
                              const char * _Nullable types,
                              BOOL isRequiredMethod, BOOL isInstanceMethod) `
作用: 给协议添加一个方法
参数: proto 目标协议,name 要添加方法的名称(SEL),types 方法的参数和返回值的类型编码，后面的两个属性跟添加协议的时候相同。
返回值: void

下面看看内部的实现,根据是否必须实现是否是实例的属性的条件判断将这个方法添加到不同的数组中。其实属性也是类似这种做法。

```objc
void 
protocol_addMethodDescription(Protocol *proto_gen, SEL name, const char *types,
                              BOOL isRequiredMethod, BOOL isInstanceMethod) 
{
    protocol_t *proto = newprotocol(proto_gen);

    extern objc_class OBJC_CLASS_$___IncompleteProtocol;
    Class cls = (Class)&OBJC_CLASS_$___IncompleteProtocol;

    if (!proto_gen) return;

    rwlock_writer_t lock(runtimeLock);

    if (proto->ISA() != cls) {
        _objc_inform("protocol_addMethodDescription: protocol '%s' is not "
                     "under construction!", proto->nameForLogging());
        return;
    }

    if (isRequiredMethod  &&  isInstanceMethod) {
        protocol_addMethod_nolock(proto->instanceMethods, name, types);
    } else if (isRequiredMethod  &&  !isInstanceMethod) {
        protocol_addMethod_nolock(proto->classMethods, name, types);
    } else if (!isRequiredMethod  &&  isInstanceMethod) {
        protocol_addMethod_nolock(proto->optionalInstanceMethods, name,types);
    } else /*  !isRequiredMethod  &&  !isInstanceMethod) */ {
        protocol_addMethod_nolock(proto->optionalClassMethods, name, types);
    }
}
```

示例: 跟下面一起(只有在创建未注册的情况下才可以 添加 因此示例只写一份就够了 懒 ~~~)

#### objc_allocateProtocol

`Protocol * _Nullable
objc_allocateProtocol(const char * _Nonnull name) `

作用: 创建一个协议但是在未注册之前都是无法使用的
参数: 协议的名称
返回值: 一个创建好的协议

`注意`: 如果协议的名字跟目前已经存在的一个协议的名称相同,那么返回nil。这个方法没有对应的dispose方法。

示例: 当然还是跟后面的一起了

#### objc_registerProtocol

`void objc_registerProtocol(Protocol * _Nonnull proto) `

作用: 注册一个刚创建的协议,一旦注册之后这个协议就是不可以改变的
参数: 协议的名称
返回值: void

示例:(终于有了 不过不要高兴太早)

```objc
Protocol *prop = objc_allocateProtocol("RuntimeProtocol3");
    
    // 为协议添加方法
    protocol_addMethodDescription(prop, @selector(addMethod), "v@:", NO, YES);
    
    //为协议添加属性
    objc_property_attribute_t attrs[] = { { "T", "@\"NSString\"" }, { "&", "N" }, { "V", "" } };
    protocol_addProperty(prop, "newAddProperty", attrs, 3, NO, YES);
    
    // 添加一个已注册的协议到协议中
    protocol_addProtocol(prop, objc_getProtocol("RuntimeProtocol1"));
    
    //在运行时注册新创建的协议  所有的添加操作都必须放在注册操作之前
    objc_registerProtocol(prop);
    
    NSLog(@"------------------create finish ------------------------");
```

只有示例 代码输出要在讲完后面两个方法在说


#### protocol_copyMethodDescriptionList

`struct objc_method_description * _Nullable
protocol_copyMethodDescriptionList(Protocol * _Nonnull proto,
                                   BOOL isRequiredMethod,
                                   BOOL isInstanceMethod,
                                   unsigned int * _Nullable outCount)`
                                   
作用: 获取一个协议的所有方法(根据后面满足要求的方法)
参数: proto 目标协议, isRequiredMethod是否为@required的方法,isInstanceMethod是否为实例方法,outCount方法的个数。
返回值: 一个C数组objc_method_description(包含name和type) 如果没有匹配的方法返回NULL

`注意`:如果一个协议遵守了另一个协议 那么另一个协议的方法在这里不会返回

#### protocol_getMethodDescription

` struct objc_method_description
protocol_getMethodDescription(Protocol * _Nonnull proto, SEL _Nonnull aSel,
                              BOOL isRequiredMethod, BOOL isInstanceMethod)`
                              
作用: 获取协议中某一个满足条件的方法
参数: 与`protocol_copyMethodDescriptionList`相同
返回值: 对应方法的objc_method_description(内有 name和types属性)

示例:(终于等到你)

```objc
- (void)addProtocolDurRuntime
{
    Protocol *prop = objc_allocateProtocol("RuntimeProtocol3");
    
    // 为协议添加方法
    protocol_addMethodDescription(prop, @selector(addMethod), "v@:", NO, YES);
    
    //为协议添加属性
    objc_property_attribute_t attrs[] = { { "T", "@\"NSString\"" }, { "&", "N" }, { "V", "" } };
    protocol_addProperty(prop, "newAddProperty", attrs, 3, NO, YES);
    
    // 添加一个已注册的协议到协议中
    protocol_addProtocol(prop, objc_getProtocol("RuntimeProtocol1"));
    
    //在运行时注册新创建的协议  所有的添加操作都必须放在注册操作之前
    objc_registerProtocol(prop);
    
    NSLog(@"------------------create finish ------------------------");
    
    //获取协议中指定条件的方法的方法描述数组
    unsigned int outCount = 0;
   struct objc_method_description *desc = protocol_copyMethodDescriptionList(prop, NO, YES, &outCount);
    for (int i = 0; i < outCount; i++) {
        struct objc_method_description md = desc[i];
        NSLog(@"%s",md.types);
        NSLog(@"%s",sel_getName(md.name));
    }
    
    //获取某一个方法
    struct objc_method_description desc1 = protocol_getMethodDescription(prop, @selector(addMethod), NO, YES);
    NSLog(@"%s",desc1.types);
    NSLog(@"%s",sel_getName(desc1.name));
    
    
    //获取属性列表
    outCount = 0;
    objc_property_t *property = protocol_copyPropertyList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t p = property[i];
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
    //获取指定的属性
    objc_property_t p = protocol_getProperty(prop, "newAddProperty", NO, YES);
    if (p) {
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
    outCount = 0;
    Protocol * __unsafe_unretained _Nonnull *prto = protocol_copyProtocolList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        Protocol *p = prto[i];
        NSLog(@"%s",protocol_getName(p));
    }
    
}
```

打印结果:

```c
2018-04-27 16:28:37.615260+0800 Runtime_ProtocolCategory[36611:53025122] ------------------create finish ------------------------
2018-04-27 16:28:37.615411+0800 Runtime_ProtocolCategory[36611:53025122] v@:
2018-04-27 16:28:37.615500+0800 Runtime_ProtocolCategory[36611:53025122] addMethod
2018-04-27 16:28:37.615594+0800 Runtime_ProtocolCategory[36611:53025122] v@:
2018-04-27 16:28:37.615691+0800 Runtime_ProtocolCategory[36611:53025122] addMethod
2018-04-27 16:28:37.615799+0800 Runtime_ProtocolCategory[36611:53025122] RuntimeProtocol1
```



