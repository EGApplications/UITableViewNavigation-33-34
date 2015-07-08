//
//  EGFolderCell.h
//  UITableViewNavigation #33-34
//
//  Created by Евгений Глухов on 06.07.15.
//  Copyright (c) 2015 EGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EGFolderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *folderImage;

@property (weak, nonatomic) IBOutlet UILabel *folderName;

@property (weak, nonatomic) IBOutlet UILabel *folderSize;


@end
