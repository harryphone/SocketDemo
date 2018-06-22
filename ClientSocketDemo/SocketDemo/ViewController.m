//
//  ViewController.m
//  SocketDemo
//
//  Created by HarryHuang on 2018/6/20.
//  Copyright © 2018年 HarryHuang. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

typedef NS_ENUM(NSInteger, SendType) {
    SendType_Connent,
    SendType_SendMessage,
};

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

//终端服务器命令   nc -lk 端口

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)sendAction{
    if (self.button.tag == SendType_Connent) {
        NSArray *arr = [self.textField.text componentsSeparatedByString:@":"];
        NSError *error;
        [self.socket connectToHost:arr.firstObject onPort:[arr.lastObject intValue] withTimeout:15 error:&error];
        if (error) {
            NSLog(@"%@, %d", error, __LINE__);
        }
    }else {
        
        NSMutableData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
        [data appendData: [GCDAsyncSocket CRLFData]];
      
        [self.socket writeData:data withTimeout:30 tag:0];
    }
}


- (GCDAsyncSocket *)socket{
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

#pragma mark - GCDAsyncSocketDelegate

//- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock{
//
//}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"%s,%d", __func__, __LINE__);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s,%d", __func__, __LINE__);
    self.button.tag = SendType_SendMessage;
    [self.button setTitle:@"发送" forState:UIControlStateNormal];
    
    [self.socket readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"%s,%d", __func__, __LINE__);
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self.socket readDataWithTimeout:-1 tag:0];
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
    self.button.tag = SendType_Connent;
    [self.button setTitle:@"连接" forState:UIControlStateNormal];
}


- (void)socketDidSecure:(GCDAsyncSocket *)sock{
    NSLog(@"%s,%d", __func__, __LINE__);
}


- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    NSLog(@"%s,%d", __func__, __LINE__);
}

@end
