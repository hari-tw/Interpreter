//
//  NLBinding.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

#import "NLBindingFilesystem.h"
#import "NLBindingConstants.h"
#import "NLBindingSmalloc.h"
#import "NLBindingBuffer.h"
#import "NLCaresWrap.h"
#import "NLBindingUv.h"
#import "NLTimerWrap.h"

@implementation NLBinding

+ (NSCache *)bindingCache {
    static NSCache *cache = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (NSDictionary *)bindings {
    static NSDictionary *bindings = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        bindings = @{@"fs":         [NLBindingFilesystem class],
                     @"constants":  [NLBindingConstants  class],
                     @"smalloc":    [NLBindingSmalloc    class],
                     @"buffer":     [NLBindingBuffer     class],
                     @"timer_wrap": [NLTimerWrap         class],
                     @"cares_wrap": [NLCaresWrap         class],
                     @"uv":         [NLBindingUv         class]};
    });
    return bindings;
}

+ (id)bindingForIdentifier:(NSString *)identifier {
    NSCache *cache = [NLBinding bindingCache];
    id binding = [cache objectForKey:identifier];
    if (binding != nil) {
        return binding;
    }
    Class cls = [NLBinding bindings][identifier];
    if (cls) {
        binding = [cls binding];
        [cache setObject:binding forKey:identifier];
        return binding;
    } else {
        return nil;
    }
}

+ (id)binding {
    return self;
}

+ (JSValue *)makeConstructor:(id)block inContext:(JSContext *)context {
    JSValue *fun = [context evaluateScript:@"(function () { return this.__construct.apply(this, arguments); });"];
    fun[@"prototype"][@"__construct"] = block;
    return fun;
}

@end
