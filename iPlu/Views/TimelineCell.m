//
//  TimelineCell.m
//  iPlu
//
//  Created by Semen Belokovsky on 09.08.12.
//  Copyright (c) 2012 Semen Belokovsky. All rights reserved.
//

#import "TimelineCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorsProvider.h"

@implementation TimelineCell

@synthesize cellView;
@synthesize avatar;
@synthesize name;
@synthesize content;
@synthesize qualifier;
@synthesize responseCount;
@synthesize avatarTapRecognizer;

@synthesize popup;
@synthesize isPopup;
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
			self.isPopup = NO;
			
			self.name.font = [UIFont fontWithName:@"Ubuntu-R" size:16];
			
			[self.avatar.layer setMasksToBounds:YES];
			[self.avatar.layer setBorderColor:[UIColor grayColor].CGColor];
			[self.avatar.layer setBorderWidth:1];
			[self.avatar.layer setCornerRadius:30.0];
			
			[self.qualifier.layer setCornerRadius:10];
			
			[self.responseCount.layer setCornerRadius:10.0];
			self.responseCount.textColor = [UIColor whiteColor];
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
	NSLog(@"avatar tap");
	[m_delegate timelineCell:self touchedWithEvent:kTimelineCellEventAvatarTapped];
}

- (IBAction)cellTapped:(id)sender
{
	[m_delegate timelineCell:self touchedWithEvent:kTimelineCellEventCellTapped];
}

- (void)showPopup:(BOOL)animated
{
	popup.delegate = self;
	[popup updateView];
	if (animated) {
		popup.frame = self.avatar.frame;
		[self.cellView addSubview:popup.view];
		[self.cellView insertSubview:avatar aboveSubview:popup.view];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		popup.frame = CGRectMake(self.avatar.frame.origin.x, self.avatar.frame.origin.x, 300, 60);
		[UIView commitAnimations];
	} else {
		[self.cellView addSubview:popup.view];
		[self.cellView insertSubview:avatar aboveSubview:popup.view];
		popup.frame = CGRectMake(self.avatar.frame.origin.x, self.avatar.frame.origin.x, 300, 60);
	}
	isPopup = YES;
}

- (void)hidePopup:(BOOL)animated
{
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		popup.frame = self.avatar.frame;
		[UIView commitAnimations];
		
	} else {
		popup.frame = self.avatar.frame;
		[popup.view removeFromSuperview];
		//popup.delegate = nil;
		popup = nil;
	}
	isPopup = NO;
}

- (void)updateView
{
	self.content.text = self.plurk.contentRaw;
	
	
	NSString *qualifierTranslated = self.plurk.qualifierTranslated;
	NSString *qualifierString = self.plurk.qualifier;
	
	if ([qualifierTranslated isEqualToString:@""]) {
		self.qualifier.hidden = YES;
	} else {
		NSString *firstCapChar = [[qualifierTranslated substringToIndex:1] capitalizedString];
		NSString *cappedString = [qualifierTranslated stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
		self.qualifier.text = cappedString;
		self.qualifier.hidden = NO;
		self.qualifier.backgroundColor = (UIColor *)[[ColorsProvider sharedInstance]
													 colorForKey:qualifierString
													 inPalette:@"qualifierPalette"];
	}
	if ([self.plurk.responseCount intValue] == 0) {
		self.responseCount.hidden = YES;
	} else {
		self.responseCount.hidden = NO;
		self.responseCount.text = [self.plurk.responseCount stringValue];
		if ([self.plurk.responseCount isEqualToNumber:self.plurk.responsesSeen]) {
			self.responseCount.backgroundColor = [UIColor colorWithRed:0
																 green:0
																  blue:0
																 alpha:0.25];
		} else {
			self.responseCount.backgroundColor = [UIColor colorWithRed:0
																 green:0
																  blue:0
																 alpha:0.75];
		}
	}
}

#pragma mark - Popup Delegate

- (BOOL)isMuted
{
	return ([self.plurk.isUnread intValue] == 2) ? YES : NO;
}

- (BOOL)isPromoted
{
	return NO;
}

- (BOOL)isReplurked
{
	return [self.plurk.replurked boolValue];
}

- (BOOL)isLiked
{
	return [self.plurk.favorite boolValue];
}

@end
