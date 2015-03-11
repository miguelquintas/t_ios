//
//  TKTutorialViewController.h
//  Tinkler
//
//  Created by Diogo Guimarães on 25/01/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCApi.h"
#import "TKPageContentViewController.h"

@interface TKTutorialViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageDescriptions;

@end
