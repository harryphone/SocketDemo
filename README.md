# SocketDemo
### 前言
我是培训班出身的，我至今还记得老师关于socket的一句话：http是短连接，socket是长连接。我估计是老师对我们这群菜鸟不报什么希望，所以才这么说的，而我直到前一阵子还一直当真理相信着。。。

最近工作上接触了socket，看了很多文档，渐渐的对socket有了一个清晰的了解，下面附上2个比较好的连接：
- https://cainluo.github.io/14986613643920.html
- http://www.cocoachina.com/ios/20180228/22385.html
你还可以看文章中的链接，也是好文章。

在这个充斥着互联网的世界，单机的APP已经渐渐销声匿迹，网络编程成为了一个程序员的基本素养。在此，我推荐2本我准备要看的书给和我一样非科班出身的程序猿：《计算机网络-自顶向下方法》，还有就是《TCP-IP详解》的3卷。这2本有先后顺序，先读第一本，在理解第二本会好很多。书单链接：
- 链接: https://pan.baidu.com/s/1cj4tJX0qG0yDXLI6Gy6mLA 密码: 1y8i
- 链接: https://pan.baidu.com/s/1uZcREgN08tU1Sd2G8kRP8g 密码: xw2q
> 与君共勉

### socket框架

我用的是`GCDAsyncSocket`，毕竟对c的api一脸懵逼的，所以找一个成名的、封装好、面向对象的socket框架，`GCDAsyncSocket`的用法我就不多说了，自己可以百度。
![image.png](https://upload-images.jianshu.io/upload_images/4038106-6bb84957e285b06b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
大家可以去https://github.com/robbiehanson/CocoaAsyncSocket下载，当然，也可以下我的demo直接拿。注意到图片里的udp了么，我们用的是tcp协议的，后面可以带大家看3次握手和4次分手的过程。

### socket客户端

![image.png](https://upload-images.jianshu.io/upload_images/4038106-47b06ca934eb3bc4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先在storyboard里拖个小界面，在`ViewController`里关联下，接着声明一个`GCDAsyncSocket`的对象，如果不持有属性的话，对象释放的时候会自动断开连接。
``` objc
@property (nonatomic, strong) GCDAsyncSocket *socket;
```
创建socket，这边`GCDAsyncSocket`用法详解就不说了，自己百度。
``` objc
_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
```
给button加个点击事件，里面有连接服务器，和发送数据事件的切换。值得注意的是，每个发送的消息必须要有特定字符分隔开，不然后台无法识别数据是否已经发送完成，常用的是换行符。`[GCDAsyncSocket CRLFData]`框架里已经封装给我们了。所以__每次发送的数据都要拼接上`[GCDAsyncSocket CRLFData]`__
``` objc
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
```
接着你可以把`GCDAsyncSocketDelegate`中的所有代理都拷贝过来，方便自己学习，你可以在所有代理方法中加上这句，这样就很方便就看到那些代理方法调用了。
``` objc
NSLog(@"%s,%d", __func__, __LINE__);
```
下面是代理方法的书写

首先是连上服务器的回调，连上的时候把button的事件改成发送，然后监听服务器的数据。
``` objc
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
NSLog(@"%s,%d", __func__, __LINE__);
self.button.tag = SendType_SendMessage;
[self.button setTitle:@"发送" forState:UIControlStateNormal];  
[self.socket readDataWithTimeout:-1 tag:0];
}
```
然后是数据监听的回调，将`NSData `转成`NSString`，并在控制台打印
``` objc
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
NSLog(@"%s,%d", __func__, __LINE__);
NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
[self.socket readDataWithTimeout:-1 tag:0];
}
```
最后是断开连接的回调，把button调回连接状态。
``` objc
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
NSLog(@"%s,%d", __func__, __LINE__);
self.button.tag = SendType_Connent;
[self.button setTitle:@"连接" forState:UIControlStateNormal];
}
```
一个简单demo就完成了，写完了当然要测试，在终端用netcat工具实现简单的服务器聊天功能，命令是`nc -lk 端口`
![image.png](https://upload-images.jianshu.io/upload_images/4038106-8061260b9ba3f317.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
当光标移到下面去的时候，表示服务器已经开始监听啦。运行demo，如果是模拟器，那么ip写上127.0.0.1的回环地址，如果是真机的话，写上电脑的ip地址就行。端口的话就和服务器监听的一致就行。输入ip后，点击连接，如果成功的话，控制台会打印成功的回调。

![image.png](https://upload-images.jianshu.io/upload_images/4038106-b77adffd5541ceeb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
接着在输入框里可以输入内容聊天了，比如我输入一个hello
![image.png](https://upload-images.jianshu.io/upload_images/4038106-407bbf4152833cd4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
控制台便会跳出来一个hello，控制台也会打印`didWriteDataWithTag`的回调。如果你在终端输入内容（回车键发送），那么你也会收到信息
![image.png](https://upload-images.jianshu.io/upload_images/4038106-8b5dcd502b6171d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

你关掉终端或者按`ctrl+c`便能关掉服务端，会收到`socketDidDisconnect`的回调。

客户端的小demo就完成啦。

### socket服务端

手机当服务器，有没有觉得很有成就感？

服务端的demo很多内容和上面一样，具体可以看demo中的下载，着重说下不同点。

首先是socket的创建，这个socket对象只负责端口的监听，并不负责data的传送。一旦这个socket断开了连接，其他客户端就再也连不上这台服务器了。
``` objc
self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//监听某个端口 等待被链接 0-25535  1000以内是系统预留端口
[self.serverSocket acceptOnPort:5555 error:nil];
```
一旦有客户端有连接的话，便会回调这个方法：
``` objc
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
NSLog(@"%s,%d", __func__, __LINE__);
//把链接进来的socket对象 持有住不被自动释放 释放掉的话 链接会自动断开
[self.sockets addObject:newSocket];
[newSocket readDataWithTimeout:-1 tag:0];
}
```
这里会有一个`newSocket`的参数，这个`newSocket`对象表示是与当前客户端的连接，作用是和当前客户端相互传送data的，`self.serverSocket`的代理对象会赋值给这个`newSocket`，所以`newSocket`也会走你写的代理方法。当然，可能会有好几个客户端接进来，所以你需要用一个数组来管理，创建数组我就不展示了。

所以走`didReadData`回调的是你`sockets`数组中的某一个，并不是一开始创建的`self.serverSocket`。我为了识别是哪一个客户端给我发的消失，创建了一个对象指向它：
``` objc
@property (nonatomic, weak)GCDAsyncSocket *currentSocket;

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
NSLog(@"%s,%d", __func__, __LINE__);
NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
self.currentSocket = sock;
[sock readDataWithTimeout:-1 tag:0];
}
```
当有消息进来的时候，我指向那个客户端，方便给他回消息（暂时不考虑并发的情况，只是demo嘛）

客户端断开连接的时候，socket记得从数组中移除。

接下来就是测试啦，先运行demo，然后用终端当客户端，命令是`nc 127.0.0.1 5555`，host和port可以根据自己的实际情况自己改，你可以多开几个终端，同时连上服务器。
![image.png](https://upload-images.jianshu.io/upload_images/4038106-cfb32390eaf06dad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/4038106-7f19fe47b1f5e023.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我连了3个，就有3次回调，数组也有3个。data传送你们自己试吧。

### TCP的3次握手和4次分手

我们平时用的抓包工具是Charles，但这个一般用来抓http协议请求的，他帮我们做了很多处理，所以很多细节都看不到，对于socket来说，这工具就不够看了。推荐一个新工具--Wireshark。
![image.png](https://upload-images.jianshu.io/upload_images/4038106-14a1c689babc5727.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
工具的使用自己百度搜吧，我也用的很生疏。

接下来我模拟器运行服务端，真机运行客户端，模拟器ip是10.10.2.47，真机ip是10.10.2.50
![image.png](https://upload-images.jianshu.io/upload_images/4038106-c50a2166ea57cf7b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
当我点击连接的时候出现了4条数据，前面3条是不是很熟悉，就是一直念在口中的3次握手，第4条数据是滑动窗口的概念。
![image.png](https://upload-images.jianshu.io/upload_images/4038106-3192ee706beb0110.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


然后我客户端发送了2条后，服务器也发送了1条。由图可以得到每条消息要2个数据包，来回各一次。
![image.png](https://upload-images.jianshu.io/upload_images/4038106-6262e76590af1806.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
最后断开连接，是不是很完美的4次分手？

### 结语
附上代码地址：https://github.com/harryphone/SocketDemo
用Wireshark可以分解出一次完整的http请求，下次有机会用socket封装出一个http请求，甚至是https请求。
