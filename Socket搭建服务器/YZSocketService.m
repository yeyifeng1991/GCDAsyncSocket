//
//  YZSocketService.m
//  Socket搭建服务器
//
//  Created by YeYiFeng on 2018/4/4.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "YZSocketService.h"
#import "GCDAsyncSocket.h"
@interface YZSocketService ()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *serviceSocket; // 服务端socket
@property (nonatomic,strong) NSMutableArray *connectionClientSockets; // 已经链接的socket
@end
/*
 TCP编程的服务器端一般步骤是：
 
 1、创建一个socket，用函数socket()；
 
 2、设置socket属性，用函数setsockopt(); * 可选
 
 3、绑定IP地址、端口等信息到socket上，用函数bind();
 
 4、开启监听，用函数listen()；
 
 5、接收客户端上来的连接，用函数accept()；
 
 6、收发数据，用函数send()和recv()，或者read()和write();
 
 7、关闭网络连接；
 
 8、关闭监听；
 */
@implementation YZSocketService

- (NSMutableArray *)connectionClientSockets
{
    if (_connectionClientSockets == nil) {
        _connectionClientSockets = [[NSMutableArray alloc] init];
    }
    return _connectionClientSockets;
}
// 初始化创建socket
- (instancetype)init
{
    if (self = [super init]) {
        
        /**
         注意：这里的服务端socket，只负责socket(),bind()，lisence(),accept(),他的任务到底结束，只负责监听是否有客户端socket来连接
         */
        self.serviceSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}
// 连接
- (void)connected
{
    NSError *error = nil;
    // 给一个需要连接的端口，0-1024是系统的
    [self.serviceSocket acceptOnPort:3666 error:&error]; // 这个方法内部已经实现了bind listen的操作
    if (error) {
        NSLog(@"3666服务器开启失败。。。。。");
    }
    else
    {
        NSLog(@"开启成功，并开始监听");
    }
}
// 内部实现accept 过程
// 有客户端连接该服务器进行会话 Mac 终端下调用telnet IP port进行与服务器的链接，如果链接上了就会调用这个方法
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"服务器%@",sock);
    NSLog(@"客户端%@ IP:%@,%d 连接成功",newSocket,newSocket.connectedHost,newSocket.connectedPort);
    // 1.如果不用全局变量存取，直接就会推出
    [self.connectionClientSockets addObject:newSocket];
    
    // 2.连接完成之后进行 客户端的sock进行监听状态
    [newSocket readDataWithTimeout:-1 tag:0];
    
    // 3.write目的就是发送数据 有人连接到服务端之后就进行一系列响应
    NSMutableString *options = [NSMutableString string];
    [options appendString:@"欢迎来到洗浴天堂 请输入下面的数字选择服务\n"];
    [options appendString:@"[0]cc来了\n"];
    [options appendString:@"[1]我要288的服务\n"];
    [options appendString:@"[2]我带小明一起过来了\n"];
    [options appendString:@"[3]我需要特殊的服务\n"];
    [options appendString:@"[4]退出\n"];
    // 服务端发送数据
    [newSocket writeData:[options dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];// 收发数据中必须注意是添加 [sock readDataWithTimeout:-1 tag:0];否则接收不到数据，并且这个函数在数据返回就必须调用一次，让他一直循环下去。
    

    
}

// 内部实现read 和 write 操作
/**
 这个是服务端的代码，这里的write就是服务器发送数据，而且这里的发送socket对象也是连接的客户端socket
 当有连接好的客户端之后发送消息给服务器，就能通过该方法受到消息，在通过消息，服务端在进行write数据给客户端展示
 */
- (void)socket:(GCDAsyncSocket *)clientSock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    switch ([receiveStr integerValue]) {
        case 0:
            [self writeDataWithSocket:clientSock message:@"按摩188，这边请\n"];
            break;
        case 1:
            [self writeDataWithSocket:clientSock message:@"洗脚288，这边请\n"];
            break;
        case 2:
            [self writeDataWithSocket:clientSock message:@"黄哥你又来了啊，还带人过来，来来来\n"];
            break;
        case 3:
            [self writeDataWithSocket:clientSock message:@"新来的头牌，大冲包你满意\n"];
            break;
        case 4:
            [self exitSocket:clientSock];
            break;
            
        default:
            [self writeDataWithSocket:clientSock message:@"没有您要的服务\n"];
            break;
    }
    [clientSock readDataWithTimeout:-1 tag:0];
}

/**
 断开链接调用
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"失去连接了");
}


/**
 发送数据给客户端
 */
- (void)writeDataWithSocket:(GCDAsyncSocket *)socket message:(NSString *)msg
{
    [socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}


/**
 断开连接，会调用Connection closed by foreign host.
 并且发送数据到客户端
 最终从服务端的数组中移除，释放内存，断开socket
 
 @param socket 需要断开的客户端socket
 */
- (void)exitSocket:(GCDAsyncSocket *)socket
{
    [self writeDataWithSocket:socket message:@"离开东莞\n"];
    [self.connectionClientSockets removeObject:socket]; // 断开连接是调用
    NSLog(@"currentSocket:%ld",self.connectionClientSockets.count);
}

@end
