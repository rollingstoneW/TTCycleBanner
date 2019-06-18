//
//  TTCombineDelegateProxy.m
//  TTKit
//
//  Created by rollingstoneW on 2019/6/17.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCombineDelegateProxy.h"
#import <objc/runtime.h>

@interface TTCombineDelegateProxy ()

@property (nonatomic, strong) id priorDelegate;
@property (nonatomic, strong, nullable) id secondaryDelegate;

@end

@implementation TTCombineDelegateProxy

+ (instancetype)proxyWithPriorDelegate:(id)prior secondaryDelegate:(nullable id)secondary {
    TTCombineDelegateProxy *proxy = [TTCombineDelegateProxy alloc];
    proxy.priorDelegate = prior;
    proxy.secondaryDelegate = secondary;
    return proxy;
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [self priorRespondsToSelector:selector] || [self secondrayRespondsToSelector:selector] || [super respondsToSelector:selector];
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    return [self.priorDelegate conformsToProtocol:protocol] || [self.secondaryDelegate conformsToProtocol:protocol];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    if ([self priorRespondsToSelector:selector]) {
        [invocation invokeWithTarget:self.priorDelegate];
        // 如果第一个delegate已经返回了值，则不执行第二个delegate的方法
        if (strcmp([self methodSignatureForSelector:selector].methodReturnType, "v")) {
            return;
        }
    }
    if ([self secondrayRespondsToSelector:selector]) {
        [invocation invokeWithTarget:self.secondaryDelegate];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([self priorRespondsToSelector:sel]) {
        return [self.priorDelegate methodSignatureForSelector:sel];
    }
    if ([self secondrayRespondsToSelector:sel]) {
        return [self.secondaryDelegate methodSignatureForSelector:sel];
    }
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)priorRespondsToSelector:(SEL)selector {
    if (![self.priorDelegate respondsToSelector:selector]) {
        return NO;
    }
    if ([self.blacklistForPriorDelegateSelector containsObject:NSStringFromSelector(selector)]) {
        return NO;
    }
    if (self.whitelistForPriorDelegateSelector && ![self.whitelistForPriorDelegateSelector containsObject:NSStringFromSelector(selector)]) {
        return NO;
    }
    return YES;
}

- (BOOL)secondrayRespondsToSelector:(SEL)selector {
    if (![self.secondaryDelegate respondsToSelector:selector]) {
        return NO;
    }
    if ([self.blacklistForSecondaryDelegateSelector containsObject:NSStringFromSelector(selector)]) {
        return NO;
    }
    if (self.whitelistForSecondaryDelegateSelector && ![self.whitelistForSecondaryDelegateSelector containsObject:NSStringFromSelector(selector)]) {
        return NO;
    }
    return YES;
}

- (BOOL)isProxy {
    return YES;
}

@end
