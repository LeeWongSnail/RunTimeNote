//
//  BlockIMP.m
//  Runtime_Other
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "BlockIMP.h"
#import <objc/runtime.h>

@implementation BlockIMP

- (void)impWithBlock
{
    // 测试代码
    IMP imp = imp_implementationWithBlock(^() {
        NSLog(@"this block in ---");
    });
    
    imp();
}

- (void)addMethod
{
    // 测试代码
    IMP imp = imp_implementationWithBlock(^(id obj, NSString *str) {
        NSLog(@"%@", str);
    });
    class_addMethod(self.class, @selector(testBlock:), imp, "v@:@");
    [self performSelector:@selector(testBlock:) withObject:@"hello world!"];

}

@end
