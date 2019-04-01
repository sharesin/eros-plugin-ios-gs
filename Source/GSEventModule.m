//
//  GSEventModule.m
//  WeexEros
//
//  Created by caas on 2019/3/30.
//  Copyright © 2019 benmu. All rights reserved.
//

#import "GSEventModule.h"

#import <WeexPluginLoader/WeexPluginLoader.h>
// 第一个参数为暴露给 js 端 Module 的名字，
// 第二个参数为你 Module 的类名
WX_PlUGIN_EXPORT_MODULE(gsEventModule, GSEventModule)

@implementation GSEventModule

@synthesize weexInstance;
// 将方法暴露出去
WX_EXPORT_METHOD(@selector(sayHello:))

- (void)sayHello:(NSString *)name {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您好：%@",name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

@end
