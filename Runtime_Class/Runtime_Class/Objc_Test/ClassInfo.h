//
//  ClassInfo.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassInfo : NSObject
- (NSString *)getClassName;
- (long)getClassVersion;
- (void)setClassVersion;
- (long)getInstanceSize;
@end
