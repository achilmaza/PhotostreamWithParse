//
//  SignupViewController.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/13/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "SignupViewController.h"
#import "DAO.h"

@interface SignupViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;

- (IBAction)signup:(id)sender;
-(void)alertView:(NSString*)title withMsg:(NSString*)msg;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTextFieldDelegates];
    self.activityIndicator.alpha = 0.0;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIImage * buttonImage = [UIImage imageNamed:@"circle-left-gray.png"];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self clearTextFields];
}



- (IBAction)signup:(id)sender {
    
    [self resignFirstResponderAllFields];
    
    NSString * username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([username length] == 0 ||
       [password length] == 0 ||
       [email length] == 0){
        
        [self alertView:@"" withMsg:@"Make sure fields are not blank"];
    }
    else{
        
        DAO * dao = [DAO sharedDAOInstance];
        
        [self showActivityIndicator];
        [dao signupUser:username password:password email:email completionHandler:^(BOOL succeeded, NSError* error){
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideActivityIndicator];
                
                if(error){
                    [self alertView:@"Sign Up Error" withMsg:[error.userInfo objectForKey:@"error"]];
                }
                else{
                    
                    [self performSegueWithIdentifier:@"showPhotoStreamFromSignup" sender:self];
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
    [self signup:self];
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
    self.emailField.delegate = self;
}

-(void) clearTextFields{
    
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    self.emailField.text = @"";
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
