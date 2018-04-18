//
//  Objc_ClassList.h
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Objc_ClassList : NSObject
- (void)getClassList;
- (void)copyClassList;
- (void)getSpecificClass;
- (void)getMetaClass;
@end
