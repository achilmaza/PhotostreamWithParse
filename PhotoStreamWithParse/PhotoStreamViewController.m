//
//  ViewController.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/13/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "PhotoStreamViewController.h"
#import "PhotoStreamCell.h"
#import "PhotoDetailViewController.h"


@interface PhotoStreamViewController ()


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIImagePickerController * imagePicker;
@property(nonatomic, strong) DAO * dao;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)selectPhoto:(id)sender;
- (IBAction)logout:(id)sender;


@end

@implementation PhotoStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.activityIndicator.alpha = 0.0;
    self.dao = [DAO sharedDAOInstance];
    
    BOOL validUser = [self.dao isValidUser];
    
    if(validUser){
        [self showActivityIndicator];
    
        [self.dao loadPhotosWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.collectionView reloadData];
                [self hideActivityIndicator];
            });
        }];
    }
    
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    
    
    //Setup gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    
    longPress.numberOfTouchesRequired = 1;
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    
    
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
       
}

#pragma mark Lazy Loading 

-(UIImagePickerController*)imagePicker{
    
    if(!_imagePicker){
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    return _imagePicker;
}


#pragma mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [[self.dao data] count];
}

-(PhotoStreamCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"CollectionViewCell";
    
    PhotoStreamCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
   //set thumbnail
   //cell.imageView.image;
    cell.imageView.image = [UIImage imageNamed:@"default-image"];
    
    [self.dao getThumbnail:[indexPath row] completionHandler:^(NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:data];
        });
        
    }];
    
    return cell;
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.dao getPhoto:[indexPath row] completionHandler:^(NSData*data, NSError*error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(error){
                
                [self alertView:@"Load error" withMsg:[error.userInfo objectForKey:@"error"]];
            }
            else{
                
                if(data){
                    [self performSegueWithIdentifier:@"showPhotoDetail" sender:data];
                }
            }
        });
        
    }];
    
}

#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"showPhotoDetail"]){
        
        PhotoDetailViewController * vc = (PhotoDetailViewController*)segue.destinationViewController;
        [vc setImageData:sender];
    }
    
    
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self showActivityIndicator];
    [self.dao uploadPhoto:image completionHandler:^(BOOL succeeded, NSError*error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self hideActivityIndicator];
            
            NSInteger index = (NSInteger)([[self.dao data] count] - 1);
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(NSInteger)index inSection:0];
            
            //load thumbnail
            NSArray * indexPathArray = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.collectionView insertItemsAtIndexPaths:indexPathArray];
            
        });
        
    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark IBAction

- (IBAction)logout:(id)sender {

    [self showActivityIndicator];
    [self.dao logoutUserWithCompletionHandler:^(NSError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideActivityIndicator];
            
            if(error){
                [self alertView:@"Logout Error" withMsg:[error.userInfo objectForKey:@"error"]];
            }
            else{
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        });
    }];
    
}

- (IBAction)selectPhoto:(id)sender {
    
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}


#pragma mark Alert

-(void)alertView:(NSString*)title withMsg:(NSString*)msg{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:^{}];
    
}


#pragma mark UITextFieldDelegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES]; //get rid of keyboard
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

#pragma mark LongPressGestureRecognizer

-(void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Delete Photo?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         
                                                         [self showActivityIndicator];
                                                         
                                                         [self.dao deletePhoto:[indexPath row] completionHandler:^(BOOL succeeded, NSError*error){
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 [self hideActivityIndicator];
                                                                 
                                                                 if(error){
                                                                     [self alertView:@"Delete error" withMsg:[error.userInfo objectForKey:@"error"]];
                                                                 }
                                                                 else{
                                                                     
                                                                     if(succeeded){
                                                                          NSArray* deleteCells = [[NSArray alloc] initWithObjects:indexPath, nil];
                                                                         [self.collectionView deleteItemsAtIndexPaths:deleteCells];
                                                                         
                                                                     }
                                                                 }
                                                                 
                                                                 
                                                             });
                                                             
                                                         }];
                                                         
                                                     }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //do nothing
                                                         }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}


@end
