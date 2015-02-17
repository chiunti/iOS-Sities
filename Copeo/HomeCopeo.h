//
//  ViewController.h
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface HomeCopeo : UIViewController

// Labels
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtLatitude;
@property (weak, nonatomic) IBOutlet UITextField *txtLongitude;

//Actions
- (IBAction)btnSavePressed:(id)sender;

@end

