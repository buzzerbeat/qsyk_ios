//
//  MyHeadImageViewController.h
//  quiz
//
//  Created by subo on 15/11/11.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyHeadImageDelegate;

@interface MyHeadImageViewController : UIViewController

@property (weak, nonatomic) id<MyHeadImageDelegate> delegate;

- (instancetype)initWithTarget:(id)target;
- (UIAlertController *)actionSheet;
@end

@protocol MyHeadImageDelegate <NSObject>

- (void)presentVC:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissViewController;
- (void)upLoadAvatarWithFilePath:(NSString *)filePath;

@end