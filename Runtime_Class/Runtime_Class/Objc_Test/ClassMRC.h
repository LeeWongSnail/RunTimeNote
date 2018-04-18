//
//  ClassMRC.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>


//这个类主要是针对一些只能在MRC环境下使用的方法

@interface ClassMRC : NSObject
- (id)createInstance;
- (void)class_destoryInstance;
@end
