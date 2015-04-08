//
//  TKTutorialViewController.m
//  Tinkler
//
//  Created by Diogo Guimarães on 25/01/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import "TKTutorialViewController.h"

@interface TKTutorialViewController ()

@end

@implementation TKTutorialViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Tutorial";
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                NSLog(@"iPhone 4 Resolution");
                self.pageImages = @[@"iphone4-01.png",
                                    @"iphone4-02.png",
                                    @"iphone4-03.png",
                                    @"iphone4-04.png",
                                    @"iphone4-05.png"];
            }
            if(result.height == 1136) {
                NSLog(@"iPhone 5 Resolution");
                self.pageImages = @[@"iphone5-01.png",
                                    @"iphone5-02.png",
                                    @"iphone5-03.png",
                                    @"iphone5-04.png",
                                    @"iphone5-05.png"];
            }
            if(result.height == 1334) {
                NSLog(@"iPhone 6 Resolution");
                self.pageImages = @[@"iphone6-01.png",
                                    @"iphone6-02.png",
                                    @"iphone6-03.png",
                                    @"iphone6-04.png",
                                    @"iphone6-05.png"];
            }
            if(result.height == 2208) {
                NSLog(@"iPhone 6 Plus Resolution");
                self.pageImages = @[@"iphone6+-01.png",
                                    @"iphone6+-02.png",
                                    @"iphone6+-03.png",
                                    @"iphone6+-04.png",
                                    @"iphone6+-05.png"];
            }
        }else{
            NSLog(@"Standard Resolution");
            self.pageImages = @[@"iphone4-01.png",
                                @"iphone4-02.png",
                                @"iphone4-03.png",
                                @"iphone4-04.png",
                                @"iphone4-05.png"];
        }
    }
    
    self.pageDescriptions = @[@"Think of everything you would like to always be connected to and create a Tinkler of it",
                              @"Shortly after, you'll receive an email with the QR-Code for your Tinkler. Print it!",
                              @"Place the QR-Code in your Tinkler so that it stays visible and scannable by everyone",
                              @"From now on when someone scans that QR-Code using Tinkler you'll be notified",
                              @"You can now communicate without having to share personal information between Tinkler users. Enjoy!"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, 20, 60, 30)];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(goToScanPage) forControlEvents:UIControlEventTouchUpInside];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 50, self.view.frame.size.height - 50, 100, 50)];
    self.pageControl.numberOfPages = [self.pageImages count];
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:.89 blue:.20 alpha:1];
    
    TKPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40);
    [self.pageViewController setDelegate:self];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.view addSubview:self.skipButton];
    [self.view addSubview:self.pageControl];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)goToScanPage {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasSeenTut"];
    [defaults synchronize];
    
    UIStoryboard *storyBoard = self.storyboard;
    UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TabViewController"];
    UINavigationController *navController = self.navigationController;
    
    if (navController) {
        //Code to show the navigation bar
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        [navController pushViewController:targetViewController animated:NO];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
}

- (TKPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TKPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.descriptionText = self.pageDescriptions[index];
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TKPageContentViewController*) viewController).pageIndex;
    
    // Create a new view controller and pass suitable data.
    TKPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.descriptionText = self.pageDescriptions[index];
    
    if (index == [self.pageImages count]-1){
        pageContentViewController.buttonHidden = NO;
        [self.skipButton setTitle:@"Finish" forState:UIControlStateNormal];
    } else {
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        pageContentViewController.buttonHidden = YES;
    }
    
    if ((index == 0) || (index == NSNotFound)) {
        [self.pageControl setCurrentPage:index];
        return nil;
    }
    
    [self.pageControl setCurrentPage:index];
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TKPageContentViewController*) viewController).pageIndex;
    
    // Create a new view controller and pass suitable data.
    TKPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.descriptionText = self.pageDescriptions[index];
    
    if (index == [self.pageImages count]-1){
        pageContentViewController.buttonHidden = NO;
        [self.skipButton setTitle:@"Finish" forState:UIControlStateNormal];
    } else {
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        pageContentViewController.buttonHidden = YES;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    [self.pageControl setCurrentPage:index];
    
    index++;
    
    if (index == [self.pageImages count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
