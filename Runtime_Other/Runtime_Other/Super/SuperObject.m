//
//  SuperObject.m
//  Runtime_Other
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "SuperObject.h"

@implementation SuperObject

- (void)someInstanceMethod
{
    NSLog(@"%s",__func__);
}

+ (void)someClassMethod
{
    NSLog(@"%s",__func__);
}

@end
