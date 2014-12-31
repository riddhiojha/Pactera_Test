//
//  ViewController.m
//  PacteraTestIOS
//
//  Created by Riddhi on 12/31/14.
//  Copyright (c) 2014 Riddhi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tableView, refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    dataArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 320, screenHeight-90)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    
    refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor colorWithRed:89/255.0 green:173/255.0 blue:222/255.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(getDataFromURL) forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:refreshControl];
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataFromURL];
}

-(void)dealloc
{
    [dataArray release];
    [tableView release];
    [refreshControl release];

    [headinLabel release];
    [pullDownInstructionLabel release];
    [super dealloc];
    
}

- (void) getDataFromURL
{
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation
                                               , id responseObject) {
        
        
        // added label instead of navigation bar
        
        headinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 35)];
        headinLabel.text = [responseObject objectForKey:@"title"];
        headinLabel.textColor = [UIColor colorWithRed:248/255.0 green:88/255.0 blue:88/255.0 alpha:1.0];
        headinLabel.font = [UIFont fontWithName:@"TSTAR-Headline" size:25];
        headinLabel.textAlignment = NSTextAlignmentCenter;
        
        pullDownInstructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 320, 15)];
        pullDownInstructionLabel.text = @"Pull down to refresh the feed";
        pullDownInstructionLabel.textColor = [UIColor darkGrayColor];
        pullDownInstructionLabel.font = [UIFont fontWithName:@"TSTAR-Light" size:14];
        pullDownInstructionLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:headinLabel];
        [self.view addSubview:pullDownInstructionLabel];
        
        
        
        dataArray = [responseObject objectForKey:@"rows"];
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        NSLog(@"JSON: %@", dataArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    
    [operation start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Table View Datasource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //fetching data here for each cell
    NSMutableDictionary *cellDict = [[dataArray objectAtIndex:indexPath.row]mutableCopy];
    //handle null values
    if([[cellDict valueForKey:@"title"] isEqual:[NSNull null]])
    {
         [cellDict setValue:@"-" forKey:@"title"];
    }
    
    if([[cellDict valueForKey:@"description"] isEqual:[NSNull null]])
    {
        [cellDict setValue:@"-" forKey:@"description"];
    }
    
    if([[cellDict valueForKey:@"imageHref"] isEqual:[NSNull null]])
    {
        [cellDict setValue:@"-" forKey:@"imageHref"];
    }
    

    NSString *mainNameLabel = [cellDict valueForKey:@"title"];
    UIFont *mainLabelFont = [UIFont fontWithName:@"TSTAR-Headline" size:20];
    
    NSString *descriptionLabelText = [cellDict valueForKey:@"description"];
    UIFont *descriptionLabelFont = [UIFont fontWithName:@"TSTAR-Regular" size:14];
    
    //get size of text
    CGSize sizeDescriptionLabel = [self getSizeOfText:descriptionLabelText withFont:descriptionLabelFont];
    
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(240, (sizeDescriptionLabel.height+60)/2-30, 60, 60)];
    
    //For lazy loading of images we use SD web image API
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:[cellDict valueForKey:@"imageHref"]] placeholderImage:[UIImage imageNamed:@"placeholderLogo.png"]];
    imageView.clipsToBounds = YES;
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    //Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 234, 40)];
    titleLabel.text = mainNameLabel;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont fontWithName:@"TSTAR-Headline" size:20];
    titleLabel.textColor = [UIColor colorWithRed:89/255.0 green:173/255.0 blue:222/255.0 alpha:1.0];
    
    
    //description label
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, 234, sizeDescriptionLabel.height)];
    descriptionLabel.text = descriptionLabelText;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"TSTAR-Regular" size:14];
    descriptionLabel.textColor = [UIColor blackColor];
    
    
    [cell.contentView addSubview:descriptionLabel];
    [cell.contentView addSubview:titleLabel];
    [cell.contentView addSubview:imageView];
    
    [imageView release];
    [titleLabel release];
    [descriptionLabel release];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //fetching data here for each cell
    NSMutableDictionary *cellDict = [[dataArray objectAtIndex:indexPath.row]mutableCopy];
    if([[cellDict valueForKey:@"description"] isEqual:[NSNull null]])
    {
        [cellDict setValue:@"-" forKey:@"description"];
    }
    
    NSString *descriptionLabelText = [cellDict valueForKey:@"description"];
    UIFont *descriptionLabelFont = [UIFont fontWithName:@"TSTAR-Regular" size:14];
    
    //get size of text
    CGSize sizeDescriptionLabel = [self getSizeOfText:descriptionLabelText withFont:descriptionLabelFont];
 
    
    return (sizeDescriptionLabel.height+60);
}


#pragma mark - Adjust size of cells and description


#pragma mark -  Get Size of text


- (CGSize)getSizeOfText:(NSString *)text withFont:(UIFont *)font
{
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(234, 500)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    CGSize size = textRect.size;
    return  size;
    
//    return [text sizeWithFont:font constrainedToSize:CGSizeMake(234, 500)];
    
}
#pragma mark - Refresh Button

- (IBAction)refreshButton:(id)sender
{
    [self getDataFromURL];
}

@end

