//
//  QCTabViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 03/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCTabViewController.h"

@implementation QCTabViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    //Set the default tab
    self.selectedIndex = 2;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:YES];
}


@end

