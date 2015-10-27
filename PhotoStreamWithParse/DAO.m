//
//  DAO.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/20/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "DAO.h"
#import <Parse/Parse.h>
#import "UIImage+ResizeAdditions.h"

@interface DAO ()


@end

@implementation DAO


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableArray alloc] init];
    }
    return self;
}

//singleton
+(instancetype)sharedDAOInstance {
    
    static id _sharedDAOInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedDAOInstance = [[self alloc] init];
    });
    
    return _sharedDAOInstance;
}


-(BOOL)isValidUser{
    
    PFUser * currentUser = [PFUser currentUser];
    if(currentUser){
        NSLog(@"Current user = %@ \n", currentUser);
        return TRUE;
    }
    
    //[currentUser isAuthenticated]
    
    return FALSE;
}


-(void)logoutUserWithCompletionHandler:(void (^)(NSError*error))completionHandler{
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        
        if(!error){
            [self reset];
        }
        
        completionHandler(error);
    }];

}

-(void)loginUser:(NSString*)username password:(NSString*)password completionHandler:(void (^)(NSError*error))completionHandler{
    
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                        
        completionHandler(error);
                                
    }];
    
}

-(void)signupUser:(NSString*)username password:(NSString*)password email:(NSString*)email completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler{
    
    
    //What happens if a user already exists? Parse checks for that
    //How to validate email to it's proper form? Parse checks
    //How to enforce a specific password format ?
    
    PFUser * newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email    = email;

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
       
        completionHandler(succeeded, error);

    }];
    
}


-(void)loadPhotosWithCompletionHandler:(void (^)(void))completionHandler{
    
    //query
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"Photo"];
    [photosFromCurrentUserQuery whereKey:@"ownerKey" equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:@"thumbnailImageKey"];
    
    [photosFromCurrentUserQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        [self.data removeAllObjects];
        [self.data addObjectsFromArray:objects];
        completionHandler();
        
    }];
    
}


-(void)deletePhoto:(NSUInteger)index completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler{
    
    PFObject * object = [self.data objectAtIndex:index];
    
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    
       if(succeeded){
           [self.data removeObjectAtIndex:index];
       }
    
       completionHandler(succeeded, error);
        
    }];

    
}

-(void)getPhoto:(NSUInteger)index completionHandler:(void (^)(NSData*data, NSError*error))completionHandler{
    
    PFObject * object = [self.data objectAtIndex:index];
    PFFile * file = object[@"fullImageKey"];
    
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        
        completionHandler(data, error);
    }];
    
}

-(void)getThumbnail:(NSUInteger)index completionHandler:(void (^)(NSData*data, NSError*error))completionHandler{

    
    PFObject * object = [self.data objectAtIndex:index];
    PFFile * file = object[@"thumbnailImageKey"];
    
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        completionHandler(data, error);
    }];
    
}

-(void)uploadPhoto:(UIImage*)image completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler{
    
    
    NSData * fullImageData = UIImageJPEGRepresentation(image,0.7f);
    
    UIImage *thumbnailImage = [image  thumbnailImage:96.0f
                                    transparentBorder:0.0f
                                        cornerRadius:5.0f
                                 interpolationQuality:kCGInterpolationDefault];
    NSData * thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    
    PFFile * fullImageFile = [PFFile fileWithData:fullImageData];
    PFFile * thumbnailImageFile = [PFFile fileWithData:thumbnailImageData];
    
    if(fullImageFile && thumbnailImageFile){
        
        [fullImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if(succeeded){
                
                [thumbnailImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if(succeeded){
                        PFObject * photo = [PFObject objectWithClassName:@"Photo"];
                        [photo setObject:[PFUser currentUser] forKey:@"ownerKey"];
                        [photo setObject:fullImageFile forKey:@"fullImageKey"];
                        [photo setObject:thumbnailImageFile forKey:@"thumbnailImageKey"];
                        
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            if(succeeded){
                                [self.data addObject:photo];
                            }
                            
                            completionHandler(succeeded, error);
                            
                        }];
                        
                    }else{
                        
                        completionHandler(succeeded, error);
                    }
                    
                }];
                
            }else{
                completionHandler(succeeded, error);
            }
            
        }];
    }
    else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Error uploading image", nil),
                                   NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"Error uploading image", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Error uploading image", nil)
                                   };
        
        NSError * error = [NSError errorWithDomain:@"PhotoStreamErrorDomain" code:-1 userInfo:userInfo];
        completionHandler(false, error);
    }
    
}


-(void)reset{
    
    [self.data removeAllObjects];
}


@end
