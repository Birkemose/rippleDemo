//
//  HelloWorldLayer.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCChangeScaleWithoutPositionChangeCenter.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
    //[layer setScale:0.5f];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        float scaleRTT = 4.0f;
        // --------------------------------------------------------------------------
        // create ripple sprite
        // --------------------------------------------------------------------------
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        float texWidth = screenSize.width/scaleRTT;
        float texHeight = screenSize.height/scaleRTT;
        CCRenderTexture * tex = [CCRenderTexture renderTextureWithWidth:texWidth   height:texHeight];
        tex.position = ccp(texWidth/(2.0f), texHeight/(2.0f));
        [[tex.sprite texture] setAntiAliasTexParameters];
        
        
        CCSprite * spr = [CCSprite spriteWithFile:@"image.png"];
        spr.position = ccp(tex.position.x, tex.position.y);
        
        [self addChild:tex];
        
        
        [tex beginWithClear:0 g:0 b:0 a:1]; 
        [spr setFlipY:YES];
        [spr setScale:1.0f/scaleRTT];
        [[spr texture] setAntiAliasTexParameters];
        [spr visit];
        [tex end];
        
        rippleImage = [ pgeRippleSprite ripplespriteWithRTT:tex scaleFactor:scaleRTT];
        [self addChild:rippleImage ];
        [tex removeFromParentAndCleanup:YES];
        
        scaleRTT = 1;
        
        rippleImage.position = ccp(screenSize.width/2 - (texWidth*scaleRTT)/(2.0f), screenSize.height/2 - (texHeight*scaleRTT)/(2.0f));
        rippleImage.scale=scaleRTT;
        [[rippleImage texture] setAntiAliasTexParameters];
        
        //rippleImage.visible=NO;
        
        
        // --------------------------------------------------------------------------
        
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Cocos2D Forum" fontName:@"Marker Felt" fontSize:16];
		label.position = ccp( 80 , 300 );
		[self addChild: label];
        
        FPSLabel = [CCLabelTTF labelWithString:@"FPS" fontName:@"Marker Felt" fontSize:16];
		FPSLabel.position = ccp( 80 , 100 );
		[self addChild: FPSLabel];
        
        
        // schedule update
        [ self schedule:@selector( update: ) ];    
        
	}
	return self;
}

-(void) onEnterTransitionDidFinish
{
	CCDirectorIOS *director =  (CCDirectorIOS*)[CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0  swallowsTouches:YES];
    
    //CMLog(@"...%s...", __PRETTY_FUNCTION__);
	[super onEnterTransitionDidFinish];
}

- (void)onExit
{
	CCDirectorIOS *director =  (CCDirectorIOS*)[CCDirector sharedDirector];
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}	

float runtime = 0;

-( BOOL )ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
    return( YES );
}

-( void )ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

-( void )update:( ccTime )dt {
    
    runtime += dt;
    [ rippleImage update:dt ];
    
    [FPSLabel setString: [NSString stringWithFormat:@"%0.1f", 1.f/dt] ];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
