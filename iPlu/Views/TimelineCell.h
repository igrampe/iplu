//
//  TimelineCell.h
//  iPlu
//
//  Created by Sema Belokovsky on 02.08.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UITextView *contentView;

@end
