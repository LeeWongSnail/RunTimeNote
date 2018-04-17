//
//  ClassProtocol.h
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/17.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Protocol1 <NSObject>
- (void)method1InProtocol1;
@end

@protocol Protocol2 <NSObject>
- (void)method2InProtocol2;
@end

@interface ClassProtocol : NSObject <Protocol1>
- (void)copyProtocolList;
- (void)classConformsProtocol;
- (void)addProtocol;
@end
