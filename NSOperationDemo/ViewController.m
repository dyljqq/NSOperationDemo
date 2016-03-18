//
//  ViewController.m
//  NSOperationDemo
//
//  Created by 季勤强 on 16/3/16.
//  Copyright © 2016年 季勤强. All rights reserved.
//

#import "ViewController.h"
#import "JQQImageOperation.h"
#import "JQQWebImageDownLoader.h"

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
//    webSites = @[// progressive jpeg
//                 @"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg",
//                 
//                 // animated gif: http://cinemagraphs.com/
//                 @"http://i.imgur.com/uoBwCLj.gif",
//                 @"http://i.imgur.com/8KHKhxI.gif",
//                 @"http://i.imgur.com/WXJaqof.gif",
//                 
//                 // animated gif: https://dribbble.com/markpear
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1780193/dots18.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1809343/dots17.1.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1845612/dots22.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1820014/big-hero-6.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1819006/dots11.0.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1799885/dots21.gif",
//                 
//                 // animaged gif: https://dribbble.com/jonadinges
//                 @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/2025999/batman-beyond-the-rain.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1855350/r_nin.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1963497/way-back-home.gif",
//                 @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1913272/depressed-slurp-cycle.gif",
//                 
//                 // jpg: https://dribbble.com/snootyfox
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2016158/avalanche.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1839353/pilsner.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1833469/porter.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1521183/farmers.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1391053/tents.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1399501/imperial_beer.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1488711/fishin.jpg",
//                 @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1466318/getaway.jpg",
//                 
//                 // animated webp and apng: http://littlesvr.ca/apng/gif_apng_webp.html
//                 @"http://littlesvr.ca/apng/images/BladeRunner.png",
//                 @"http://littlesvr.ca/apng/images/Contact.webp",];
    webSites = @[@"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

#pragma Private Method

- (void)downloadFavicon{
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
//        NSString* urlString = [NSString stringWithFormat:@"http://%@/favicon.ico", urlName];
//        JQQImageOperation* operation = [[JQQImageOperation alloc] initWithUrlString:urlString];
//        [queue addOperation:operation];
//        operation.dataBlock = ^(UIImage* image, NSError* error){
//            if(image)
//                [webSitesIcon replaceObjectAtIndex:index withObject:image];
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [self.tableView reloadData];
//            }];
//        };
//        operation.progressBlock = ^(CGFloat progress){
//            [progressArray insertObject:[NSNumber numberWithFloat:progress] atIndex:index];
//            [self.tableView reloadData];
//        };
//        NSString* urlString = [NSString stringWithFormat:@"http://%@/favicon.ico", urlName];
        NSString* urlString = urlName;
        [[JQQWebImageDownLoader sharedManager] downloadImageWithUrlString:urlString progress:^(CGFloat progress){
            [progressArray insertObject:[NSNumber numberWithFloat:progress] atIndex:index];
            [self.tableView reloadData];
        }complete:^(UIImage* image, NSError* error){
            if(image)
                [webSitesIcon replaceObjectAtIndex:index withObject:image];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }];
        index++;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
