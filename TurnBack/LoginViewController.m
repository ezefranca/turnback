//
//  ViewController.m
//  TurnBack
//
//  Created by Ezequiel Dev on 11/23/15.
//  Copyright © 2015 Ezequiel Dev. All rights reserved.
//

#import "LoginViewController.h"
#import "DevicesViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (strong, nonatomic) IBOutlet UIView *facebookButtonFrame;
@end



@implementation LoginViewController
@synthesize facebookButtonFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    // Optional: Place the button in the center of your view.
//    loginButton.center = self.view.center;
//    loginButton.delegate = self;
//    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_likes", @"user_location", @"user_tagged_places"];
//    [self.view addSubview:loginButton];
    
    
    DevicesViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"devicesVC"];
    [self presentViewController:viewController animated:YES completion:nil];
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
    DevicesViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"devicesVC"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
