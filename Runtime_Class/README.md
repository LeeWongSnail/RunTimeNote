### Class

先看一下Class 在Runtime中的结构:

```c
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;  //isa指针指向类的元类(metaClass)

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE; //父类
    const char * _Nonnull name                               OBJC2_UNAVAILABLE; //类名
    long version                                             OBJC2_UNAVAILABLE; //类版本
    long info                                                OBJC2_UNAVAILABLE; //类的信息
    long instance_size                                       OBJC2_UNAVAILABLE; //类实例对象的大小
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE; //实例变量的列表
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;//方法列表
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE; //方法的缓存
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE; //协议列表
#endif

} OBJC2_UNAVAILABLE;
```

objc_class 是一个继承自objc_objcet的结构体

objc_object结构体的结构为：

```c
struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags

    class_rw_t *data() { 
        return bits.data();
    }
    void setData(class_rw_t *newData) {
        bits.setData(newData);
    }
    
    .... //这里省略了一些方法
```



#### class_getName

`const char * class_getName(Class cls)`

作用: 获取类的名称
参数: 类对象的名称
返回值: 类对象名称的字符串

示例:

```objc
- (NSString *)getClassName
{
    return [NSString stringWithFormat:@"current class name : %s",class_getName([self class])];
}
```

打印结果:

```c
2018-04-25 17:11:27.649212+0800 Runtime_Class[90632:48592451] current class name : ClassInfo
```

#### class_getSuperclass

`Class class_getSuperclass(Class cls)`

作用: 获取一个类的父类
参数: 要获取名称的类对象
返回值: 对应类的父类对象

示例:

```objc
- (void)getSuperClassTree
{
    Class currentClass = [Son class];
    for (int i = 0; i < 5; i++) {
        NSLog(@"Following the isa pointer %d times gives %p class type %@", i, currentClass,NSStringFromClass(currentClass));
        currentClass = class_getSuperclass(currentClass);
    }
    
    NSLog(@"NSObject's SuperClass is %@",class_getSuperclass([NSObject class]));
}
```

打印结果:

```c
2018-04-25 18:17:19.529214+0800 Runtime_Class[92720:48811264] Following the isa pointer 0 times gives 0x102d7b718 class type Son
2018-04-25 18:17:19.529334+0800 Runtime_Class[92720:48811264] Following the isa pointer 1 times gives 0x102d7b7b8 class type Father
2018-04-25 18:17:19.529455+0800 Runtime_Class[92720:48811264] Following the isa pointer 2 times gives 0x103d29ea8 class type NSObject
2018-04-25 18:17:19.529567+0800 Runtime_Class[92720:48811264] Following the isa pointer 3 times gives 0x0 class type (null)
2018-04-25 18:17:19.529691+0800 Runtime_Class[92720:48811264] Following the isa pointer 4 times gives 0x0 class type (null)
2018-04-25 18:17:19.529784+0800 Runtime_Class[92720:48811264] NSObject's SuperClass is (null)
```

#### objc_getMetaClass

`BOOL class_isMetaClass(Class  _Nullable __unsafe_unretained cls)`

作用: 判断一个类是否为元类
参数: 要判断的类的名称
返回值: bool 是否为元类

示例:

```objc
- (void)classIsMetaClass
{
    Class cls = [Father class];
    Class fatherMeta = objc_getMetaClass(class_getName([Father class]));
    NSLog(@"%@ is %@ a meta class",[Father class],class_isMetaClass(cls)?@"":@"not");
    NSLog(@"%@ is %@ a meta class",[fatherMeta class],class_isMetaClass(fatherMeta)?@"":@"not");
}
```

打印结果:

```c
2018-04-25 18:47:29.675142+0800 Runtime_Class[93611:48910663] Father is not a meta class
2018-04-25 18:47:29.675276+0800 Runtime_Class[93611:48910663] Father is  a meta class
```

#### class_getInstanceSize

`size_t class_getInstanceSize(Class  _Nullable __unsafe_unretained cls)`

作用: 获取类的实例大小
参数: 要获取的类对象
返回值: 实例的大小

示例:

```objc
- (long)getInstanceSize
{
    NSLog(@"class instance size = %ld",class_getInstanceSize([self class]));
    return class_getInstanceSize([self class]);
}
```

打印结果:

```c
2018-04-25 19:19:22.185527+0800 Runtime_Class[95628:49017081] class instance size = 8
```

### Property

#### class_getProperty

`  objc_property_t  class_getProperty(<#Class  _Nullable __unsafe_unretained cls#>, const char * _Nonnull name)`

作用: 获取类的某一个属性
参数: 属性所属的类,以及属性的名称
返回值: 要获取的这个属性(objc_property_t) 如果属性不存在返回nil

示例:

```objc
- (void)getProperty
{
    objc_property_t property = class_getProperty([self class], "name");
   NSLog(@"%s",property_getName(property));
```

打印结果:

```c
2018-04-25 19:25:49.914516+0800 Runtime_Class[95898:49041836] name
```

#### class_copyPropertyList

```objc
   unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
```

作用: 获取某个类的所有属性(不包含父类的属性)
参数: 获取哪个类的属性 传入一个数据用来记录属性的个数
返回值: 一个参数列表的入口指针

示例:

```objc
- (void)copyPropertyList
{
    unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList([Son class], &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        objc_property_t prop = props[i];
        NSLog(@"ivar name = %s  ivar type = %s",property_getName(prop),property_getAttributes(prop));
    }
    free(props);
}
```

打印结果:

```c
2018-04-25 19:31:55.071746+0800 Runtime_Class[96158:49064525] ivar name = age  ivar type = Tq,N,V_age
2018-04-25 19:31:55.071890+0800 Runtime_Class[96158:49064525] ivar name = icon  ivar type = T@"NSString",C,N,V_icon
2018-04-25 19:31:55.072011+0800 Runtime_Class[96158:49064525] ivar name = works  ivar type = T@"NSArray",&,N,V_works
```

#### class_addProperty

```
 BOOL class_addProperty(Class  _Nullable __unsafe_unretained cls, <#const char * _Nonnull name#>, <#const objc_property_attribute_t * _Nullable attributes#>, <#unsigned int attributeCount#>)
```

作用: 给某各类动态添加一个属性
参数: 为哪个类添加属性 属性名称 属性attribute attributeCount
返回值: 是否添加成功

示例:

```objc
- (void)addPropertyDynamic
{
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    if (class_addProperty([self class], "nickName", attrs, 3)) {
        NSLog(@"添加成功");
    }
  
    [self copyPropertyList];
}
```

打印结果:

```c
2018-04-25 19:37:19.188243+0800 Runtime_Class[96374:49084907] 添加成功
2018-04-25 19:37:19.188389+0800 Runtime_Class[96374:49084907] ivar name = age  ivar type = Tq,N,V_age
2018-04-25 19:37:19.188498+0800 Runtime_Class[96374:49084907] ivar name = icon  ivar type = T@"NSString",C,N,V_icon
2018-04-25 19:37:19.188593+0800 Runtime_Class[96374:49084907] ivar name = works  ivar type = T@"NSArray",&,N,V_works
```

`注意`:使用class_copyPropertyList无法打印刚刚新添加的属性

#### class_replaceProperty

```c
  class_replaceProperty(<#Class  _Nullable __unsafe_unretained cls#>, <#const char * _Nonnull name#>, <#const objc_property_attribute_t * _Nullable attributes#>, <#unsigned int attributeCount#>)
```

作用: 替换某一个属性的类型 而不是将某个属性替换为另一个属性
参数: 替换哪个类添的属性 属性名称 属性attribute attributeCount
返回值: void

示例:

```objc
- (void)replaceClassProperty
{
    objc_property_attribute_t type = {"T", "@\"NSArray\""};
    objc_property_attribute_t ownership = { "&N", "" };
    objc_property_attribute_t backingivar = { "V", "_nickName"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_replaceProperty([self class], "nickName", attrs, 3);
  
    NSLog(@"--------- after replace -----------------");
     [self copyPropertyList];
}
```

打印结果:




