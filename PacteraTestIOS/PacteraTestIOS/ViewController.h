//
//  ViewController.h
//  PacteraTestIOS
//
//  Created by Riddhi on 12/31/14.
//  Copyright (c) 2014 Riddhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "SBJSON.h"
#import "AFNetworking.h"


@interface ViewController : UIViewController<NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableData *_responseData;
    NSMutableArray *dataArray;
    
    UILabel *headinLabel;
    UILabel *pullDownInstructionLabel;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;


@end
