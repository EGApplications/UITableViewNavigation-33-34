//
//  EGFileCell.h
//  UITableViewNavigation #33-34
//
//  Created by Евгений Глухов on 07.07.15.
//  Copyright (c) 2015 EGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

@property (weak, nonatomic) IBOutlet UILabel *fileName;

@property (weak, nonatomic) IBOutlet UILabel *fileSize;

@property (weak, nonatomic) IBOutlet UILabel *fileDate;


@end
