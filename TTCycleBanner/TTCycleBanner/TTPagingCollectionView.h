//
//  TTPagingCollectionView.h
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TTPagingCollectionView;

@protocol TTPageControl <NSObject>
@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@end

@protocol TTPagingCollectionViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInPagingCollectionView:(TTPagingCollectionView *)collectionView;
- (UICollectionViewCell *)pagingCollectionView:(TTPagingCollectionView *)collectionView cellForItemAtIndex:(NSInteger)index;

@end

@protocol TTPagingCollectionViewDelegate <UIScrollViewDelegate>

@optional
- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didSelectCellAtIndex:(NSInteger)index;
- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didScrollToIndex:(NSInteger)index;

@end

@interface TTPagingCollectionView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/**
 nil if showPageControl is NO
 */
@property (nonatomic, strong)  UIView<TTPageControl> * _Nullable pageControl;

/**
 分页圆点 default is NO
 */
@property (nonatomic, assign) BOOL showPageControl;

/**
 自定义pageControl
 */
@property (nonatomic, strong) UIView<TTPageControl> *(^loadCustomPageControl)(void);

/**
 自动轮播 default is NO
 */
@property (nonatomic, assign) BOOL autoScrollEnabled;

/**
 无限轮播 default is YES
 */
@property (nonatomic, assign) BOOL infiniteScrollEnabled;

/**
 翻页间隔 default is 3
 */
@property (nonatomic, assign) NSTimeInterval pagingTimeInterval;

/**
 消失时自动停止滚动，展示时自动开启滚动 default is YES
 */
@property (nonatomic, assign) BOOL autoDisableTimerWhenDisappear;

/**
 单个cell自适应宽度 default is YES
 */
@property (nonatomic, assign) BOOL adjustCellWidthToFillWhenSingleCell;

/**
 最后一个cell是否贴着边框 default is NO
 */
@property (nonatomic, assign) BOOL adjustMarginRightToShowLastCellAlignRight;

/**
 cell宽度 default same as self
 */
@property (nonatomic, assign) CGFloat rowWidth;

/**
 cell间距 default is 0
 */
@property (nonatomic, assign) CGFloat padding;

/**
 视图左边距 default is 0
 */
@property (nonatomic, assign) CGFloat marginLeft;

/**
 当前位置
 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, weak) id<TTPagingCollectionViewDataSource> dataSource;
@property (nonatomic, weak) id<TTPagingCollectionViewDelegate> delegate;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

- (void)scrollToNext;
- (void)scrollToPrevious;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
