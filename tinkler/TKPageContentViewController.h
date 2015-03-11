//
//  TKPageContentViewController.h
//  Tinkler
//
//  Created by Miguel Quintas on 03/03/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *imageDescription;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property NSUInteger pageIndex;
@property NSString *imageFile;
@property NSString *descriptionText;
@property bool buttonHidden;

@end
