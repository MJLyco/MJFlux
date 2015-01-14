//
//  ThreadsViewController.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ThreadsViewController.h"
#import "ChatDispatcher.h"
#import "UnreadThreadStore.h"
#import "ThreadStore.h"
#import "Thread.h"
#import "ChatAPIUtil.h"

@interface ThreadsViewController ()

@property (nonatomic, strong) NSArray *threads;

@end

@implementation ThreadsViewController

- (void)dealloc
{
    [[ThreadStore store] removeChangeListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refresh];

    self.threads = [NSArray arrayWithArray:[ThreadStore threadsChrono]];

    self.navigationController.tabBarItem.badgeValue = ([UnreadThreadStore count] == 0) ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)[UnreadThreadStore count]];

    __weak typeof(self)weakSelf = self;

    [[ThreadStore store] addChangeListener:self usingBlock:^{

        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf handleThreadChange];

            if (![ChatAPIUtil isRefreshing])
            {
                [strongSelf refreshFinished];
            }
        }

    }];

    [[UnreadThreadStore store] addChangeListener:self usingBlock:^{

        __strong typeof(self)strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.navigationController.tabBarItem.badgeValue = ([UnreadThreadStore count] == 0) ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)[UnreadThreadStore count]];
        }

    }];

    [ChatAPIUtil getAllMessages];
    [refresh beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MJPayload *payload = [MJPayload payloadWithType:ChatPayloadTypeLeaveThread andInfo:nil];
    [[ChatDispatcher dispatcher] dispatch:payload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self refreshFinished];
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

- (void)handleThreadChange
{
    NSArray *chronoThreads = [ThreadStore threadsChrono];

    NSMutableArray *deletedThreads = [NSMutableArray arrayWithArray:self.threads];
    [deletedThreads removeObjectsInArray:chronoThreads];
    NSUInteger changeCount = (deletedThreads.count > 0) ? 1 : 0;

    NSMutableArray *addedThreads = [NSMutableArray arrayWithArray:chronoThreads];
    [addedThreads removeObjectsInArray:self.threads];
    changeCount += (addedThreads.count > 0) ? 1 : 0;

    NSMutableArray *updatedThreads = [NSMutableArray arrayWithCapacity:self.threads.count];
    if (changeCount < 2)
    {
        for (Thread *thread in self.threads)
        {
            Thread *masterThread = [ThreadStore threads][thread.identifier];
            if (masterThread != nil && thread.lastMessage != masterThread.lastMessage)
            {
                [updatedThreads addObject:thread];
            }
        }
        changeCount += (updatedThreads.count > 0) ? 1 : 0;
    }

    if (changeCount > 1)
    {
        self.threads = [NSArray arrayWithArray:chronoThreads];
        [self.tableView reloadData];
    }
    else if (deletedThreads.count > 0)
    {
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:deletedThreads.count];
        for (Thread *thread in deletedThreads)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.threads indexOfObject:thread] inSection:0]];
        }
        self.threads = [NSArray arrayWithArray:chronoThreads];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else if (addedThreads.count > 0)
    {
        [self.tableView beginUpdates];
        self.threads = [NSArray arrayWithArray:chronoThreads];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:addedThreads.count];
        for (Thread *thread in addedThreads)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.threads indexOfObject:thread] inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else if (updatedThreads.count > 0)
    {
        [self.tableView beginUpdates];
        self.threads = [NSArray arrayWithArray:chronoThreads];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:updatedThreads.count];
        for (Thread *thread in updatedThreads)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:[self.threads indexOfObject:thread] inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        self.threads = [NSArray arrayWithArray:chronoThreads];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreadCell" forIndexPath:indexPath];
    Thread *thread = self.threads[indexPath.row];
    cell.textLabel.text = thread.lastMessage.authorName;
    cell.detailTextLabel.text = thread.lastMessage.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Thread *thread = self.threads[indexPath.row];
    MJPayload *payload = [MJPayload payloadWithType:ChatPayloadTypeTapThread andInfo:@{@"threadID": thread.identifier}];
    [[ChatDispatcher dispatcher] dispatch:payload];
    [self performSegueWithIdentifier:@"threadTapped" sender:nil];
}

@end
