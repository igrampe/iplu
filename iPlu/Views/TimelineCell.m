//
//  TimelineCell.m
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "TimelineCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TimelineCell
@synthesize cellView;
@synthesize avatar;
@synthesize name;
@synthesize content;
@synthesize qualifier;
@synthesize avatarTapRecognizer;
@synthesize popup;
@synthesize delegate = m_delegate;

+ (NSString *)nibName
{
	return @"TimelineCell";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		NSString *nibName = [[self class] nibName];
		if (nibName) {
			[[NSBundle mainBundle] loadNibNamed:nibName
                                          owner:self
                                        options:nil];
            NSAssert(self.cellView != nil, @"NIB file loaded but content property not set.");
            [self addSubview:self.cellView];
			isPopup = NO;
			[popup.layer setMasksToBounds:YES];
			[popup.layer setCornerRadius:25];
        }
    }
    return self;
}

- (void)dealloc {
    self.cellView = nil;
    self.name = nil;
    self.avatar = nil;
    self.content = nil;
    [super dealloc];
}

- (CGFloat)heightForContent
{
	return self.content.frame.size.height + self.content.frame.origin.y + 5;
}

- (IBAction)avatarTapped:(id)sender
{
	NSLog(@"tap");
	if (isPopup) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		popup.frame = self.avatar.frame;
		[UIView commitAnimations];
		isPopup = NO;
	} else {
		[m_delegate cell:self touchedWithAction:kPopup];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		popup.frame = CGRectMake(self.avatar.frame.origin.x, self.avatar.frame.origin.y, 300, 50);
		[UIView commitAnimations];
		isPopup = YES;
	}
}

- (void)hidePopup:(BOOL)animated
{
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		popup.frame = self.avatar.frame;
		[UIView commitAnimations];
		isPopup = NO;
	} else {
		popup.frame = self.avatar.frame;
		isPopup = NO;
	}
}

@end
