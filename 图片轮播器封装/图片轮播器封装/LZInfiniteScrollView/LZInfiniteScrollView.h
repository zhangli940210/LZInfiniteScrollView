//
//  LZInfiniteScrollView.h
//  图片轮播器封装
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 m14a.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LZInfiniteScrollView;

@protocol LZInfiniteScrollViewDelegate <NSObject>

@optional
- (void)infiniteScrollView:(LZInfiniteScrollView *)infiniteScrollView didClickImageAtIndex:(NSInteger)index;

@end

@interface LZInfiniteScrollView : UIView

/** 需要显示的图片数据(要求里面存放UIImage\NSURL对象) */
@property (nonatomic, strong) NSArray *images;
/** 下载远程图片时的占位图片 */
@property (nonatomic, strong) UIImage *placeholderImage;
/** 当前下标正在显示的图片 */
@property (nonatomic, strong) UIImage *currentImage;
/** 当前下标没有显示的图片 */
@property (nonatomic, strong) UIImage *otherImage;
/** pageControl*/
@property (nonatomic, assign) CGRect pageControlFrame;
/** 用来监听框架内部事件的代理 */
@property (nonatomic, weak) id<LZInfiniteScrollViewDelegate> delegate;
@end
