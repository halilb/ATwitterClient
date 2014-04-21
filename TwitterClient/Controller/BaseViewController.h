//
//  BaseViewController.h
//  TwitterClient
//
//  Created by Yavuz Nuzumlali on 15/04/14.
//  Copyright (c) 2014 manuyavuz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

extern CGFloat const TextLabelFont;
extern CGFloat const DetailTextLabelFont;

- (UIFont*)textLabelFont;
- (UIFont*)detailTextLabelFont;

@end
