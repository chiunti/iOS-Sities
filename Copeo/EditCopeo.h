//
//  ViewController.h
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditCopeo : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

// Images
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
//Navigators

@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

// Labels
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtLatitude;
@property (weak, nonatomic) IBOutlet UITextField *txtLongitude;
//ScrollView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//Vistas
@property (weak, nonatomic) IBOutlet UIView *vwAcquire;
//botones
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;

//Actions
- (IBAction)btnSavePressed:(id)sender;
- (IBAction)btnCameraPressed:(id)sender;
- (IBAction)btnReelPressed:(id)sender;
- (IBAction)btnPhotoPressed:(id)sender;
- (IBAction)btnCloseAcquire:(id)sender;
- (IBAction)btnLostFocus:(id)sender;
- (IBAction)textFieldDidBeginEditing:(UITextField *)sender;

@end

