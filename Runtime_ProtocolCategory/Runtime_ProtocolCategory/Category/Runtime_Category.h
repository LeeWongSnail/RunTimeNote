//
//  Category.h
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Runtime_Category : NSObject
- (void)method;
+ (void)method3;


- (void)getInstanceMethods;
- (void)getClassMethods;
@end
