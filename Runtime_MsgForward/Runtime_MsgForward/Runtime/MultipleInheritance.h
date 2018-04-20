//
//  MultipleInheritance.h
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Father.h"

/**
 这个类继承自Father 但是 我还想让这个类继承自SomeClass
 */
@interface MultipleInheritance : Father

- (void)eat;

@end
