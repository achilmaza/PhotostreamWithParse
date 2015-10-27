//
//  AppDelegate.m
//  photoStreamWithParse
//
//  Created by Angie Chilmaza on 10/13/15.
//  Copyright © 2015 Angie Chilmaza. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    //Must set id and client key, otherwise the app will not work
    @try{
        [Parse setApplicationId:@"" clientKey:@""];
    }
    @catch(NSException * exception){
        NSLog(@"exception = %@ \n", exception);
    }
    
    //[Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [self setupAppearance];
    

    return YES;
}

-(void)setupAppearance {
    
    UINavigationBar * navigationBarApperance = [UINavigationBar appearance];
    navigationBarApperance.barTintColor = [UIColor colorWithRed:139.0/255.0 green:165.0/255.0 blue:252.0/255.0 alpha:1.0];
    navigationBarApperance.tintColor = [UIColor whiteColor];
    navigationBarApperance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
