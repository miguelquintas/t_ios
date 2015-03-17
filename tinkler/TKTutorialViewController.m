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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Tutorial";
    
    // Create the data model
    _pageImages = @[@"tutorial1.png", @"tutorial2.png", @"tutorial3.png", @"tutorial4.png", @"tutorial5.png"];
    _pageDescriptions = @[@"Think of everything you would like to always be connected to and create a Tinkler of it", @"Shortly after, you'll receive an email with the QR-Code for your Tinkler. Print it!", @"Place the QR-Code in your Tinkler so that it stays visible and scannable by everyone", @"From now on when someone scans that QR-Code using Tinkler you'll be notified", @"You can now communicate without having to share personal information between Tinkler users. Enjoy!"];
    
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
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.view addSubview:self.skipButton];
    [self.view addSubview:self.pageControl];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)goToScanPage {
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
    
    if (index == [self.pageImages count] - 1){
        pageContentViewController.buttonHidden = NO;
        [self.skipButton setTitle:@"Finish" forState:UIControlStateNormal];
    } else {
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        pageContentViewController.buttonHidden = YES;
    }
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TKPageContentViewController*) viewController).pageIndex;
    
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
