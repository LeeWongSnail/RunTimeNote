//
//  ClassProperty.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassProperty : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSArray *works;



- (void)getProperty;
- (void)copyPropertyList;
- (void)addPropertyDynamic;
- (void)replaceClassProperty;
@end
