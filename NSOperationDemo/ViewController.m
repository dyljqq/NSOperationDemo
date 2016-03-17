//
//  ViewController.m
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/16.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "ViewController.h"
#import "JQQImageOperation.h"

@interface ViewController ()<NSURLSessionDelegate>

@end

@implementation ViewController{
    NSArray* webSites;
    NSMutableArray* webSitesIcon;
    NSMutableArray* progressArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    webSites = @[@"google.com", @"amazon.com", @"microsoft.com", @"oreilly.com"];
    webSitesIcon = [NSMutableArray array];
    progressArray = [NSMutableArray array];
    for (int i = 0; i < [webSites count]; i++) {
        [webSitesIcon addObject:[NSNull null]];
        [progressArray addObject:@0];
    }
    [self downloadFavicon];
}

#pragma Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [webSites count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    UIProgressView* progressView = [cell viewWithTag:8888];
    if(progressView == nil){
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.progress = 0;
        progressView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
        progressView.tag = 8888;
        [cell addSubview:progressView];
    }
    progressView.progress = [progressArray[indexPath.row] floatValue];
    cell.textLabel.text = webSites[indexPath.row];
    UIImage* image = (UIImage*)webSitesIcon[indexPath.row];
    if((NSNull*)image != [NSNull null]){
        cell.imageView.image = image;
    }
    return cell;
}

#pragma Private Method

- (void)downloadFavicon{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    int index = 0;
    for (NSString* urlName in webSites) {
//        [queue addOperationWithBlock:^{
//            NSString* urlString = [NSString stringWithFormat:@"http://%@/favicon.ico", urlName];
//            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//            NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//            NSURLSessionDownloadTask* task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * __nullable location, NSURLResponse * __nullable response, NSError * __nullable error){
//                NSData * data = [NSData dataWithContentsOfURL:location];
//                if (data != nil) {
//                    UIImage* image = [UIImage imageWithData:data];
//                    if(image != nil){
//                        [webSitesIcon replaceObjectAtIndex:index withObject:image];
//                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                            [self.tableView reloadData];
//                        }];
//                    }
//                }
//            }];
//            [task resume];
//        }];
        NSString* urlString = [NSString stringWithFormat:@"http://%@/favicon.ico", urlName];
        JQQImageOperation* operation = [[JQQImageOperation alloc] initWithUrlString:urlString];
        [queue addOperation:operation];
        operation.dataBlock = ^(UIImage* image, NSError* error){
            if(image)
                [webSitesIcon replaceObjectAtIndex:index withObject:image];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        };
        operation.progressBlock = ^(CGFloat progress){
            [progressArray insertObject:[NSNumber numberWithFloat:progress] atIndex:index];
            [self.tableView reloadData];
        };
        index++;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
