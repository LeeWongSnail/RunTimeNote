//
//  ViewController.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "ClassIvar.h"
#import "MetaClass.h"
#import "SuperClass.h"
#import "ClassCreate.h"
#import "ClassProperty.h"
#import "ClassProtocol.h"
#import "ClassCreateInstance.h"
#import "ClassMethod.h"
#import "ClassInfo.h"
#import "Father.h"
#import "Son.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)metaClassTest
{
    MetaClass *meta = [[MetaClass alloc] init];
//    [meta getMetaClass];
//    [meta getSonMetaClassTree];
    [meta classIsMetaClass];
}

- (void)superClassTest
{
    SuperClass *superCls = [[SuperClass alloc] init];
    [superCls getSuperClassTree];
}


- (void)fetchClassInfo
{
    ClassInfo *info = [[ClassInfo alloc] init];
    NSLog(@"%@",[info getClassName]);
    NSLog(@"=====================================");
//    [info getClassVersion];
//    [info setClassVersion];
    [info getInstanceSize];
    NSLog(@"=====================================");
    
    
}

- (void)fetchClassIvar
{
    ClassIvar *ivar = [[ClassIvar alloc] init];
    [ivar getInstanceVariable];
    ivar.name = @"Lee";
    [ivar getInstanceVariable];
    
    NSLog(@"get ivar list");
    
    [ivar getIvarList];
    
    NSLog(@"add ivar in runtime");
    [ivar addIvarDynamic];

}

- (void)classProperty
{
    ClassProperty *property = [[ClassProperty alloc] init];
//    [property getProperty];
    
//    [property copyPropertyList];
//    NSLog(@"add a property");
//    [property addPropertyDynamic];
    [property replaceClassProperty];
    
}


- (void)class_getMethod
{
    ClassMethod *m = [[ClassMethod alloc] init];
//    [m getInstanceMethod];
    
//    [m replaceMethodImplementation];
    
//    [m getMethodImplementation];
    [m addClassMethod];
}

- (void)protocol_getProtocolList
{
    ClassProtocol *p = [[ClassProtocol alloc] init];
//    [p classConformsProtocol];
    [p addProtocol];
}

- (void)createClass
{
    ClassCreate *create = [[ClassCreate alloc] init];
    [create createNewClassInRuntime];
}

- (void)clsCreateInstance
{
    ClassCreateInstance *ins = [[ClassCreateInstance alloc] init];
    [ins createInstance];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self classProperty];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
