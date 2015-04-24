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
    //Verify if user has received a push notification - through user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool hasReceivedMsg = [defaults boolForKey:@"hasReceivedMsg"];
    
    if(hasReceivedMsg) {
        self.selectedIndex = 0;
    } else {
        self.selectedIndex = 1;
    }
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
   [super viewDidAppear:YES];
}

@end

