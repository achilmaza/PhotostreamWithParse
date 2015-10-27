//
//  DAO.h
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/20/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface DAO : NSObject

@property (nonatomic, strong) NSMutableArray * data;

+(instancetype)sharedDAOInstance;
-(BOOL)isValidUser;
-(void)reset;

-(void)uploadPhoto:(UIImage*)image completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler;
-(void)deletePhoto:(NSUInteger)index completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler;
-(void)getThumbnail:(NSUInteger)index completionHandler:(void (^)(NSData*data, NSError*error))completionHandler;
-(void)getPhoto:(NSUInteger)index completionHandler:(void (^)(NSData*data, NSError*error))completionHandler;
-(void)logoutUserWithCompletionHandler:(void (^)(NSError*error))completionHandler;
-(void)loadPhotosWithCompletionHandler:(void (^)(void))completionHandler;
-(void)signupUser:(NSString*)username password:(NSString*)password email:(NSString*)email completionHandler:(void (^)(BOOL succeeded, NSError*error))completionHandler;
-(void)loginUser:(NSString*)username password:(NSString*)password completionHandler:(void (^)(NSError*error))completionHandler;


@end
