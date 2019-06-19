//
//  ViewController.m
//  TTCycleBanner
//
//  Created by rollingstoneW on 2019/6/18.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "ViewController.h"
#import "TTCycleBanner.h"
#import "TTCombineDelegateProxy.h"

@interface TestPagingCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *textLabel;
@end
@implementation TestPagingCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [self randomColor];
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

- (UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 64 / 256.0 );
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

@end

@interface ViewController ()  <TTCycleBannerDelegate, TTPagingCollectionViewDataSource>

@property (nonatomic, strong) TTPagingCollectionView *pagingView;
@property (nonatomic, strong) TTCombineDelegateProxy *delegateProxy;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataArray = @[@"轮播图", @"轮播组件不循环", @"轮播组件单张自动适配宽度", @"轮播组件", @"页面消失自动关闭轮播，展示自动开启轮播"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView reloadData];

    [self showCycleBanner];

    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"第0个" style:UIBarButtonItemStyleDone target:self action:@selector(scrollToFirst)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"前一个" style:UIBarButtonItemStyleDone target:self action:@selector(scrollToPrevious)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"后一个" style:UIBarButtonItemStyleDone target:self action:@selector(scrollToNext)];
    self.navigationItem.rightBarButtonItems = @[item1, item2, item3];
}

- (void)setPagingView:(TTPagingCollectionView *)pagingView {
    _pagingView = pagingView;
    pagingView.delegate = self;
    self.tableView.tableHeaderView = pagingView;
}

- (void)showCycleBanner {
    TTCycleBanner *cycleBanner = [[TTCycleBanner alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    NSArray *urls = @[@"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3300305952,1328708913&fm=27&gp=0.jpg", @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2153937626,1074119156&fm=27&gp=0.jpg", @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1905452358,4132262221&fm=27&gp=0.jpg"];
    NSAttributedString *prettyContent = [[NSAttributedString alloc] initWithString:@"标题3" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor redColor]}];
    NSArray *titles = @[@"这是一个很长很长很长很长很长很长很长很长的标题", @"", prettyContent];
    NSArray *images = @[[UIImage imageNamed:@"beach"]];
    cycleBanner.backgroundColor = [UIColor lightGrayColor];
    cycleBanner.items = [TTCycleBannerItem itemsWithImageUrls:urls titlesOrPretty:titles localImages:images];
    self.pagingView = cycleBanner;
}

- (void)showPagingCollectionView1 {
    TTPagingCollectionView *pagingCollectionView = [[TTPagingCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    pagingCollectionView.infiniteScrollEnabled = NO;
    pagingCollectionView.autoScrollEnabled = NO;
    pagingCollectionView.marginLeft = 20;
    pagingCollectionView.rowWidth = self.view.bounds.size.width - pagingCollectionView.marginLeft * 2;
    pagingCollectionView.padding = 10;
    pagingCollectionView.adjustMarginRightToShowLastCellAlignRight = YES;
    [pagingCollectionView registerClass:[TestPagingCollectionCell class] forCellReuseIdentifier:@"cell"];
    pagingCollectionView.dataSource = self;
    self.pagingView = pagingCollectionView;
}

- (void)showPagingCollectionView2 {
    TTPagingCollectionView *pagingCollectionView = [[TTPagingCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    pagingCollectionView.marginLeft = 20;
    pagingCollectionView.rowWidth = self.view.bounds.size.width - pagingCollectionView.marginLeft * 2;
    pagingCollectionView.padding = 10;
    pagingCollectionView.adjustCellWidthToFillWhenSingleCell = YES;
    pagingCollectionView.tag = 100;
    [pagingCollectionView registerClass:[TestPagingCollectionCell class] forCellReuseIdentifier:@"cell"];
    pagingCollectionView.dataSource = self;
    self.pagingView = pagingCollectionView;
}

- (void)showPagingCollectionView3 {
    TTPagingCollectionView *pagingCollectionView = [[TTPagingCollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    pagingCollectionView.marginLeft = 20;
    pagingCollectionView.rowWidth = self.view.bounds.size.width - pagingCollectionView.marginLeft * 2;
    pagingCollectionView.padding = 10;
    [pagingCollectionView registerClass:[TestPagingCollectionCell class] forCellReuseIdentifier:@"cell"];
    pagingCollectionView.dataSource = self;
    pagingCollectionView.delegate = self;
    self.tableView.tableHeaderView = pagingCollectionView;
    self.pagingView = pagingCollectionView;
}

- (void)scrollToPrevious {
    [self.pagingView scrollToPrevious];
}

- (void)scrollToNext {
    [self.pagingView scrollToNext];
}

- (void)scrollToFirst {
    [self.pagingView scrollToIndex:0 animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = selectedView;
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showCycleBanner];
    } else if (indexPath.row == 1) {
        [self showPagingCollectionView1];
    } else if (indexPath.row == 2) {
        [self showPagingCollectionView2];
    } else if (indexPath.row == 3) {
        [self showPagingCollectionView3];
    } else if (indexPath.row == 4) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor whiteColor];
        vc.title = @"返回自动开启轮播图";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfRowsInPagingCollectionView:(TTPagingCollectionView *)collectionView {
    return collectionView.tag == 100 ? 1 : 3;
}

- (UICollectionViewCell *)pagingCollectionView:(TTPagingCollectionView *)collectionView cellForItemAtIndex:(NSInteger)index {
    TestPagingCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndex:index];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", index];
    return cell;
}

- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didScrollToIndex:(NSInteger)index {
    NSLog(@"滚动到第 %ld 个", index);
}

- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didSelectCellAtIndex:(NSInteger)index {
    NSLog(@"点击了第 %ld 个", index);
}

- (void)cycleBanner:(TTCycleBanner *)cycleBanner didScrollToIndex:(NSInteger)index {
    NSLog(@"滚动到第 %ld 个", index);
}

- (void)cycleBanner:(TTCycleBanner *)cycleBanner didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了第 %ld 个", index);
}

@end
