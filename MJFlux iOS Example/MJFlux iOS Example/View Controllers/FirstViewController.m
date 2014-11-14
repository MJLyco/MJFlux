//
//  FirstViewController.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "FirstViewController.h"
#import "ChatStore.h"

@interface FirstViewController ()

@property (nonatomic, strong) NSArray *messages;

@end

@implementation FirstViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

    [self setRefreshControl:refresh];

    self.messages = [NSArray arrayWithArray:[ChatStore messages]];

    self.navigationController.tabBarItem.badgeValue = ([ChatStore newMessageCount] == 0) ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)[ChatStore newMessageCount]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatStoreUpdated) name:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeReceieveMessages] object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFinished) name:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeGetChats] object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MJPayload *payload = [[MJPayload alloc] init];
    payload.type = ChatPayloadTypeClickThread;
    [[ChatDispatcher dispatcher] dispatch:payload];
}

- (void)refresh:(UIRefreshControl *)control
{
    [control beginRefreshing];
    MJPayload *payload = [[MJPayload alloc] init];
    payload.type = ChatPayloadTypeGetChats;
    [[ChatDispatcher dispatcher] dispatch:payload];
}

- (void)refreshFinished
{
    if (self.refreshControl.refreshing)
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)chatStoreUpdated
{
    if ([ChatStore newMessageCount] > 0 && self.tabBarController.selectedIndex == 0)
    {
        // delay because we're in the dispatch loop
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MJPayload *payload = [[MJPayload alloc] init];
            payload.type = ChatPayloadTypeClickThread;
            [[ChatDispatcher dispatcher] dispatch:payload];
        });
    }
    else
    {
        NSMutableArray *deletedMessages = [NSMutableArray arrayWithArray:self.messages];
        [deletedMessages removeObjectsInArray:[ChatStore messages]];

        NSMutableArray *addedMessages = [NSMutableArray arrayWithArray:[ChatStore messages]];
        [addedMessages removeObjectsInArray:self.messages];

        if (deletedMessages.count > 0 && addedMessages.count > 0)
        {
            self.messages = [NSArray arrayWithArray:[ChatStore messages]];
            [self.tableView reloadData];
        }
        else if (deletedMessages.count > 0)
        {
            [self.tableView beginUpdates];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:deletedMessages.count];
            for (NSDictionary *message in deletedMessages)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
            }
            self.messages = [NSArray arrayWithArray:[ChatStore messages]];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else if (addedMessages.count > 0)
        {
            [self.tableView beginUpdates];
            self.messages = [NSArray arrayWithArray:[ChatStore messages]];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:addedMessages.count];
            for (NSDictionary *message in addedMessages)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else
        {
            self.messages = [NSArray arrayWithArray:[ChatStore messages]];
            [self.tableView reloadData];
        }

        self.navigationController.tabBarItem.badgeValue = ([ChatStore newMessageCount] == 0) ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)[ChatStore newMessageCount]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.messages[indexPath.row][@"text"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MJPayload *payload = [[MJPayload alloc] init];
    payload.type = ChatPayloadTypeDeleteMessage;
    payload.info = self.messages[indexPath.row];
    [[ChatDispatcher dispatcher] dispatch:payload];
}

@end
