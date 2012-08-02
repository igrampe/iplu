//
//  MainViewController.m
//  iPlu
//
//  Created by Sema Belokovsky on 18.07.12.
//  Copyright (c) 2012 Sema Belokovsky. All rights reserved.
//

#import "MainViewController.h"
#import "TimelineCell.h"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	m_oAuthViewController = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	if ([[[PluConnector instance] tokenKey] length] < 1) {
		[self presentModalViewController:m_oAuthViewController animated:YES];
	} else {
		NSMutableDictionary *dict = [NSMutableDictionary new];
		NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
		NSNumber *timestampObject = [NSNumber numberWithDouble:timestamp];
		NSString *timestampString = [NSString stringWithFormat:@"%d",[timestampObject intValue]];
		srand (time(NULL));
		NSString *onceString = [NSString stringWithFormat:@"%d",rand()%1000000000];
		[dict setValue:onceString forKey:@"oauth_nonce"];
		[dict setValue:timestampString forKey:@"oauth_timestamp"];
		[dict setValue:@"tG0lk2XlB63h" forKey:@"oauth_consumer_key"];
		[dict setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
		[dict setValue:@"1.0" forKey:@"oauth_version"];
		[dict setValue:[[PluConnector instance] tokenKey] forKey:@"oauth_token"];
		PluCommand *command = [[PluCommand alloc] initWithString:@"APP/Timeline/getPlurks"];
		[[PluConnector instance] pluCommand:command withParameters:dict delegate:self];
	}
}

#pragma mark - PluConnector Delegate

- (void)pluCommandFailed:(NSString *)request
{
	
}

- (void)pluCommand:(NSString *)request finishedWithResult:(NSObject *)result
{
	NSLog(@"result:\n%@",result);
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [@"TimelineCell" stringByAppendingFormat:@"_%d_%d", indexPath.section, indexPath.row];
	TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TimelineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	return cell;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

#pragma mark - UITableView Delegate


@end
