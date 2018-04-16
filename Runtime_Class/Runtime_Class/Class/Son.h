//
//  Son.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Father.h"

@interface Son : Father
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSArray *works;
@end
