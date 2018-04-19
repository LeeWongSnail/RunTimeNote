//
//  DataMap.m
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "DataMap.h"

/*
 假定这样一个场景，我们从服务端两个不同的接口获取相同的字典数据，
 但这两个接口是由两个人写的，相同的信息使用了不同的字段表示。我们在接收到数据时，
 可将这些数据保存在相同的对象中。对象类如下定义
 **/

#import <objc/runtime.h>

static NSMutableDictionary *map = nil;
@implementation DataMap
+ (void)load
{
    map = [NSMutableDictionary dictionary];
    map[@"name1"]                = @"name";
    map[@"status1"]              = @"status";
    map[@"name2"]                = @"name";
    map[@"status2"]              = @"status";
}


- (void)setDataWithDic:(NSDictionary *)dic
{
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *propertyKey = [self propertyForKey:key];
        if (propertyKey)
        {
            objc_property_t property = class_getProperty([self class], [propertyKey UTF8String]);
            // TODO: 针对特殊数据类型做处理
            NSString *attributeString = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
          
            [self setValue:obj forKey:propertyKey];
        }
    }];
}

- (NSString *)propertyForKey:(NSString *)aKey
{
    return map[aKey];
}

@end
