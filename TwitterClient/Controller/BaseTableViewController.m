//
//  BaseTableViewController.m
//  TwitterClient
//
//  Created by Yavuz Nuzumlali on 15/04/14.
//  Copyright (c) 2014 manuyavuz. All rights reserved.
//

#import "BaseTableViewController.h"
#import "Tweet.h"
#import "AFNetworking.h"
#import "TweetCell.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = 0;
    Tweet *tweet = self.dataArray[indexPath.row];
    
    CGSize size = [tweet.text  boundingRectWithSize:CGSizeMake(250.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self textLabelFont]} context:nil].size;
    
    height += size.height;
    float cellWidth = TWEET_CELL_TEXT_WIDTH; //neden direk parametre olarak geciremiyorum
    
    size = [tweet.user.screenName sizeWithFont:[self textLabelFont] constrainedToSize:CGSizeMake(cellWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    height += size.height;
    
    height += 10;
    
    
    return ceilf(height);
    
}

- (TweetCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimelineCell";
    TweetCell *cell;
    //    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Tweet *tweet = self.dataArray[indexPath.row];
    cell.textLabel.font = [self textLabelFont];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = tweet.text;
    CGFloat imageHeight = TWEET_CELL_IMAGE_HEIGHT;
    CGFloat imageWidth = TWEET_CELL_IMAGE_WIDTH;
    if(tweet.user.profileImage)
    {
        cell.imageView.image = [ImageUtil resizeImage:tweet.user.profileImage withWidth:imageWidth withHeight:imageHeight];
        cell.imageView.bounds = CGRectMake(0, 0, imageWidth, imageHeight);
        
    }
    
    
    cell.detailTextLabel.textColor = [UIColor magentaColor];
    cell.detailTextLabel.font = [self detailTextLabelFont];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",tweet.user.screenName];
    
    return cell;
}


#pragma mark - root table functionality

RequestType lastType;

- (void)refreshDataWithType:(RequestType)type
{
    __weak BaseTableViewController *weakSelf = self;
    [[RequestManager sharedManager] requestWithRequestType:type completion:^(BOOL succeeded, id response, NSError *error) {
        if(succeeded)
        {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in response) {
                Tweet *tweet = [[Tweet alloc] initWithDictionary:dict];
                [tmpArray addObject:tweet];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:tweet.user.profileImageURL];
                
                AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    tweet.user.profileImage = responseObject;
                    NSUInteger index = [weakSelf.dataArray indexOfObject:tweet];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    
                    if ([weakSelf.tableView cellForRowAtIndexPath:indexPath])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                            CGFloat imageHeight = TWEET_CELL_IMAGE_HEIGHT;
                            CGFloat imageWidth = TWEET_CELL_IMAGE_WIDTH;
                            cell.imageView.image = [ImageUtil resizeImage:tweet.user.profileImage withWidth:imageWidth withHeight:imageHeight];
                            cell.imageView.bounds = CGRectMake(0, 0, imageWidth, imageHeight);
                            /*
                             cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",tweet.user.screenName];
                             cell.textLabel.text = tweet.text;
                             cell.textLabel.font = [self textLabelFont];
                             */
                            [weakSelf.tableView  reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            
                            
                        });
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Image error: %@", error);
                }];
                [requestOperation start];
                
            }
            //            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.dataArray = tmpArray;
                [weakSelf.tableView reloadData];
            });
        }
        else
        {
            NSLog(@"TIMELINE FAILED!!\nResponse : %@\nError : %@",response,[error debugDescription]);
        }
    }];
}


#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDataWithType:)];
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:refreshControl];
    
//    self.tableController = [[UITableViewController alloc] init];
//    self.tableController.tableView = self.tableView;
//    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
//    self.tableController.refreshControl = self.refreshControl;

    
//    UITableViewController *controller = [[UITableViewController alloc] init];
//    controller.preferredContentSize = self.view.bounds.size;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
