//
//  HelloWorldLayer.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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

        // --------------------------------------------------------------------------
        // create ripple sprite
        // --------------------------------------------------------------------------

        rippleImage = [ pgeRippleSprite ripplespriteWithFile:@"image.png" ];
        [ self addChild:rippleImage ];

        // --------------------------------------------------------------------------
        
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Cocos2D Forum" fontName:@"Marker Felt" fontSize:16];
		label.position = ccp( 80 , 300 );
		[self addChild: label];
        
        // enable touch
        [ [ CCTouchDispatcher sharedDispatcher ] addTargetedDelegate:self priority:0 swallowsTouches:YES ];	
        
        // schedule update
        [ self schedule:@selector( update: ) ];    
                
	}
	return self;
}

float runtime = 0;

-( BOOL )ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
    runtime = 0.1f;
    [ self ccTouchMoved:touch withEvent:event ];
    return( YES );
}

-( void )ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos;
    
    if ( runtime >= 0.1f ) {
        
        runtime -= 0.1f;
        
        // get touch position and convert to screen coordinates
        pos = [ touch locationInView: [ touch view ] ];
        pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    
        // [ rippleImage addRipple:pos type:RIPPLE_TYPE_RUBBER strength:1.0f ];    
        [ rippleImage addRipple:pos type:RIPPLE_TYPE_WATER strength:2.0f ];  
        
        
    }
}

-( void )update:( ccTime )dt {
    
    runtime += dt;
    
    [ rippleImage update:dt ];
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
