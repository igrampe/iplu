//
//  MainViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Nulana. All rights reserved.
//

#import "MainViewController.h"

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
	NSMutableDictionary *dict = [NSMutableDictionary new];
	[dict setValue:@"21796946" forKey:@"oauth_nonce"];
	[dict setValue:@"1343476614" forKey:@"oauth_timestamp"];
	[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
	[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[dict setValue:@"1.0" forKey:@"oauth_version"];
	PluCommand *command = [[PluCommand alloc] initWithString:@"OAuth/request_token"];
	[[PluConnector instance] pluCommand:command withParameters:dict delegate:self];
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
