//
//  ViewController.m
//  NSThreadDemo
//
//  Created by 草帽~小子 on 2019/5/7.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) int ticketSurplusCount;
@property (nonatomic, strong) NSThread *ticketSaleWindow1;
@property (nonatomic, strong) NSThread *ticketSaleWindow2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 300)];
    [self.view addSubview:self.imageView];
    
    //[self pthreadInit];
    
    [self initTicketStatusNotSave];
    
    // Do any additional setup after loading the view.
}

- (void)pthreadInit {
    //1.创建
    pthread_t thread;
    //2.开启线程，执行任务
    pthread_create(&thread, NULL, run, NULL);
    //3.设置子线程的状态设置为 detached，该线程运行结束后会自动释放所有资源
    pthread_detach(thread);
    pthread_join(thread, jump(nil));

#pragma pthread 其他相关方法
//    pthread_create() 创建一个线程
//    pthread_exit() 终止当前线程
//    pthread_cancel() 中断另外一个线程的运行
//    pthread_join() 阻塞当前的线程，直到另外一个线程运行结束
//    pthread_attr_init() 初始化线程的属性
//    pthread_attr_setdetachstate() 设置脱离状态的属性（决定这个线程在终止时是否可以被结合）
//    pthread_attr_getdetachstate() 获取脱离状态的属性
//    pthread_attr_destroy() 删除线程的属性
//    pthread_kill() 向线程发送一个信号
}

void *run (void *para) {
    NSLog(@"%@", [NSThread currentThread]);
    return NULL;
}

void *jump (void *para) {
    NSLog(@"2");
    return NULL;
}

- (void)nsthread {
    //一、1.先创建再启动
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(eat) object:nil];
    //2.启动
    [thread start];
    
    //二、创建后自动启动
    [NSThread detachNewThreadSelector:@selector(eat) toTarget:self withObject:nil];
    
    //三、隐式创建并启动线程
    [self performSelectorInBackground:@selector(eat) withObject:nil];
//    // 获得主线程
//    + (NSThread *)mainThread;
//
//    // 判断是否为主线程(对象方法)
//    - (BOOL)isMainThread;
//
//    // 判断是否为主线程(类方法)
//    + (BOOL)isMainThread;
//
//    // 获得当前线程
//    NSThread *current = [NSThread currentThread];
//
//    // 线程的名字——setter方法
//    - (void)setName:(NSString *)n;
//
//    // 线程的名字——getter方法
//    - (NSString *)name;
//
    
}

- (void)eat {
    NSLog(@"%@", [NSThread currentThread]);
}

/**
 * 创建一个线程下载图片
 */
- (void)downloadImageOnSubThread {
    // 在创建的子线程中调用downloadImage下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}

- (void)downloadImage {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    
    // 1. 获取图片 imageUrl
    NSURL *imageUrl = [NSURL URLWithString:@"https://ysc-demo-1254961422.file.myqcloud.com/YSC-phread-NSThread-demo-icon.jpg"];
    
    // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    // 通过二进制 data 创建 image
    UIImage *image = [UIImage imageWithData:imageData];
    
    // 3. 回到主线程进行图片赋值和界面刷新
    [self performSelectorOnMainThread:@selector(refreshOnMainThread:) withObject:image waitUntilDone:YES];
}

/**
 * 回到主线程进行图片赋值和界面刷新
 */
- (void)refreshOnMainThread:(UIImage *)image {
    NSLog(@"current thread -- %@", [NSThread currentThread]);
    
    // 赋值图片到imageview
    self.imageView.image = image;
}

/**
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    // 1. 设置剩余火车票为 50
    self.ticketSurplusCount = 50;
    
    // 2. 设置北京火车票售卖窗口的线程
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    //安全
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow1.name = @"北京火车票售票窗口";
    
    // 3. 设置上海火车票售卖窗口的线程
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketNotSafe) object:nil];
    //安全
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow2.name = @"上海火车票售票窗口";
    
    // 4. 开始售卖火车票
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
    
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        //如果还有票，继续售卖
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
            [NSThread sleepForTimeInterval:0.2];
        }
        //如果已卖完，关闭售票窗口
        else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 互斥锁
        @synchronized (self) {
            //如果还有票，继续售卖
            if (self.ticketSurplusCount > 0) {
                self.ticketSurplusCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                NSLog(@"所有火车票均已售完");
                break;
            }
        }
    }
}


@end
