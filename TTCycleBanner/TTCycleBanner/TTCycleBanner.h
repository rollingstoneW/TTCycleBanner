//
//  TTCycleBanner.h
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTPagingCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTCycleBannerItem : NSObject

/**
 图片地址
 */
@property (nonatomic,   copy, nullable) NSString *imageUrl;
/**
 文字描述
 */
@property (nonatomic,   copy, nullable) NSString *title;
/**
 富文本描述
 */
@property (nonatomic,   copy, nullable) NSAttributedString *prettyTitle;
/**
 展示本地图片，也可当作占位图t展示
 */
@property (nonatomic, strong, nullable) UIImage *localImage;

+ (instancetype)itemWithImageUrl:(NSString *)imageUrl;
+ (instancetype)itemWithImageUrl:(nullable NSString *)imageUrl titleOrPretty:(nullable id)title localImage:(nullable UIImage *)localImage;

+ (NSArray *)itemsWithImageUrls:(NSArray *)imageUrls;
+ (NSArray *)itemsWithImageUrls:(nullable NSArray *)imageUrls titlesOrPretty:(nullable NSArray *)titlesOrPretty localImages:(nullable NSArray *)localImages;

@end

@interface TTCycleBannerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) TTCycleBannerItem *item;

@end

@class TTCycleBanner;
@protocol TTCycleBannerDelegate <TTPagingCollectionViewDelegate>
@optional
- (void)cycleBanner:(TTCycleBanner *)cycleBanner didSelectItemAtIndex:(NSInteger)index;
- (void)cycleBanner:(TTCycleBanner *)cycleBanner didScrollToIndex:(NSInteger)index;

@end

@interface TTCycleBanner : TTPagingCollectionView


/**
 设置轮播图
 */
@property (nonatomic, strong) NSArray *items;

/**
 可以自定义cell，Class需要继承TTCycleBannerCell
 */
@property (nonatomic, strong) Class customCellClass;

@property (nonatomic,   weak) id<TTCycleBannerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
