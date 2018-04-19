//
//  DataMap.h
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataMap : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *status;

- (void)setDataWithDic:(NSDictionary *)dic;
@end
