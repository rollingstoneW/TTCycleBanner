//
//  TTCombineDelegateProxy.h
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 实现多重代理。首先执行priorDelegate的方法，之后再执行secondaryDelegate的方法。如果执行的方法需要返回值，则只执行priorDelegate的方法
 栗子：
 TTAlphaNavigationBar *navigationBar = **;
 UIScrollView *scrollView = **;
 // 控制器持有，防止proxy立马释放
 self.delegateProxy = [TTCombineDelegateProxy proxyWithPriorDelegate:self secondaryDelegate:navigationBar];
 scrollView.delegate = self.delegateProxy;
 */
@interface TTCombineDelegateProxy : NSProxy

@property (nonatomic, copy) NSArray *whitelistForPriorDelegateSelector; // 首要代理的方法白名单，不指定就可以执行所有方法
@property (nonatomic, copy) NSArray *blacklistForPriorDelegateSelector; // 首要代理的方法黑名单，黑名单里的方法不会被执行

@property (nonatomic, copy) NSArray *whitelistForSecondaryDelegateSelector; // 次要代理的方法白名单，不指定就可以执行所有方法
@property (nonatomic, copy) NSArray *blacklistForSecondaryDelegateSelector; // 次要代理的方法黑名单，黑名单里的方法不会被执行

+ (instancetype)proxyWithPriorDelegate:(id)prior secondaryDelegate:(nullable id)secondary;

@end

NS_ASSUME_NONNULL_END
