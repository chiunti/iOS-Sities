//
//  CustomTableViewCell.h
//  Copeo
//
//  Created by Chiunti on 18/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

@end
