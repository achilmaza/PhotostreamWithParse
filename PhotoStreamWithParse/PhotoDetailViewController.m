//
//  PhotoDetailViewController.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/25/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "PhotoDetailViewController.h"

@interface PhotoDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)done:(id)sender;


@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageWithData:self.imageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


@end
