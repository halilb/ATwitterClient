//
//  BaseViewController.m
//  TwitterClient
//
//  Created by Yavuz Nuzumlali on 15/04/14.
//  Copyright (c) 2014 manuyavuz. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view methods

CGFloat const TextLabelFont = TWEET_TEXT_FONT_SIZE;
CGFloat const DetailTextLabelFont = TWEET_USER_FONT_SIZE;

- (UIFont*)textLabelFont
{
    return [UIFont systemFontOfSize:TextLabelFont];
}

- (UIFont*)detailTextLabelFont
{
    return [UIFont systemFontOfSize:DetailTextLabelFont];
}

#pragma mark - root functionality


@end
