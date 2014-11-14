//
//  SecondViewController.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "SecondViewController.h"
#import "ChatStore.h"

@interface SecondViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation SecondViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.label.text = [ChatStore messages].lastObject[@"text"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatStoreUpdated) name:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeReceieveMessages] object:nil];
}

- (void)chatStoreUpdated
{
    self.label.text = [ChatStore messages].lastObject[@"text"];
}

- (IBAction)sendtapped:(id)sender
{
    if (self.textField.text.length > 0)
    {
        MJPayload *payload = [[MJPayload alloc] init];
        payload.type = ChatPayloadTypeNewMessage;
        payload.info = [ChatStore newMessage:self.textField.text];
        [[ChatDispatcher dispatcher] dispatch:payload];
        self.textField.text = nil;
        [self.textField resignFirstResponder];
    }
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self.textField resignFirstResponder];
}

@end
