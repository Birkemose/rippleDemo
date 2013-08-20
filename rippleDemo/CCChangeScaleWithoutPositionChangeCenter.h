//
//  CCChangeScaleWithoutPositionChangeCenter.h
//  rippleDemo
//
//  Created by Goffredo Marocchi on 2/3/12.
//  Copyright (c) 2012 IGGS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCActionInstant.h"
#import "cocos2d.h"

@interface CCChangeScaleWithoutPositionChangeCenter : CCActionInstant <NSCopying>
{
    CGPoint newScale;
}
+(id) actionWithScale: (CGPoint) scale;
-(id) initWithScale:(CGPoint) scale;
-(void) startWithTarget:(id)aTarget;
@end

