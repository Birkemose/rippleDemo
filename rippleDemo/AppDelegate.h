//
//  AppDelegate.h
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCDirectorIOS;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
	UIWindow			*window_;
    UINavigationController *navController_;
    
	CCDirectorIOS	*director_;	
}

@property (nonatomic, retain) UIWindow *window;

@end
