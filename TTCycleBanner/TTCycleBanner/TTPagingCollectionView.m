//
//  TTPagingCollectionView.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTPagingCollectionView.h"

static const NSInteger kSectionNumberOfInfinateScroll = 5;

@interface TTPagingCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) BOOL shouldFireTimer;

@end

@implementation TTPagingCollectionView
@synthesize padding = _padding, marginLeft = _marginLeft, rowWidth = _rowWidth;

#pragma -mark Public Methods

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                          forIndexPath:[NSIndexPath indexPathForItem:index inSection:self.currentSection]];
}

- (void)reloadData {
    [self.collectionView reloadData];
    [self setupPageControl];

    if (self.numberOfItemsPerSection == 0) {
        return;
    }
    if (self.shouldFireTimer) {
        [self fireTimer];
    }

    [self setupCollectionViewPageEnabled];
    [self scrollToIndex:self.currentIndex animated:NO];
    self.collectionView.scrollEnabled = ![self shouldAdjustCellFitWidth];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger targetIndex;

    if (self.infiniteScrollEnabled) {
        targetIndex = index + kSectionNumberOfInfinateScroll / 2 * self.numberOfItemsPerSection;
    } else {
        if (index > self.numberOfItemsPerSection - 1 || index < 0) {
            return;
        }
        targetIndex = index;
    }
    targetIndex = MAX(targetIndex, 0);
    [self.collectionView setContentOffset:CGPointMake([self targetOffsetXAtIndex:targetIndex], 0.f) animated:animated];
    [self resumeTimer];
}

- (void)scrollToNext {
    [self scrollToIndex:self.currentIndex + 1 animated:YES];
}

- (void)scrollToPrevious {
    [self scrollToIndex:self.currentIndex - 1 animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.rowWidth == 0) {
        self.rowWidth = CGRectGetWidth(self.frame);
    }
    [self reloadData];

    if (self.shouldFireTimer) {
        [self fireTimer];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (!self.autoDisableTimerWhenDisappear || !self.autoScrollEnabled) {
        return;
    }
    if (self.window) {
        [self resumeTimer];
    } else {
        [self pauseTimer];
    }
}

#pragma -mark Life Cycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
        [self initCollectionView];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self initCollectionView];
    }

    return self;
}

- (void)dealloc{
//    NSLog(@"dealloc - %@", NSStringFromClass([self class]));
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

// 解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma -mark Private Methods

- (void)setup {
    _rowWidth = 0.f;
    _marginLeft = 0.f;
    _padding = 0.f;
    _pagingTimeInterval = 3;
    _autoDisableTimerWhenDisappear = YES;
    _adjustCellWidthToFillWhenSingleCell = YES;
    _adjustMarginRightToShowLastCellAlignRight = NO;
    _autoScrollEnabled = NO;
    _infiniteScrollEnabled = YES;
    _showPageControl = NO;
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.layout = layout;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.decelerationRate = 0.9f;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)setupPageControl {
    [self loadPageControlIfNeeded];

    if (!self.pageControl) {
        return;
    }
    self.pageControl.numberOfPages = [self numberOfItemsPerSection];
    self.pageControl.currentPage = self.currentIndex;
    CGFloat width = CGRectGetWidth(self.pageControl.frame);
    CGFloat height = CGRectGetHeight(self.pageControl.frame);
    CGFloat x = (CGRectGetWidth(self.frame) - width) / 2;
    CGFloat y = CGRectGetHeight(self.frame) - height - 10.f;
    self.pageControl.frame = CGRectMake(x, y, width, height);
    [self addSubview:self.pageControl];
}

- (void)loadPageControlIfNeeded {
    if (self.pageControl) {
        return;
    }
    if (self.loadCustomPageControl) {
        self.pageControl = self.loadCustomPageControl();
    }
    if (!self.pageControl && self.showPageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.hidesForSinglePage = YES;
        [self addSubview:pageControl];
        self.pageControl = (UIView<TTPageControl> *)pageControl;
    }
}

- (void)layoutCollectionView {
    if (!self.infiniteScrollEnabled || self.numberOfItemsPerSection <= 1) {
        return;
    }
    NSIndexPath *indexPath = self.currentIndexPath;
    if (indexPath.section != kSectionNumberOfInfinateScroll / 2) {
        [self scrollToIndex:indexPath.item animated:NO];
    }
}

- (void)fireTimer {
    if (self.numberOfItemsPerSection <= 1) {
        return;
    }
    self.shouldFireTimer = NO;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.pagingTimeInterval
                                                  target:self
                                                selector:@selector(scrollToNext)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)pauseTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.pagingTimeInterval]];
}

- (void)setupCollectionViewPageEnabled {
    self.collectionView.pagingEnabled =
    self.rowWidth == CGRectGetWidth(self.frame) && self.marginLeft == 0 && self.padding == 0;
}

#pragma -mark Calculate

- (NSInteger)idealTargetIndexWithOffsetX:(CGFloat)offsetX velocity:(CGPoint)velocity {
    if (offsetX < self.marginLeft) {
        return 0;
    }
    NSInteger index = (NSInteger)((offsetX - self.marginLeft) / (self.rowWidth + self.padding));
    // 在cell上
    if (offsetX - self.marginLeft < (self.rowWidth + self.padding) * index + self.rowWidth) {
        if (velocity.x > 0) {
            return index + 1;
        } else if (velocity.x == 0) {
            CGFloat onScrollCellStartX = [self frameXOfCellAtIndex:index];
            CGFloat nextCellStartX = [self frameXOfCellAtIndex:index + 1];
            if (offsetX - onScrollCellStartX > nextCellStartX - offsetX) {
                return index + 1;
            } else {
                return index;
            }
        } else {
            return index;
        }
    } else {
        // 在空白上
        return index + 1;
    }
}

- (NSInteger)numberOfItemsPerSection {
    return [self.collectionView numberOfItemsInSection:0];
}

// cell的实际偏移位置
- (CGFloat)frameXOfCellAtIndex:(NSInteger)index {
    return self.marginLeft + (self.rowWidth + self.padding) * index;
}

// cell的目标位置
- (CGFloat)targetOffsetXAtIndex:(NSInteger )index {
    // 不能轮播，且滚动到了最后一个cell，最后一个靠右悬停
    if (!self.infiniteScrollEnabled &&
        index == self.numberOfItemsPerSection * self.collectionView.numberOfSections - 1 &&
        self.adjustMarginRightToShowLastCellAlignRight) {
        return [self frameXOfCellAtIndex:index] - (CGRectGetWidth(self.frame) - self.rowWidth);
    }

    return [self frameXOfCellAtIndex:index] - self.marginLeft;
}

- (NSIndexPath *)currentIndexPath {
    NSInteger actualIndex = (self.collectionView.contentOffset.x + self.marginLeft) / (self.rowWidth + self.padding);

    if (self.numberOfItemsPerSection == 0) {
        return nil;
    }
    return [NSIndexPath indexPathForItem:(actualIndex % self.numberOfItemsPerSection) inSection:(actualIndex / self.numberOfItemsPerSection)];
}

#pragma -mark CollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.infiniteScrollEnabled ? kSectionNumberOfInfinateScroll : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInPagingCollectionView:)]) {
        return [self.dataSource numberOfRowsInPagingCollectionView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pagingCollectionView:cellForItemAtIndex:)]) {
        self.currentSection = indexPath.section;
        return [self.dataSource pagingCollectionView:self cellForItemAtIndex:indexPath.item];
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pagingCollectionView:willDisplayCell:atIndex:)]) {
        [self.dataSource pagingCollectionView:self willDisplayCell:cell atIndex:indexPath.item];
    }
}

#pragma -mark CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagingCollectionView:didSelectCellAtIndex:)]) {
        [self.delegate pagingCollectionView:self didSelectCellAtIndex:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.rowWidth, CGRectGetHeight(self.frame));
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(self.marginLeft, CGRectGetHeight(self.frame));
    }
    return CGSizeMake(self.padding, CGRectGetHeight(self.frame));
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForFooterInSection:(NSInteger)section {
    if (section == [collectionView numberOfSections] - 1) {
        return CGSizeMake(self.adjustMarginRightToShowLastCellAlignRight ? 0 : self.marginRight, CGRectGetHeight(self.frame));
    }
    return CGSizeZero;
}

#pragma -mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.currentIndex;

    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:self.collectionView];

    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseTimer];

    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self resumeTimer];

    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }

    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.collectionView.pagingEnabled) {
        return;
    }
    CGPoint targetLocation = ((CGPoint) * targetContentOffset);

    NSInteger targetIndex = [self idealTargetIndexWithOffsetX:targetLocation.x velocity:velocity];
    CGFloat targetOffsetX = [self targetOffsetXAtIndex:targetIndex];

    *targetContentOffset = CGPointMake(targetOffsetX, 0);

    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self layoutCollectionView];

    if ([self.delegate respondsToSelector:@selector(pagingCollectionView:didScrollToIndex:)]) {
        [self.delegate pagingCollectionView:self didScrollToIndex:self.currentIndex];
    }
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma -mark Getter

- (NSInteger)currentIndex {
    return self.currentIndexPath.item;
}

- (CGFloat)marginLeft {
    return [self shouldAdjustCellFitWidth] ? 0 : _marginLeft;
}

- (CGFloat)marginRight {
    return CGRectGetWidth(self.frame) - self.marginLeft - self.rowWidth;
}

- (CGFloat)padding {
    return [self shouldAdjustCellFitWidth] ? 0 : _padding;
}

- (CGFloat)rowWidth {
    return [self shouldAdjustCellFitWidth] ? CGRectGetWidth(self.frame) : (_rowWidth == 0 ? CGRectGetWidth(self.frame) : _rowWidth);
}

- (BOOL)shouldAdjustCellFitWidth {
    return self.adjustCellWidthToFillWhenSingleCell && self.numberOfItemsPerSection == 1;
}

- (BOOL)isVisible {
    return self.window && !CGRectIsEmpty(self.frame);
}

#pragma -mark Setter

- (void)setPadding:(CGFloat)padding {
    if (padding == _padding) {
        return;
    }
    _padding = padding;
    self.layout.minimumLineSpacing = padding;
    if ([self isVisible]) {
        [self setupCollectionViewPageEnabled];
    }
}

- (void)setMarginLeft:(CGFloat)marginLeft {
    if (marginLeft == _marginLeft) {
        return;
    }
    _marginLeft = marginLeft;
    if ([self isVisible]) {
        [self reloadData];
    }
}

- (void)setRowWidth:(CGFloat)rowWidth {
    if (rowWidth == _rowWidth) {
        return;
    }
    _rowWidth = rowWidth;
    if ([self isVisible]) {
        [self reloadData];
    }
}

- (void)setInfiniteScrollEnabled:(BOOL)infiniteScrollEnabled {
    if (_infiniteScrollEnabled == infiniteScrollEnabled) {
        return;
    }
    _infiniteScrollEnabled = infiniteScrollEnabled;
    if ([self isVisible]) {
        [self reloadData];
    }
}

- (void)setAutoScrollEnabled:(BOOL)autoScrollEnabled {
    if (_autoScrollEnabled == autoScrollEnabled) {
        return;
    }
    if (autoScrollEnabled) {
        if (!CGRectIsEmpty(self.frame) && self.superview) {
            [self fireTimer];
        } else {
            self.shouldFireTimer = YES;
        }
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
    _autoScrollEnabled = autoScrollEnabled;
}

- (void)setadjustMarginRightToShowLastCellAlignRight:(BOOL)adjustMarginRightToShowLastCellAlignRight {
    if (_adjustMarginRightToShowLastCellAlignRight == adjustMarginRightToShowLastCellAlignRight) {
        return;
    }
    _adjustMarginRightToShowLastCellAlignRight = adjustMarginRightToShowLastCellAlignRight;
    if ([self isVisible]) {
        [self reloadData];
    }
}

- (void)setShowPageControl:(BOOL)showPageControl {
    if (showPageControl == _showPageControl) {
        return;
    }
    _showPageControl = showPageControl;

    if (showPageControl && !self.pageControl) {
        [self setupPageControl];
    } else if (!showPageControl && self.pageControl) {
        _showPageControl = showPageControl;
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
    }
}

@end
