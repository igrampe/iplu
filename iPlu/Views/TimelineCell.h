//
//  TimelineCell.h
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkData.h"

typedef enum {
	kPopup = 0,
	kShare = 1
}TimelineCellAction;

@protocol TimelineCellDelegate <NSObject>

- (void)cell:(UITableViewCell *)cell touchedWithAction:(TimelineCellAction)action;

@end

@interface TimelineCell : UITableViewCell <UIGestureRecognizerDelegate> {
	BOOL isPopup;
	id<TimelineCellDelegate> m_delegate;
}

@property (nonatomic, retain) IBOutlet UIView *cellView;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *qualifier;
@property (nonatomic, retain) IBOutlet UIGestureRecognizer *avatarTapRecognizer;
@property (nonatomic, retain) IBOutlet UIView *popup;

@property (nonatomic, retain) PlurkData *plurk;
@property (nonatomic, assign) id<TimelineCellDelegate> delegate;

- (IBAction)avatarTapped:(id)sender;

- (CGFloat)heightForContent;

- (void)hidePopup:(BOOL)animated;

@end

