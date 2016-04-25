//
//  ViewController.m
//  图片轮播器封装
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 m14a.cn. All rights reserved.
//

#import "ViewController.h"
#import "LZInfiniteScrollView.h"

@interface ViewController () <LZInfiniteScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.创建对象,这里默认设置了一张占位图片
    LZInfiniteScrollView *scrollView = [[LZInfiniteScrollView alloc] init];
    // 2.设置图片
    scrollView.images = @[
                          [UIImage imageNamed:@"img_00"],
                          [UIImage imageNamed:@"img_01"],
                          [NSURL URLWithString:@"http://tupian.enterdesk.com/2013/mxy/12/10/15/3.jpg"],
                          [UIImage imageNamed:@"img_03"],
                          [NSURL URLWithString:@"http://pic4.nipic.com/20091215/2396136_140959028451_2.jpg"]
                        ];
    // 修改占位图片
    scrollView.placeholderImage = [UIImage imageNamed:@"imglogo-r"];
    // 修改当前显示的图片
    scrollView.currentImage = [UIImage imageNamed:@"current"];
    scrollView.otherImage = [UIImage imageNamed:@"other"];
    
    // 3.设置尺寸
    scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    // 4.设置代理
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

#pragma mark - <LZInfiniteScrollViewDelegate>
- (void)infiniteScrollView:(LZInfiniteScrollView *)infiniteScrollView didClickImageAtIndex:(NSInteger)index
{
    NSLog(@"点击了第%zd张图片", index);
}

@end
