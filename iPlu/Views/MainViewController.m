//
//  MainViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import "MainViewController.h"
#import "OAuthLoginViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	OAuthLoginViewController *m_oAuthViewController = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
	self.view = m_oAuthViewController.view;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pluCommandFailed:(NSString *)request
{
	
}

- (void)pluCommand:(NSString *)request finishedWithResult:(NSObject *)result
{
	NSLog(@"lol");
}

@end
