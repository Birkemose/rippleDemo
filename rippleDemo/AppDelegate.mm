//
//  AppDelegate.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"

@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];					
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];									
	[director_ setDisplayStats:NO];																
	[director_ setAnimationInterval:1.0/30];	
    
    //[director_ setProjection:kCCDirectorProjection2D];
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]								
                                     pixelFormat:kEAGLColorFormatRGB565							
                                     depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */				
                              preserveBackbuffer:NO												
                                      sharegroup:nil												
                                   multiSampling:NO												
                                 numberOfSamples:0												
                          ];
    [__glView setMultipleTouchEnabled:YES];
	[director_ setView:__glView];																
	[director_ setDelegate:self];																
	director_.wantsFullScreenLayout = YES;														
	[director_ enableRetinaDisplay:YES];	
    //director_.displayStats=YES;
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];		
	navController_.navigationBarHidden = YES;													
	[window_ addSubview:navController_.view];													
	[window_ makeKeyAndVisible];	
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
    [director_ pushScene: [HelloWorldLayer scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)dealloc {
    [window_ release];
	[navController_ release];
    
	[super dealloc];
}

@end
