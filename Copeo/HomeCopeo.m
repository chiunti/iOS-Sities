//
//  ViewController.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "HomeCopeo.h"

@interface HomeCopeo ()

@end

@implementation HomeCopeo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSavePressed:(id)sender {
    
    PFObject *testObject = [PFObject objectWithClassName:@"lugares"];
    testObject[@"name"] = self.txtName.text;
    testObject[@"description"] = self.txtDescription.text;
    testObject[@"position"] = self.txtName.text;
    [testObject saveInBackground];
}
@end
