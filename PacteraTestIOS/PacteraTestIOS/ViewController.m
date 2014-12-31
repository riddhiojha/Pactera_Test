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
    dataArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    
    UIRefreshControl *refreshControlLocal = [[UIRefreshControl alloc]
                                        init];
    refreshControlLocal.tintColor = [UIColor blueColor];
    [refreshControlLocal addTarget:self action:@selector(getDataFromURL) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControlLocal;    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataFromURL];
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
        
        
        dataArray = [responseObject objectForKey:@"rows"];
        [self.tableView reloadData];
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
    
    if([[cellDict valueForKey:@"image"] isEqual:[NSNull null]])
    {
        [cellDict setValue:@"-" forKey:@"image"];
    }
    

    NSString *mainNameLabel = [cellDict valueForKey:@"title"];
    UIFont *mainLabelFont = [UIFont fontWithName:@"TSTAR-Light" size:20];
    
    
    NSString *descriptionLabelText = [cellDict valueForKey:@"description"];
    UIFont *descriptionLabelFont = [UIFont fontWithName:@"TSTAR-Light" size:14];
    
    
    
    //get size of text
    CGSize sizeMainLabel = [self getSizeOfText:mainNameLabel withFont:mainLabelFont];
    CGSize sizeDescriptionLabel = [self getSizeOfText:descriptionLabelText withFont:descriptionLabelFont];
    
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, sizeMainLabel.height/2-4, 20, 20)];
    
    //For lazy loading of images we use SD web image API
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:[cellDict valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholderLogo.png"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 234, sizeMainLabel.height)];
    titleLabel.text = mainNameLabel;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont fontWithName:@"TSTAR-Light" size:20];
    titleLabel.textColor = [UIColor blueColor];
    
    
    //description label
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (20 + sizeMainLabel.height), 234, sizeDescriptionLabel.height)];
    descriptionLabel.text = mainNameLabel;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"TSTAR-Light" size:14];
    descriptionLabel.textColor = [UIColor blueColor];
    
    
    [cell.contentView addSubview:descriptionLabel];
    [cell.contentView addSubview:titleLabel];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableDictionary *cellDict = [dataArray objectAtIndex:indexPath.row];
//    
//    //Title implementation
//    NSString *mainNameLabel = [cellDict valueForKey:@"description"];
//    UIFont *mainLabelFont = [UIFont fontWithName:@"TSTAR-Light" size:20];
//    CGSize SizeMainLabel = [self getSizeOfText:mainNameLabel withFont:mainLabelFont];
//    
//    return SizeMainLabel.height+15;
    
    return 200;
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

