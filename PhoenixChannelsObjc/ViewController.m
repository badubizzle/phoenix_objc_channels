//
//  ViewController.m
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@end

@implementation ViewController

- (IBAction)sendMessage:(id)sender {
    NSString *text = self.messageTextField.text;
    self.messageTextField.text=@"";
    if(text.length>0){
        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [del sendMessage:text];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
