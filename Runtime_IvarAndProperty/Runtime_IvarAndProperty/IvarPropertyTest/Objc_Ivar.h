//
//  Objc_Ivar.h
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Objc_Ivar : NSObject
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *works;

- (void)getIvarName;
@end
