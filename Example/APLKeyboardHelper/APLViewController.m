//
//  APLViewController.m
//  APLKeyboardHelper
//
//  Created by igrampe on 10/31/2017.
//  Copyright (c) 2017 igrampe. All rights reserved.
//

#import "APLViewController.h"
#import <APLKeyboardHelper/APLKeyboardHelper.h>

@interface APLViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation APLViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Avoid retain cycle
    __weak typeof(self) welf = self;
    
    // Keyboard will show, we should change bottom inset for our scrollView
    // according keyboard height
    [self handleKeyboardWillShow:^(CGSize keyboardSize, double duration) {
        welf.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    }];
    
    // Keyboard will hide, we should change bottom inset for our scrollView
    // to normal state
    [self handleKeyboardWillHide:^(CGSize keyboardSize, double duration) {
        welf.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
    
    // Keyboard will change, we should change bottom inset for our scrollView
    // according keyboard height
    [self handleKeyboardWillChange:^(CGSize keyboardSize, double duration) {
        welf.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // We should stop handling keyboard
    [self cancelHandlingKeyboard];
}

@end
