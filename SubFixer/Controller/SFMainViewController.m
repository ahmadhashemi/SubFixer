//
//  SFMainViewController.m
//  SubFixer
//
//  Created by Ahmad on 8/24/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "SFMainViewController.h"
#import "SFConverter.h"

@interface SFMainViewController ()

@property (weak) IBOutlet NSTextField *messageLabel;

@end

@implementation SFMainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMessageLabelText:) name:@"ChangeMessageLabelText" object:nil];
    
}

-(void)changeMessageLabelText:(NSNotification *)sender {
    
    NSString *message = sender.userInfo[@"Message"];
    self.messageLabel.stringValue = message;
    
}

@end
