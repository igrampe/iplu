//
//  Popup.m
//  iPlu
//
//  Created by Semen Belokovsky on 11.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "Popup.h"

@implementation Popup

@synthesize view;
@synthesize buttonUser;
@synthesize buttonLike;
@synthesize buttonReplurk;
@synthesize buttonPromote;
@synthesize buttonMute;

@synthesize frame;
@synthesize delegate = m_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil
{
	self = [super init];
    if (self) {
		if (nibNameOrNil) {
			[[NSBundle mainBundle] loadNibNamed:nibNameOrNil
                                          owner:self
                                        options:nil];
            NSAssert(self.view != nil, @"NIB file loaded but content property not set.");
			[view.layer setMasksToBounds:YES];
			[view.layer setCornerRadius:25];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)_frame
{
	self.view.frame = _frame;
}

- (CGRect)frame
{
	return self.view.frame;
}

- (IBAction)userTapped:(id)sender
{
	
}

- (IBAction)muteTapped:(id)sender
{
	if (((UIButton *)sender).selected) {
		((UIButton *)sender).selected = NO;
	} else {
		((UIButton *)sender).selected = YES;
	}
}

- (IBAction)likeTapped:(id)sender
{
	if (((UIButton *)sender).selected) {
		((UIButton *)sender).selected = NO;
	} else {
		((UIButton *)sender).selected = YES;
	}
}

- (IBAction)replurkTapped:(id)sender
{
	if (((UIButton *)sender).selected) {
		((UIButton *)sender).selected = NO;
	} else {
		((UIButton *)sender).selected = YES;
	}
}

- (IBAction)promoteTapped:(id)sender
{
	if (((UIButton *)sender).selected) {
		((UIButton *)sender).selected = NO;
	} else {
		((UIButton *)sender).selected = YES;
	}
}

- (void)updateView
{
	buttonMute.selected = [m_delegate isMuted];
	buttonPromote.selected = [m_delegate isPromoted];
	buttonReplurk.selected = [m_delegate isReplurked];
	buttonLike.selected = [m_delegate isLiked];
}

@end
