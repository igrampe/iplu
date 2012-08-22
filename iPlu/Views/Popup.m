//
//  Popup.m
//  iPlu
//
//  Created by Semen Belokovsky on 11.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "Popup.h"

@implementation Popup

@synthesize view = m_view;
@synthesize buttons = m_buttons;

@synthesize frame = m_frame;
@synthesize delegate = m_delegate;
@synthesize buttonMute;

- (id)initWithOrientation:(PopupOrientation)orientation
{
	self = [super init];
	if (self) {
		m_view = [[UIView alloc] init];
		[m_view.layer setMasksToBounds:YES];
		[m_view.layer setCornerRadius:25];
		m_buttons = [NSMutableArray new];
		if (orientation == kPopupHorizontalOrientation) {
			m_width = 300;
			m_height = 50;
		} else {
			m_width = 50;
			m_height = 300;
		}
	}
	return self;
}

- (void)dealloc
{
	[m_buttons release];
	[m_view release];
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
{
	self = [super init];
    if (self) {
		if (nibNameOrNil) {
			[[NSBundle mainBundle] loadNibNamed:nibNameOrNil
                                          owner:self
                                        options:nil];
            NSAssert(self.view != nil, @"NIB file loaded but content property not set.");
			[m_view.layer setMasksToBounds:YES];
			[m_view.layer setCornerRadius:25];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
	m_frame = frame;
	m_width = frame.size.width;
	m_height = frame.size.height;
	self.view.frame = frame;
}

- (CGRect)frame
{
	return m_frame;
}

- (IBAction)muteTapped:(id)sender
{
	if (((UIButton *)sender).selected) {
		((UIButton *)sender).selected = NO;
	} else {
		((UIButton *)sender).selected = YES;
	}
}

- (void)updateView
{
	self.buttonMute.selected = [m_delegate isMuted];
}

- (void)buttonTouched:(UIControl *)sender
{
	
}

@end
