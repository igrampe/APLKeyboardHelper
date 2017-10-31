//
//  APLKeyboardHelper.m
//  APLKeyboardHelper
//
//  Created by Semyon Belokovsky on 24/10/15.
//  Copyright © 2015 Semyon Belokovsky. All rights reserved.
//

#import "APLKeyboardHelper.h"

@interface APLKeyboardHelper : NSObject

@property NSMutableDictionary *handlers;
@property NSArray *notificationNames;

@end

@implementation APLKeyboardHelper

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedObject
{
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.notificationNames = @[UIKeyboardWillShowNotification,
                                   UIKeyboardDidShowNotification,
                                   UIKeyboardWillHideNotification,
                                   UIKeyboardDidHideNotification,
                                   UIKeyboardWillChangeFrameNotification,
                                   UIKeyboardDidChangeFrameNotification];
        self.handlers = [NSMutableDictionary new];
        
        for (NSString *nn in self.notificationNames)
        {
            [self.handlers setObject:[NSMutableDictionary new] forKey:nn];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleNotification:)
                                                         name:nn
                                                       object:nil];
        }
    }
    return self;
}

+ (void)clearHandlersWithHash:(NSUInteger)hash
{
    for (NSMutableDictionary *hs in [APLKeyboardHelper sharedObject].handlers.allValues)
    {
        [hs removeObjectForKey:@(hash)];
    }
}

+ (void)addHandler:(APLKeyboardHelperHandler)handler forNotificationName:(NSString *)name withHash:(NSUInteger)hash
{
    NSMutableDictionary *hs = [[APLKeyboardHelper sharedObject].handlers objectForKey:name];
    if (handler)
    {
        APLKeyboardHelperHandler h = [handler copy];
        if (!hs)
        {
            hs = [NSMutableDictionary new];
            [[APLKeyboardHelper sharedObject].handlers setObject:hs forKey:name];
        }
        [hs setObject:h forKey:@(hash)];
    } else {
        if (hs)
        {
            [hs removeObjectForKey:@(hash)];
        }
    }
}

- (void)handleNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize size = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSMutableDictionary *hs = [self.handlers objectForKey:notification.name];
    for (APLKeyboardHelperHandler handler in [hs allValues])
    {
        if (handler) {
            handler(size, duration);
        }
    }
}

@end

#pragma mark - NSObject

@implementation NSObject (KeyboardHelper)

- (void)addHandler:(APLKeyboardHelperHandler)handler forNotificationName:(NSString *)name
{
    [APLKeyboardHelper addHandler:handler forNotificationName:name withHash:self.hash];
}

- (void)handleKeyboardWillShow:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardWillShowNotification];
}

- (void)handleKeyboardDidShow:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardDidShowNotification];
}

- (void)handleKeyboardWillHide:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardWillHideNotification];
}

- (void)handleKeyboardDidHide:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardDidHideNotification];
}

- (void)handleKeyboardWillChange:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardWillChangeFrameNotification];
}

- (void)handleKeyboardDidChange:(APLKeyboardHelperHandler)handler
{
    [self addHandler:handler forNotificationName:UIKeyboardDidChangeFrameNotification];
}

- (void)cancelHandlingKeyboard
{
    [APLKeyboardHelper clearHandlersWithHash:self.hash];
}

@end

