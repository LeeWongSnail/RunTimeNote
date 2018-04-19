//
//  TypeEncoding.m
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "TypeEncoding.h"

@implementation TypeEncoding

- (void)getTypeEncoding
{
    self.name = @"LeeWong";
    self.age = 10;
    self.works = @[@"art",@"live",@"beautiful"];
    NSLog(@"age encoding type: %s", @encode(typeof(self.age)));
    NSLog(@"name encoding type: %s", @encode(typeof(self.name)));
    NSLog(@"works encoding type: %s", @encode(typeof(self.works)));

}

@end
