//
//  ViewController.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "EditCopeo.h"
#import "Defaults.h"
#import "MBProgressHUD.h"

UIAlertView *alertError, *alertGuardar;
float     mlatitude;
float     mlongitude;


@interface EditCopeo ()

@end

@implementation EditCopeo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initController];
    // --------------------- location
    
    self.locationManager   = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.location = [[CLLocation alloc] init];
    self.locationManager.desiredAccuracy  = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
}

-(void)initController
{
    self.vwAcquire.hidden = true;
    if (currentState==Insert) {
        // Nuevo registro
        self.navTitle.title = @"Agregar lugar";
        [self.btnPhoto setTitle: @"Foto" forState:UIControlStateNormal];
        
        // poner valores nuevos
        self.txtName.text        = @"";
        self.txtDescription.text = @"";
        self.txtLatitude.text    = @"";
        self.txtLongitude.text   = @"";
        self.imgPhoto.image = [[UIImage alloc] init];
        
    } else {
        // registro existente
        self.navTitle.title = @"Editar lugar";
        [self.btnPhoto setTitle: @"" forState:UIControlStateNormal];
        
        //Leer datos del currentObject
        self.txtName.text        = currentObject[@"name"];
        self.txtDescription.text = currentObject[@"description"];
        PFGeoPoint *point =currentObject[@"position"];
        self.txtLatitude.text    = [[NSString alloc] initWithFormat:@"%f", [point latitude]];
        self.txtLongitude.text   = [[NSString alloc] initWithFormat:@"%f", [point longitude]];
        PFFile *img = currentObject[@"photo"];
        self.imgPhoto.image = [UIImage imageWithData:[img getData]];
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
    BOOL showAlert = false;
    CGImageRef cgref = [self.imgPhoto.image CGImage];
    CIImage    *cim  = [self.imgPhoto.image CIImage];

    if (cim==nil&&cgref==NULL) {
        self.btnPhoto.layer.borderColor = [[UIColor redColor] CGColor];
        showAlert = true;
    } else {
        self.btnPhoto.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    if ([self.txtName.text length]==0) {
        showAlert = true;
        self.txtName.layer.borderWidth = 1;
        self.txtName.layer.borderColor = [[UIColor redColor] CGColor];
    } else {
        self.txtName.layer.borderWidth = 0;
    }
    if ([self.txtDescription.text length]==0) {
        showAlert = true;
        self.txtDescription.layer.borderWidth = 1;
        self.txtDescription.layer.borderColor = [[UIColor redColor] CGColor];
    } else {
        self.txtDescription.layer.borderWidth = 0;
    }
    if ([self.txtLatitude.text length]==0) {
        showAlert = true;
        self.txtLatitude.layer.borderWidth = 1;
        self.txtLatitude.layer.borderColor = [[UIColor redColor] CGColor];
    } else {
        self.txtLatitude.layer.borderWidth = 0;
    }
    if ([self.txtLongitude.text length]==0) {
        showAlert = true;
        self.txtLongitude.layer.borderWidth = 1;
        self.txtLongitude.layer.borderColor = [[UIColor redColor] CGColor];
    } else {
        self.txtLongitude.layer.borderWidth = 0;
    }
    
    
    if (showAlert) {
        [alertError show];
        return;
    }

    
    if (currentState == Insert) {
    
        currentObject = [PFObject objectWithClassName:@"lugares"];
    }
    
    currentObject[@"name"] = self.txtName.text;
    currentObject[@"description"] = self.txtDescription.text;
    currentObject[@"position"] = [PFGeoPoint geoPointWithLatitude:[self.txtLatitude.text floatValue] longitude:[self.txtLongitude.text floatValue]];
    
    
    NSData *imageData = UIImageJPEGRepresentation(self.imgPhoto.image, 0.8);
    NSString *filename = [NSString stringWithFormat:@"%@.png", self.txtName.text];
    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
    
    currentObject[@"photo"] = imageFile;
    
    [self saveDataWithObject:currentObject];
}

-(void)saveDataWithObject:(PFObject *)testObject
{
    
    //[testObject saveInBackground];
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Actualizando";
    [hud show:YES];
    
    // Upload recipe to Parse
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        
        if (!error) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Actualización completa" message:@"Lugar de copeo guardado" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            // Notify table view to reload the recipes from Parse cloud
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getLugares" object:self];
            
            // Dismiss the controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fallo la actualización" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }];
  
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

//---------------------------------------------------------------------------------------------
// Localization
//---------------------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = locations.lastObject;
    //NSLog( @"didUpdateLocation!");
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         mlatitude = self.locationManager.location.coordinate.latitude;
         mlongitude = self.locationManager.location.coordinate.longitude;
         //NSLog(@"lat = %f", mlatitude);
         //NSLog(@"lon = %f", mlongitude);
         [self.locationManager stopUpdatingLocation];
         if (currentState==Insert) {
             self.txtLatitude.text = [[NSString alloc] initWithFormat:@"%f", mlatitude];
             self.txtLongitude.text = [[NSString alloc] initWithFormat:@"%f", mlongitude];
         }
     }];
}


@end
