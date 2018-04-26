## Ivar & Property

### Ivar

先看一下Ivar的结构

```c
typedef struct objc_ivar *Ivar;
 struct objc_ivar {
 char *ivar_name                   OBJC2_UNAVAILABLE;    // 变量名
 char *ivar_type                 OBJC2_UNAVAILABLE;    // 变量类型
 int ivar_offset                    OBJC2_UNAVAILABLE;    // 基地址偏移字节
 #ifdef __LP64__
 int space                         OBJC2_UNAVAILABLE;
 #endif
 }
```

#### ivar_getName

`const char * ivar_getName(Ivar  v)`

作用：获取实例变量的名称
参数: 目标实例变量
返回值: 实例变量名称字符串

具体实现：

```c
const char *
ivar_getName(Ivar ivar)
{
    if (!ivar) return nil;
    return ivar->name;
}
```

#### ivar_getTypeEncoding

`const char * ivar_getTypeEncoding(Ivar v)`

作用：获取一个实例变量的类型编码
参数: 目标实例变量
返回值: 实例变量的类型编码字符串

具体实现:

```objc
const char *
ivar_getTypeEncoding(Ivar ivar)
{
    if (!ivar) return nil;
    return ivar->type;
}
```

#### ivar_getOffset

`ptrdiff_t ivar_getOffset(Ivar v)`

作用：对于类型id或其它对象类型的实例变量，可以调用object_getIvar和object_setIvar来直接访问成员变量，而不使用偏移量
参数：目标实例变量
返回值: 实例变量的offset

示例：

```objc
- (void)getIvarName
{
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSLog(@"成员变量个数: %d",outCount);
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"变量名称: %s,类型: %s,偏移量: %td",ivar_getName(ivar),ivar_getTypeEncoding(ivar),ivar_getOffset(ivar));
    }
    free(ivars);
    
}
```

打印结果

```c
2018-04-26 17:48:11.554431+0800 Runtime_IvarAndProperty[18161:51164835] 成员变量个数: 3
2018-04-26 17:48:11.554543+0800 Runtime_IvarAndProperty[18161:51164835] 变量名称: _age,类型: q,偏移量: 8
2018-04-26 17:48:11.554645+0800 Runtime_IvarAndProperty[18161:51164835] 变量名称: _name,类型: @"NSString",偏移量: 16
2018-04-26 17:48:11.554744+0800 Runtime_IvarAndProperty[18161:51164835] 变量名称: _works,类型: @"NSArray",偏移量: 24
```

### Property

先来看一下Property的数据结构

```
struct property_t {
    const char *name;
    const char *attributes;
};
```

#### property_getName

`const char *property_getName(objc_property_t property) `

作用: 获取一个属性的名称
参数: 目标属性
返回值: 这个属性的名称

具体实现：

```objc
const char *property_getName(objc_property_t prop)
{
    return prop->name;
}
```

#### property_getAttributes

`const char *property_getAttributes(objc_property_t property) `

作用: 获取属性的attribute
参数: 目标属性
返回值: 属性的attribute 字符串

具体实现:

```objc
const char *property_getAttributes(objc_property_t prop)
{
    return prop->attributes;
}
```

#### property_copyAttributeValue

`char * property_copyAttributeValue(objc_property_t property,
                            const char * attributeName)`
                            
作用:获取属性的某个attribute的值
参数: 目标属性,目标属性的哪个attribute
返回值: 目标attribute的值

示例:

```objc
- (void)copyAttributeValue
{
    objc_property_t p = class_getProperty([Father class], "name");
    NSLog(@"property name : %s",property_copyAttributeValue(p, "V"));
    NSLog(@"property type : %s",property_copyAttributeValue(p, "T"));

}
```

打印结果:

```c
2018-04-26 18:04:48.672736+0800 Runtime_IvarAndProperty[18745:51219671] property name : _name
2018-04-26 18:04:49.051310+0800 Runtime_IvarAndProperty[18745:51219671] property type : @"NSString"
```

#### property_copyAttributeList

` objc_property_attribute_t *property_copyAttributeList(objc_property_t property,unsigned int * outCount)`

作用: 获取某个属性的说有attribute
参数: 目标属性 attribute的个数
返回值: 所有attribute的数组

示例:

```objc
- (void)copyAttributeList
{
    objc_property_t p = class_getProperty([Father class], "name");
    unsigned int outCount = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(p, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_attribute_t t = attrs[i];
        NSLog(@"property name is %s --- property value is %s",t.name,t.value);
    }
}
```

打印结果:

```c
2018-04-26 18:08:51.598743+0800 Runtime_IvarAndProperty[18979:51244007] property name is T --- property value is @"NSString"
2018-04-26 18:08:51.598882+0800 Runtime_IvarAndProperty[18979:51244007] property name is & --- property value is
2018-04-26 18:08:51.598974+0800 Runtime_IvarAndProperty[18979:51244007] property name is N --- property value is
2018-04-26 18:08:51.599057+0800 Runtime_IvarAndProperty[18979:51244007] property name is V --- property value is _name
```

