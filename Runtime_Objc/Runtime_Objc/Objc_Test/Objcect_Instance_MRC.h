//
//  Objc_Instance.h
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Objcect_Instance_MRC : NSObject

@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, copy) NSString *name;
- (void)setInstanceValue;
- (void)getInstanceValue;
- (void)getIvarAtIndex;

- (void)getIvarValue;
- (void)setIvarValue;
@end
