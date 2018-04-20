//
//  MultipleInheritance.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "MultipleInheritance.h"
#import "SomeClass.h"

@interface MultipleInheritance()
@property (nonatomic, strong) SomeClass *sth;
@end

@implementation MultipleInheritance

- (instancetype)init
{
    if (self = [super init]) {
        self.sth = [[SomeClass alloc] init];
    }
    return self;
}


- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *selectorStr = NSStringFromSelector(aSelector);
    if ([selectorStr isEqualToString:@"drink"]) {
        return self.sth;
    }
    
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *selectorStr = NSStringFromSelector(aSelector);
    if ([selectorStr isEqualToString:@"drink"]) {
        return [self.sth respondsToSelector:aSelector];
    } else {
        return [super respondsToSelector:aSelector];
    }
}

- (BOOL)isKindOfClass:(Class)aClass
{
    NSString *cls = NSStringFromClass(aClass);
    if ([cls isEqualToString:@"SomeClass"]) {
        return YES;
    } else {
        return [super isKindOfClass:aClass];
    }
}

@end
