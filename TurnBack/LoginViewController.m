//
//  ViewController.m
//  TurnBack
//
//  Created by Ezequiel Dev on 11/23/15.
//  Copyright © 2015 Ezequiel Dev. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController () <FBSDKLoginButtonDelegate>
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:_buttonView.frame];
    loginButton.delegate = self;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_likes", @"user_location", @"user_tagged_places"];
    [self.view addSubview:loginButton];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Facebook Button Delegate
-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"Logout");
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSLog(@"Login ok: %@", result.grantedPermissions);
}

@end
