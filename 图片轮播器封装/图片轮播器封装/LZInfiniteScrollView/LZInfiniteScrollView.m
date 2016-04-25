//
//  LZInfiniteScrollView.m
//  图片轮播器封装
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 m14a.cn. All rights reserved.
//

#import "LZInfiniteScrollView.h"
#import "UIImageView+WebCache.h"

/************** LZImageCell begin **************/
#pragma mark - LZImageCell begin
@interface LZImageCell : UICollectionViewCell
/** 存放图片的图片框*/
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation LZImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end

/************** XMGImageCell end **************/

/************** LZInfiniteScrollView begin **************/
#pragma mark - LZInfiniteScrollView begin
@interface LZInfiniteScrollView ()  <UICollectionViewDataSource, UICollectionViewDelegate>

/** 定时器 */
@property (nonatomic, weak) NSTimer *timer;
/** 用来显示图片的collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;
/** 显示下标的图片 */
@property (weak, nonatomic) UIPageControl *pageControl;
@end


@implementation LZInfiniteScrollView
/** 设置的格子数 */
static NSInteger LZItemCount = 20;
/** 标识 */
static NSString * const LZImageCellId = @"LZImageCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 流水布局
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 设置滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 设置行间距为0
        layout.minimumLineSpacing = 0;
        
        // UICollectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 设置数据源
        collectionView.dataSource = self;
        // 设置代理
        collectionView.delegate = self;
        // 设置分页功能
        collectionView.pagingEnabled = YES;
        // 隐藏水平方向和垂直方向滚动条
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        // 注册方法
        [collectionView registerClass:[LZImageCell class] forCellWithReuseIdentifier:LZImageCellId];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        // 默认属性值
        self.placeholderImage = [UIImage imageNamed:@"LZInfiniteScrollView.bundle/placeholderImage"];
        
        // 创建UIPageControl对象
        UIPageControl *pageControl = [[UIPageControl alloc] init];

        // 单页时自动隐藏pageControl
        pageControl.hidesForSinglePage = YES;
        // 设置页码图片
        [pageControl setValue:[UIImage imageNamed:@"LZInfiniteScrollView.bundle/current"] forKeyPath:@"_currentPageImage"];
        [pageControl setValue:[UIImage imageNamed:@"LZInfiniteScrollView.bundle/other"] forKeyPath:@"_pageImage"];
        // 添加进去
        [self addSubview:pageControl];
        // 赋值
        self.pageControl = pageControl;
        
    }
    return self;
}
// 设置位置
- (void)setPageControlFrame:(CGRect)pageControlFrame
{
    self.pageControl.frame = pageControlFrame;
}

// 重写setter方法
- (void)setCurrentImage:(UIImage *)currentImage
{
    _currentImage = currentImage;
    [self.pageControl setValue:currentImage forKeyPath:@"_currentPageImage"];
}
// 重写setter方法
- (void)setOtherImage:(UIImage *)otherImage
{
    _otherImage = otherImage;
    [self.pageControl setValue:otherImage forKeyPath:@"_pageImage"];
}

// 重写setter方法
- (void)setImages:(NSArray *)images
{
    _images = images;
    // 设置默认显示最中间的图片
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(LZItemCount * images.count) / 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    });
    
    // 设置总页数
    self.pageControl.numberOfPages = images.count;
    // 开启定时器
    [self startTimer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // collectionView
    self.collectionView.frame = self.bounds;
    // layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = self.bounds.size;
    
    // 设置
    self.pageControl.frame = CGRectMake(self.bounds.size.width * 0.6, self.bounds.size.height * 0.8, 100, 37);
//    self.pageControl.frame = self.pageControlFrame;
}

// 下一页
- (void)nextPage
{
    // 拿到现在的偏移量
    CGPoint offset = self.collectionView.contentOffset;
    // 在这基础上加一张图片的宽度
    offset.x += self.collectionView.frame.size.width;
    // 设置偏移量,滚动
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - 定时器
// 开启定时器
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
// 停止定时器
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - <UICollectionViewDataSource>
// 有多少个格子
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return LZItemCount * self.images.count;
}
// 每个格子显示什么内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 去缓存获取cell
    LZImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LZImageCellId forIndexPath:indexPath];
    // 获取数据
    id data = self.images[indexPath.item % self.images.count];
    if ([data isKindOfClass:[UIImage class]]) {
        cell.imageView.image = data;
    } else if ([data isKindOfClass:[NSURL class]]) {
        [cell.imageView sd_setImageWithURL:data placeholderImage:self.placeholderImage];
    }
    // 返回cell
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didClickImageAtIndex:)]) {
        [self.delegate infiniteScrollView:self didClickImageAtIndex:(indexPath.item % self.images.count)];
    }
}
// 将要开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器
    [self stopTimer];
}
// 结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 开启定时器
    [self startTimer];
}

/**
 *  scrollView滚动完毕的时候调用（通过setContentOffset:animated:滚动）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 重置cell的位置到中间
    [self resetPosition];
}

/**
 *  scrollView滚动完毕的时候调用（人为拖拽滚动）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 重置cell的位置到中间
    [self resetPosition];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5);
    self.pageControl.currentPage = page % self.images.count;
}

#pragma mark - 重置cell的位置到中间
/**
 *  重置cell的位置到中间
 */
- (void)resetPosition
{
    // 滚动完毕时，自动显示最中间的cell
    // 旧的格子的下标
    NSInteger oldItem = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    // 新的格子的下标
    NSInteger newItem = (LZItemCount * self.images.count / 2) + (oldItem % self.images.count);
    
//    NSLog(@"oldItem = %zd, newItem = %zd", oldItem, newItem);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newItem inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

/************** XMGInfiniteScrollView end **************/
@end
