//
//  LoginViewController.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/13/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "LoginViewController.h"
#import "DAO.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;
- (IBAction)login:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTextFieldDelegates];
    self.activityIndicator.alpha = 0.0;
    
    BOOL validUser = [[DAO sharedDAOInstance] isValidUser];
    if(validUser){
        [self performSegueWithIdentifier:@"showPhotoStreamFromLogin" sender:self];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.usernameField.text = @"";
    self.passwordField.text = @"";
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self resignFirstResponderAllFields];
    
}


- (IBAction)login:(id)sender {
    
    [self resignFirstResponderAllFields];
    
    NSString * username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([username length] == 0 ||
      [password length] == 0){
        
         [self alertView:@"" withMsg:@"Make sure fields are not blank"];
    }
    else{
        
        DAO * dao = [DAO sharedDAOInstance];
        
        [self showActivityIndicator];
        
        [dao loginUser:username password:password completionHandler:^(NSError*error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideActivityIndicator];
                
                if(error){
                    
                    [self alertView:@"Login Error" withMsg:[error.userInfo objectForKey:@"error"]];
                }
                else{
                    
                    [self performSegueWithIdentifier:@"showPhotoStreamFromLogin" sender:self];
                }
            
            });
            
            
        }];
    }
}


-(void)alertView:(NSString*)title withMsg:(NSString*)msg{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:^{}];
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self login:self];
    return YES;
}

#pragma mark TextField Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self resignFirstResponderAllFields]; //get rid of keyboard
}

-(void) resignFirstResponderAllFields{
    
    [self.view endEditing:YES];
}

-(void) setupTextFieldDelegates{
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
}

-(void) clearTextFields{

    self.usernameField.text = @"";
    self.passwordField.text = @"";

}

#pragma mark ActivityIndicator

-(void) showActivityIndicator {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.activityIndicator setAlpha:1.0];
    }
    completion:^(BOOL finished) {
                         
        [self.activityIndicator startAnimating];
    }];
    
}

-(void) hideActivityIndicator {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.activityIndicator setAlpha:0.0];
    }
    completion:^(BOOL finished) {
                         
        [self.activityIndicator stopAnimating];
    }];
    
}



@end
