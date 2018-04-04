//
//  main.m
//  Socket搭建服务器
//
//  Created by YeYiFeng on 2018/4/4.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZSocketService.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {

        YZSocketService * service = [[YZSocketService alloc]init];
        [service connected];
        [[NSRunLoop mainRunLoop]run];
        
    }
    return 0;
}
