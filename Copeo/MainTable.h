//
//  MainTable.h
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <iAd/iAd.h>
#import "GAITrackedViewController.h"

@interface MainTable : GAITrackedViewController<UIApplicationDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
}
@property (weak, nonatomic) IBOutlet UITableView *tblMain;
- (IBAction)btnAddPressed:(id)sender;

@end
