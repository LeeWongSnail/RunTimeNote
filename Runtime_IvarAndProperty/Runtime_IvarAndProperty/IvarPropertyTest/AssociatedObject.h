//
//  AssociatedObject.h
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssociatedObject : UIView
- (void)setTapActionWithBlock:(void (^)(void))block;
@end
