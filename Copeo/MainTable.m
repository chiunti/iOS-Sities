//
//  MainTable.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "MainTable.h"
#import "CustomTableViewCell.h"
#import "Defaults.h"


UIRefreshControl *refreshControl;

@interface MainTable ()

@end

@implementation MainTable

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cfgiAdBanner];
    // Do any additional setup after loading the view.
    
    // Initialize the refresh control.
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor grayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(getLugares) forControlEvents:UIControlEventValueChanged];
    [self.tblMain addSubview:refreshControl];
    
    //self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    //self.refreshControl.tintColor = [UIColor whiteColor];
    //[self.refreshControl addTarget:self
    //                        action:@selector(getLatestLoans)
    //              forControlEvents:UIControlEventValueChanged];
    [self getLugares];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLugares
{
    if (![refreshControl isRefreshing]) {
        [self.tblMain setContentOffset:CGPointMake(0, -refreshControl.frame.size.height) animated:YES];
        [refreshControl beginRefreshing];
    }
    NSLog(@"getLugares");
    PFQuery *query = [PFQuery queryWithClassName:@"lugares"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            lugares = [NSMutableArray arrayWithArray:objects];
            //for(id object in objects){
            //    [lugares addObject:object];
            //    NSLog(@"%@",object[@"name"]);
           // }
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)reloadData
{
    // Reload table data
    NSLog(@"reloadData");
    [self.tblMain reloadData];
    
    // End the refreshing
    if ([refreshControl isRefreshing]) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Actualizado el: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
        [refreshControl endRefreshing];
    }
    
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (lugares) {
        self.tblMain.backgroundView = nil;
        self.tblMain.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No hay datos. Desliza hacia abajo para refrescar.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tblMain.backgroundView = messageLabel;
        self.tblMain.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (lugares) {
        return [lugares count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    // Configure the cell...
    //Loan *loan = [loans objectAtIndex:indexPath.row];
    
    cell.lblTitle.text = lugares[indexPath.row][@"name"];
    cell.lblDetail.text = lugares[indexPath.row][@"description"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//-------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/***************************************
 iAd Banner
 **************************************/
- (void)cfgiAdBanner
{
    // Setup iAdView
    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, /*self.view.frame.size.height*/ 20, self.view.frame.size.width, 50)];
    /*
     adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
     
     //Set coordinates for adView
     CGRect adFrame      = adView.frame;
     //adFrame.origin.y    = self.view.frame.size.height - 50;
     adFrame.origin.y    = 20;
     NSLog(@"adFrame.origin.y: %f",adFrame.origin.y);
     adView.frame        = adFrame;
     */
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    adView.delegate = self;
    [self.view addSubview:adView];
    adView.delegate         = self;
    adView.hidden           = YES;
    self->bannerIsVisible   = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self->bannerIsVisible)
    {
        adView.hidden = NO;
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        [UIView commitAnimations];
        self->bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self->bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        [UIView commitAnimations];
        adView.hidden = YES;
        self->bannerIsVisible = NO;
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES;
    if (!willLeave && shouldExecuteAction)
    {
        // stop all interactive processes in the app
        // [video pause];
        // [audio pause];
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"resume actions from banner");
    // resume everything you've stopped
    // [video resume];
    // [audio resume];
}

@end
