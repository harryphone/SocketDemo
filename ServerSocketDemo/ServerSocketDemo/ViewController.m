//
//  ViewController.m
//  ServerSocketDemo
//
//  Created by HarryHuang on 2018/6/21.
//  Copyright © 2018年 HarryHuang. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate>

@property (nonatomic, strong)GCDAsyncSocket *serverSocket;
@property (nonatomic, weak)GCDAsyncSocket *currentSocket;
@property (nonatomic, strong)NSMutableArray *sockets;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

//nc 127.0.0.1 5555

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sockets = [NSMutableArray array];
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //监听某个端口 等待被链接 0-25535  1000以内是系统预留端口
    [self.serverSocket acceptOnPort:5555 error:nil];
}

- (IBAction)sendAction:(id)sender {
    NSMutableData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
    [data appendData:[GCDAsyncSocket CRLFData]];
    [self.currentSocket writeData:data withTimeout:30 tag:0];
}

- (IBAction)disconnentAction:(id)sender {
    //一旦断开连接，无法再连上服务器
//    [self.serverSocket disconnect];
    [self.currentSocket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate

//- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock{
//
//}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"%s,%d", __func__, __LINE__);
    //把链接进来的socket对象 持有住不被自动释放 释放掉的话 链接会自动断开
    [self.sockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s,%d", __func__, __LINE__);
   
    
    [sock readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"%s,%d", __func__, __LINE__);
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    self.currentSocket = sock;
    [sock readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"%s,%d", __func__, __LINE__);
}



- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"%s,%d", __func__, __LINE__);
    return 10;
}


- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"%s,%d", __func__, __LINE__);
    return 10;
}


- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%s,%d", __func__, __LINE__);
    
    [self.sockets removeObject:sock];
   
    
}


- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    NSLog(@"%s,%d", __func__, __LINE__);
}


@end
