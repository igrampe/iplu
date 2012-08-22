//
//  Popup.h
//  iPlu
//
//  Created by Semen Belokovsky on 11.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	kPopupHorizontalOrientation = 0,
	kPopupVerticalOrientation
} PopupOrientation;

@protocol PopupDelegate <NSObject>

- (BOOL)isMuted;
- (BOOL)isPromoted;
- (BOOL)isReplurked;
- (BOOL)isLiked;

@end

@interface Popup : NSObject {
	id<PopupDelegate> m_delegate;
	UIView *m_view;
	CGFloat m_width;
	CGFloat m_height;
	CGRect m_frame;
	NSMutableArray *m_buttons;
}

@property (nonatomic, assign) id<PopupDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *buttons;

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIButton *buttonMute;

@property (nonatomic, assign) CGRect frame;


- (id)initWithNibName:(NSString *)nibNameOrNil;

- (IBAction)muteTapped:(id)sender;

- (void)updateView;
- (void)buttonTouched:(UIControl *)sender;

@end
