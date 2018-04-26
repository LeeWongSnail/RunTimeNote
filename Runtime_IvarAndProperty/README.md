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




