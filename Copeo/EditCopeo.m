//
//  ViewController.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "EditCopeo.h"
#import "Defaults.h"

UIAlertView *alertError, *alertGuardar;


@interface EditCopeo ()

@end

@implementation EditCopeo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initController];
}
-(void)initController
{
    self.vwAcquire.hidden = true;
    if (currentState==Insert) {
        // Nuevo registro
        self.navTitle.title = @"Agregar lugar";
        [self.btnPhoto setTitle: @"Foto" forState:UIControlStateNormal];
    } else {
        // registro existente
        self.navTitle.title = @"Editar lugar";
        [self.btnPhoto setTitle: @"" forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    alertError = [[UIAlertView alloc] initWithTitle:@"Corregir"
                                            message:@"Verifique que todos los campos tengan datos"
                                           delegate:self
                                  cancelButtonTitle:@"Aceptar"
                                  otherButtonTitles:nil];
    alertGuardar = [[UIAlertView alloc] initWithTitle:@"Datos guardados"
                                              message:nil
                                             delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.scrollView setContentOffset:CGPointMake(0, kbSize.height) animated:YES];
}
//called when the text field is being edited
- (IBAction)textFieldDidBeginEditing:(UITextField *)sender
{
    sender.delegate = self;
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSavePressed:(id)sender {
    
    PFObject *testObject = [PFObject objectWithClassName:@"lugares"];
    testObject[@"name"] = self.txtName.text;
    testObject[@"description"] = self.txtDescription.text;
    testObject[@"position"] = [PFGeoPoint geoPointWithLatitude:[self.txtLatitude.text floatValue] longitude:[self.txtLongitude.text floatValue]];
    [testObject saveInBackground];
}

- (IBAction)btnCameraPressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)btnReelPressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.imgPhoto.image = chosenImage;
    [self.btnPhoto setTitle: @"" forState:UIControlStateNormal];
    self.vwAcquire.hidden = YES;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)btnPhotoPressed:(id)sender {
    self.vwAcquire.hidden = NO;
}

- (IBAction)btnCloseAcquire:(id)sender {
    self.vwAcquire.hidden = YES;
}

- (IBAction)btnLostFocus:(id)sender {
    [[self view] endEditing:YES];
}
@end
