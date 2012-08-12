//
//  TimelineCell.h
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkData.h"
#import "Popup.h"

typedef enum {
	kTimelineCellEventAvatarTapped = 0,
	kTimelineCellEventCellTapped = 1,
	kShare = 2
}TimelineCellEvent;

@class TimelineCell;

@protocol TimelineCellDelegate <NSObject>

- (void)timelineCell:(TimelineCell *)timelineCell touchedWithEvent:(TimelineCellEvent)event;

@end

@interface TimelineCell : UITableViewCell <PopupDelegate> {
	id<TimelineCellDelegate> m_delegate;
}

@property (nonatomic, retain) IBOutlet UIView *cellView;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *qualifier;
@property (nonatomic, retain) IBOutlet UILabel *responseCount;

@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *avatarTapRecognizer;
@property (nonatomic, retain) IBOutlet UITapGestureRecognizer *cellTapRecognizer;

@property (nonatomic, retain) Popup *popup;
@property (nonatomic, assign) BOOL isPopup;

@property (nonatomic, retain) PlurkData *plurk;
@property (nonatomic, assign) id<TimelineCellDelegate> delegate;

- (IBAction)avatarTapped:(id)sender;
- (IBAction)cellTapped:(id)sender;

- (void)updateView;

- (CGFloat)heightForContent;

- (void)hidePopup:(BOOL)animated;
- (void)showPopup:(BOOL)animated;

@end

