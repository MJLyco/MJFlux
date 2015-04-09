//
//  MessagesViewController.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/3/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MessagesViewController.h"
#import "ChatDispatcher.h"
#import "MessagesStore.h"
#import "ThreadStore.h"
#import "Message.h"
#import "ChatAPIUtil.h"

@interface MessagesViewController ()

@property (nonatomic, strong) NSString *messageStoreListenerID;
@property (nonatomic, strong) NSArray *messages;

@end

@implementation MessagesViewController

- (void)dealloc
{
    [[MessagesStore store] removeChangeListener:self.messageStoreListenerID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];

    self.messages = [MessagesStore messagesForThread:[ThreadStore currentThreadID]];

    __weak typeof(self)weakSelf = self;

    self.messageStoreListenerID = [[MessagesStore store] addChangeListener:self usingBlock:^{

        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf handleMessagesChange];

            if (![ChatAPIUtil isRefreshing])
            {
                [strongSelf refreshFinished];
            }
        }
        
    }];

    [ChatAPIUtil getAllMessages];
}

- (void)refresh:(UIRefreshControl *)control
{
    [control beginRefreshing];
    [ChatAPIUtil getAllMessages];
}

- (void)refreshFinished
{
    if (self.refreshControl.refreshing)
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)handleMessagesChange
{
    NSArray *chronoMessages = [MessagesStore messagesForThread:[ThreadStore currentThreadID]];

    NSMutableArray *deletedMessages = [NSMutableArray arrayWithArray:self.messages];
    [deletedMessages removeObjectsInArray:chronoMessages];

    NSMutableArray *addedMessages = [NSMutableArray arrayWithArray:chronoMessages];
    [addedMessages removeObjectsInArray:self.messages];

    if (deletedMessages.count > 0 && addedMessages.count > 0)
    {
        self.messages = [NSArray arrayWithArray:chronoMessages];
        [self.tableView reloadData];
    }
    else if (deletedMessages.count > 0)
    {
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:deletedMessages.count];
        for (Message *message in deletedMessages)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
        }
        self.messages = [NSArray arrayWithArray:chronoMessages];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else if (addedMessages.count > 0)
    {
        [self.tableView beginUpdates];
        self.messages = [NSArray arrayWithArray:chronoMessages];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:addedMessages.count];
        for (Message *message in addedMessages)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.messages indexOfObject:message] inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        self.messages = [NSArray arrayWithArray:chronoMessages];
        [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    Message *message = self.messages[indexPath.row];
    cell.textLabel.text = message.text;
    return cell;
}

@end
