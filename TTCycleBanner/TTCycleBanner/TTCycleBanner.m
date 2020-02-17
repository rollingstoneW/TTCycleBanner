//
//  TTCycleBanner.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCycleBanner.h"
#import "TTCombineDelegateProxy.h"
#import "UIImageView+WebCache.h"

@implementation TTCycleBannerItem

+ (instancetype)itemWithImageUrl:(NSString *)imageUrl {
    return [self itemWithImageUrl:imageUrl titleOrPretty:nil localImage:nil];
}

+ (instancetype)itemWithImageUrl:(nullable NSString *)imageUrl titleOrPretty:(nullable id)title localImage:(nullable UIImage *)localImage {
    TTCycleBannerItem *item = [[self alloc] init];
    item.imageUrl = imageUrl;
    if ([title isKindOfClass:[NSString class]]) {
        item.title = title;
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        item.prettyTitle = title;
    }
    item.localImage = localImage;
    return item;
}

+ (NSArray *)itemsWithImageUrls:(NSArray *)imageUrls {
    return [self itemsWithImageUrls:imageUrls titlesOrPretty:nil localImages:nil];
}

+ (NSArray *)itemsWithImageUrls:(nullable NSArray *)imageUrls titlesOrPretty:(nullable NSArray *)titlesOrPretty localImages:(nullable NSArray *)localImages {
#define queryObject(arr) (arr.count > i ? arr[i] : nil)
    NSMutableArray *items = [NSMutableArray array];
    NSInteger count = MAX(MAX(imageUrls.count, titlesOrPretty.count), localImages.count);
    for (NSInteger i = 0; i < count; i++) {
        [items addObject:[self itemWithImageUrl:queryObject(imageUrls) titleOrPretty:queryObject(titlesOrPretty) localImage:queryObject(localImages)]];
    }
    return items;
#undef queryObject
}

@end

@implementation TTCycleBannerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

- (void)setItem:(TTCycleBannerItem *)item {
    _item = item;

    self.imageView.image = item.localImage;
    self.textLabel.text = item.title;
    if (item.prettyTitle) {
        self.textLabel.attributedText = item.prettyTitle;
    }
    self.textLabel.hidden = !self.textLabel.text.length && !self.textLabel.attributedText.length;
    if (item.imageUrl) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrl]];
    }
    [self adjustTextFrame];
}

- (void)adjustTextFrame {
    if (self.textLabel.hidden || !self.frame.size.width) {
        return;
    }
    CGSize size;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat marginLeft = 15, marginBottom = 20;
    CGFloat inset = 5;
    CGFloat textMaxWidth = selfWidth - marginLeft - inset * 2;
    if (self.textLabel.attributedText) {
        size = [self.textLabel.attributedText boundingRectWithSize:CGSizeMake(textMaxWidth, 100)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil].size;
    } else {
        size = [self.textLabel.text boundingRectWithSize:CGSizeMake(textMaxWidth, 100)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:self.textLabel.font}
                                                 context:nil].size;
    }
    CGFloat textWidth = ceilf(size.width + inset * 2);
    CGFloat textHeight = ceilf(size.height + inset * 2);
    self.textLabel.frame = CGRectMake(selfWidth - textWidth, selfHeight - marginBottom - textHeight, textWidth, textHeight);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = self.contentView.bounds;
    [self adjustTextFrame];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 2;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    }
    return _textLabel;
}

@end

@interface TTCycleBanner () <TTPagingCollectionViewDataSource, TTPagingCollectionViewDelegate>
@property (nonatomic, strong) TTCombineDelegateProxy *delegateProxy;
@end

@implementation TTCycleBanner
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.autoScrollEnabled = YES;
    self.showPageControl = YES;
    self.delegate = (id<TTCycleBannerDelegate>)self;
    self.dataSource = self;
    self.customCellClass = [TTCycleBannerCell class];
}

- (void)setItems:(NSArray *)items {
    _items = items;
    [self reloadData];
}

- (void)setDelegate:(id<TTCycleBannerDelegate>)delegate {
    TTCombineDelegateProxy *proxy;
    if (delegate && delegate != (id<TTCycleBannerDelegate>)self) {
        proxy = [TTCombineDelegateProxy proxyWithPriorDelegate:self secondaryDelegate:delegate];
    } else {
        proxy = [TTCombineDelegateProxy proxyWithPriorDelegate:self secondaryDelegate:nil];
    }
    proxy.whitelistForPriorDelegateSelector = @[NSStringFromSelector(@selector(pagingCollectionView:didSelectCellAtIndex:)),
                                                NSStringFromSelector(@selector(pagingCollectionView:didScrollToIndex:))];
    proxy.blacklistForSecondaryDelegateSelector = proxy.whitelistForPriorDelegateSelector;
    self.delegateProxy = proxy;
    [super setDelegate:(id<TTCycleBannerDelegate>)proxy];
}

- (void)setCustomCellClass:(Class)customCellClass {
    _customCellClass = customCellClass;
    [self registerClass:customCellClass forCellReuseIdentifier:NSStringFromClass(customCellClass)];
}

- (NSInteger)numberOfRowsInPagingCollectionView:(TTPagingCollectionView *)collectionView {
    return self.items.count;
}

- (UICollectionViewCell *)pagingCollectionView:(TTPagingCollectionView *)collectionView cellForItemAtIndex:(NSInteger)index {
    TTCycleBannerCell *cell = [self dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.customCellClass) forIndex:index];
    cell.item = self.items[index];
    return cell;
}

- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didSelectCellAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(cycleBanner:didSelectItemAtIndex:)]) {
        [self.delegate cycleBanner:self didSelectItemAtIndex:index];
    }
}

- (void)pagingCollectionView:(TTPagingCollectionView *)collectionView didScrollToIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(cycleBanner:didScrollToIndex:)]) {
        [self.delegate cycleBanner:self didScrollToIndex:index];
    }
}

@end
