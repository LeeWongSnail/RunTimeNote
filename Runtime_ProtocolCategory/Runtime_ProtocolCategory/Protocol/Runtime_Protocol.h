//
//  Protocol.h
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RuntimeProtocol1

@property (nonatomic, strong) NSString *name;

- (void)instanceMethod;

+ (void)classMethod;
@end


@protocol RuntimeProtocol2 <RuntimeProtocol1>

@property (nonatomic, assign) NSInteger age;

- (void)instanceMethod1;

+ (void)classMethod1;
@end

@interface Runtime_Protocol : NSObject <RuntimeProtocol1,RuntimeProtocol2>
@property (nonatomic, strong) NSString *name;


- (void)getProtocol;
- (void)getProtocolList;
- (void)addProtocolDurRuntime;

- (void)copyProtocolPropertyList;
- (void)getSpecificProperty;

- (void)protocolConformProtocol;
@end
