//
//  CCChangeScaleWithoutPositionChangeCenter.m
//  rippleDemo
//
//  Created by Goffredo Marocchi on 2/3/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import "CCChangeScaleWithoutPositionChangeCenter.h"

@implementation CCChangeScaleWithoutPositionChangeCenter

+(id) actionWithScale: (CGPoint) scale
{
    return [[[self alloc] initWithScale:scale]autorelease];
}

-(id) initWithScale:(CGPoint) scale
{
    if( (self=[super init]) )
    {
        newScale = scale;
        
    }
    return self;
}

-(id) copyWithZone: (NSZone*) zone
{
    CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithScale:newScale];
    return copy;
}

-(void) startWithTarget:(id)aTarget
{
    [super startWithTarget:aTarget];
    
    CCNode *node=(CCNode*) aTarget;
    
    CGPoint oldDistance=ccp(0.f,0.f),newDistance=oldDistance,translate=oldDistance;
    
    newScale.x = (newScale.x == 0.f) ? node.scaleX : newScale.x;
    newScale.y = (newScale.x == 0.f) ? node.scaleY : newScale.y;        
    
    if (node.anchorPoint.x != 0.5f)
    {
        oldDistance.x=(0.5f-node.anchorPoint.x)*node.contentSize.width*node.scaleX;
        newDistance.x=(0.5f-node.anchorPoint.x)*node.contentSize.width*newScale.x;
    }    
    
    if (node.anchorPoint.y !=0.5f)
    {
        oldDistance.y=(0.5f-node.anchorPoint.y)*node.contentSize.height*node.scaleY;
        newDistance.y=(0.5f-node.anchorPoint.y)*node.contentSize.height*newScale.y;
    }
    
    translate= ccpSub(newDistance,oldDistance);
    
    node.scaleX=newScale.x;
    node.scaleY=newScale.y;
    
    [node setPosition:ccpSub(node.position,translate)];
}
@end
