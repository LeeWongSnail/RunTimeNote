//
//  Category+Demo.m
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Category+Demo.h"

@implementation Runtime_Category (Demo)

- (void)method2
{
    NSLog(@"%s",__func__);
}

+ (void)method4
{
    NSLog(@"%s",__func__);
}

@end
