//
//  ClassProtocol.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/17.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassProtocol.h"
#import <objc/runtime.h>

@implementation ClassProtocol

- (void)copyProtocolList
{
    unsigned int  outCount = 0;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList([self class], &outCount);
    Protocol * protocol;
    for (int i = 0; i < outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocol name : %s",protocol_getName(protocol));
    }
    free(protocols);
}


- (void)classConformsProtocol
{
    Protocol *p = objc_getProtocol("Protocol1");
    if (class_conformsToProtocol([self class], p)) {
        NSLog(@"%s implementation %s",class_getName([self class]),protocol_getName(p));
    } else {
        NSLog(@"%s not implementation %s",class_getName([self class]),protocol_getName(p));
    }
    
    Protocol *p1 = objc_getProtocol("Protocol2");
    if (class_conformsToProtocol([self class], p1)) {
        NSLog(@"%s implementation %s",class_getName([self class]),protocol_getName(p1));
    } else {
        NSLog(@"%s not implementation %s",class_getName([self class]),protocol_getName(p1));
    }
    
}


- (void)addProtocol
{
    Protocol *p = objc_getProtocol("Protocol2");
    if (class_addProtocol([self class], p)) {
        NSLog(@"add protoccol2 success");
    } else {
        NSLog(@"add protocol2 failed");
    }
    [self classConformsProtocol];
}


#pragma mark -

- (void)method1InProtocol1
{
    NSLog(@"%s",__func__);
}


@end
