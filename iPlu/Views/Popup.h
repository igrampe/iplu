//
//  Popup.h
//  iPlu
//
//  Created by Semen Belokovsky on 11.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol PopupDelegate <NSObject>

- (BOOL)isMuted;
- (BOOL)isPromoted;
- (BOOL)isReplurked;
- (BOOL)isLiked;

@end

@interface Popup : NSObject {
	id<PopupDelegate> m_delegate;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIButton *buttonUser;
@property (nonatomic, retain) IBOutlet UIButton *buttonLike;
@property (nonatomic, retain) IBOutlet UIButton *buttonReplurk;
@property (nonatomic, retain) IBOutlet UIButton *buttonPromote;
@property (nonatomic, retain) IBOutlet UIButton *buttonMute;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) id<PopupDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil;

- (IBAction)userTapped:(id)sender;
- (IBAction)likeTapped:(id)sender;
- (IBAction)replurkTapped:(id)sender;
- (IBAction)promoteTapped:(id)sender;
- (IBAction)muteTapped:(id)sender;

- (void)updateView;

@end
