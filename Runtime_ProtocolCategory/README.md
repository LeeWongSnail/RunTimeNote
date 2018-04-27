# Protocol

Protocol的定义：

 `typedef struct objc_object Protocol;`
 
 
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


