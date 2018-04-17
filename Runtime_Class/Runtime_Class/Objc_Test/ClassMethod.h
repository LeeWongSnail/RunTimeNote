//
//  ClassMethod.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassMethod : NSObject
- (void)method1;
- (void)method2;

+ (void)myClassMethod;
- (void)addClassMethod;

- (void)getInstanceMethod;
- (void)getClassMethod;
- (void)getMethodList;

- (void)replaceMethodImplementation;
- (void)getMethodImplementation;
- (void)class_respondsToSelector;
@end
