//
//  pgeRippleSprite.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright 2011 Protec Electronics. All rights reserved.
//
// --------------------------------------------------------------------------
// import headers

#import "pgeRippleSprite.h"

// --------------------------------------------------------------------------
// implementation

@implementation pgeRippleSprite

@synthesize scaleRTT;

// --------------------------------------------------------------------------
// properties

// --------------------------------------------------------------------------
// methods
// --------------------------------------------------------------------------

+( pgeRippleSprite* )ripplespriteWithFile:( NSString* )filename {
	return [ [ [ self alloc ] initWithFile:filename ] autorelease ];
}
+( pgeRippleSprite* )ripplespriteWithRTT:( CCRenderTexture* )rtt scaleFactor:(float)scale {
    return [ [ [ self alloc ] initWithRTT:rtt scaleFactor:scale] autorelease ];
}

// --------------------------------------------------------------------------

- (CCTexture2D*) texture {
    return m_texture;
}

-(BOOL)isPointInsideSprite:(CGPoint)pos {
    float maxX = m_texture.contentSize.width/scaleRTT;
    float maxY = m_texture.contentSize.height/scaleRTT;
    
    NSLog(@"maxX = %.2f, pos.x = %.2f", maxX, pos.x);
    
    if(pos.x < 0 || pos.y < 0 || 
       pos.x > maxX || pos.y > maxY) {
        return NO;
    }
    else { 
        return YES;
    }
}

-(BOOL)isTouchInsideSprite:( UITouch* )touch {
    CGPoint pos;
    pos = [ touch locationInView: [ touch view ] ];
    pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    pos = [self convertToNodeSpace:pos];
    
    return [self isPointInsideSprite:pos];
}

-(BOOL)ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
    if(![self isTouchInsideSprite:touch]) {
        return NO;
    }
    
    [ self ccTouchMoved:touch withEvent:event ];
    return( YES );
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos;
    pos = [ touch locationInView: [ touch view ] ];
    pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    pos = [self convertToNodeSpace:pos];
    
    // [ rippleImage addRipple:pos type:RIPPLE_TYPE_RUBBER strength:1.0f ];    
    [self addRipple:pos type:RIPPLE_TYPE_WATER strength:2.0f ];  
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
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

-( pgeRippleSprite* )initWithFile:( NSString* )filename {
    self = [ super init ];
    RIPPLE_DEFAULT_RADIUS = 500 / scaleRTT;
    
    // load texture
    m_texture = [[ [ CCTextureCache sharedTextureCache ] addImage: filename ] retain];
    // reset internal data
    m_vertice = nil;
    m_textureCoordinate = nil;
    // builds the vertice and texture-coordinates arrays
    m_quadCountX = RIPPLE_DEFAULT_QUAD_COUNT_X;
    m_quadCountY = RIPPLE_DEFAULT_QUAD_COUNT_Y;
    [ self tesselate ];
    
    screenSize = ccp(m_texture.contentSize.width,m_texture.contentSize.height);
    
    shaderProgram_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
    [shaderProgram_ retain];
    
    // create ripple list
    m_rippleList = [ [ [ NSMutableArray alloc ] init ] retain ];
    // done
    return( self );
}

-( pgeRippleSprite* )initWithRTT:( CCRenderTexture* )rtt scaleFactor:(float)scale {
    self = [ super init ];
    scaleRTT = 1;
    RIPPLE_DEFAULT_RADIUS = 500 / scale;
    
    // load texture
    m_texture = [[[rtt sprite] texture] retain];
    // reset internal data
    m_vertice = nil;
    m_textureCoordinate = nil;
    // builds the vertice and texture-coordinates arrays
    m_quadCountX = RIPPLE_DEFAULT_QUAD_COUNT_X;
    m_quadCountY = RIPPLE_DEFAULT_QUAD_COUNT_Y;
    [ self tesselate ];
    
    screenSize = ccp(m_texture.contentSize.width/scaleRTT,m_texture.contentSize.height/scaleRTT);
    
    self.shaderProgram = [[CCGLProgram alloc] initWithVertexShaderFilename:@"rippleShader.vsh"
                                                    fragmentShaderFilename:@"rippleShader.fsh"];
    [self.shaderProgram release];
    
    CHECK_GL_ERROR_DEBUG();
    
    [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
    [shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    CHECK_GL_ERROR_DEBUG();
    
    [shaderProgram_ link];
    CHECK_GL_ERROR_DEBUG();
    
    [shaderProgram_ updateUniforms];
    
    // create ripple list
    m_rippleList = [ [ [ NSMutableArray alloc ] init ] retain ];
    // done
    return( self );
}

// --------------------------------------------------------------------------

-( void )draw {
    if ( self.visible == NO ) return;
    
    CC_NODE_DRAW_SETUP();
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
	
    ccGLBindTexture2D([ m_texture name ] );
    
    glUniform2f(glGetUniformLocation(shaderProgram_->program_, "phaseShiftXY"),0,0);
    glUniform1f(glGetUniformLocation(shaderProgram_->program_, "time"), runTime);
    
    // vertex
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, (void*) m_vertice);
    
    // if no ripples running, use original coordinates ( Yay, dig that kewl old school C syntax )
    //glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, ( m_rippleList.count == 0 ) ? m_textureCoordinate : m_rippleCoordinate);
    
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, (m_textureCoordinate));
    
    // draw as many triangle fans, as quads in y direction
    for ( int strip = 0; strip < m_quadCountY; strip++ ) {
        glDrawArrays( GL_TRIANGLE_STRIP, strip * m_VerticesPrStrip, m_VerticesPrStrip );
    }
}

// --------------------------------------------------------------------------

-( void )dealloc {
    rippleData* runningRipple;
    
    // clean up buffers
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );
    
    // clean up running ripples
    for ( int count = 0; count < m_rippleList.count; count ++ ) {
        
        // get a pointer and free manually, as data was allocated manually
        // a void pointer would do, but this adds readability at no expense
        runningRipple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];
        free( runningRipple );
        
    }
    
    // delete list
    [ m_rippleList release ];
    
    [m_texture release];
    
    // done
    [ super dealloc ];
}

// --------------------------------------------------------------------------
// tesselation is expensive

-( void )tesselate {
    int vertexPos = 0;
    CGPoint normalized;
    
    // clear buffers ( yeah, clearing nil buffers first time around )
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );
    
    // calculate vertices pr strip
    m_VerticesPrStrip = 2 * ( m_quadCountX + 1 );
    
    // calculate buffer size
    m_bufferSize = m_VerticesPrStrip * m_quadCountY;
    
    // allocate buffers
    m_vertice = (CGPoint*)malloc( m_bufferSize * sizeof( CGPoint ) );
    m_textureCoordinate = (CGPoint*)malloc( m_bufferSize * sizeof( CGPoint ) );
    m_rippleCoordinate = (CGPoint*)malloc( m_bufferSize * sizeof( CGPoint ) );
    m_edgeVertice = (bool*)malloc( m_bufferSize * sizeof( bool ) );
    
    // reset vertice pointer
    vertexPos = 0;
    
    // create all vertices and default texture coordinates
    // scan though y quads, and create an x-oriented triangle strip for each
    for ( int y = 0; y < m_quadCountY; y ++ ) {
        
        // x counts to quadcount + 1, because number of vertices is number of quads + 1
        for ( int x = 0; x < ( m_quadCountX + 1 ); x ++ ) {
            
            // for each x vertex, an upper and lower y position is calculated, to create the triangle strip
            // upper + lower + upper + lower
            for ( int yy = 0; yy < 2; yy ++ ) {
                
                // first simply calculate a normalized position into rectangle
                normalized.x = ( float )x / ( float )m_quadCountX;
                normalized.y = ( float )( y + yy ) / ( float )m_quadCountY;
                
                // calculate vertex by multiplying rectangle ( texture ) size
                m_vertice[ vertexPos ] = ccp( normalized.x * [ m_texture contentSize ].width/scaleRTT, normalized.y * [ m_texture contentSize ].height/scaleRTT );
                
                // adjust texture coordinates according to texture size
                // as a texture is always in the power of 2, maxS and maxT are the fragment of the size actually used
                // invert y on texture coordinates
                m_textureCoordinate[ vertexPos ] = ccp( normalized.x * m_texture.maxS, m_texture.maxT - ( normalized.y * m_texture.maxT ) );
                
                // check if vertice is an edge vertice, because edge vertices are never modified to keep outline consistent
                m_edgeVertice[ vertexPos ] = ( 
                                              ( x == 0 ) || 
                                              ( x == m_quadCountX ) ||
                                              ( ( y == 0 ) && ( yy == 0 ) ) || 
                                              ( ( y == ( m_quadCountY - 1 ) ) && ( yy > 0 ) ) );
                
                // next buffer pos
                vertexPos ++;
                
            }
        } 
    } 
}

// --------------------------------------------------------------------------
// adds a ripple to list of running ripples
// OBS
// strength of 1.0f is maximum ripple strength.
// strengths above that, might result in texture artifacts

-( void )addRipple:( CGPoint )pos type:( RIPPLE_TYPE )type strength:( float )strength {
    rippleData* newRipple;
    
    // allocate new ripple
    newRipple = (rippleData*)malloc( sizeof( rippleData ) );
    
    // initialize ripple
    newRipple->parent = YES;
    for ( int count = 0; count < 4; count ++ ) newRipple->childCreated[ count ] = NO;
    newRipple->rippleType = type;
    newRipple->center = pos;
    newRipple->centerCoordinate = ccp( pos.x / [ m_texture contentSize ].width * m_texture.maxS/scaleRTT, m_texture.maxT - ( pos.y / [ m_texture contentSize ].height * m_texture.maxT/scaleRTT ) );
    newRipple->radius = RIPPLE_DEFAULT_RADIUS; // * strength;
    newRipple->strength = strength;
    newRipple->runtime = 0;
    newRipple->currentRadius = 0;
    newRipple->rippleCycle = RIPPLE_DEFAULT_RIPPLE_CYCLE;
    newRipple->lifespan = RIPPLE_DEFAULT_LIFESPAN;
    
    // add ripple to running list 
    [ m_rippleList addObject:[ NSValue valueWithPointer:newRipple ] ];
    
    
}

// --------------------------------------------------------------------------
// adds a ripple child, to mimic bouncing ripples

-( void )addRippleChild:( rippleData* )parent type:( RIPPLE_CHILD )type {
    rippleData* newRipple;
    CGPoint pos;
    
    //CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // allocate new ripple
    newRipple = (rippleData*)malloc( sizeof( rippleData ) );
    
    // new ripple is pretty much a copy of its parent
    memcpy( newRipple, parent, sizeof( rippleData ) );
    
    // not a parent
    newRipple->parent = NO;
    
    // mirror position
    switch ( type ) {
        case RIPPLE_CHILD_LEFT:
            pos = ccp( -parent->center.x, parent->center.y );
            break;
        case RIPPLE_CHILD_TOP:
            pos = ccp( parent->center.x, screenSize.y + ( screenSize.y - parent->center.y ) );
            break;
        case RIPPLE_CHILD_RIGHT:
            pos = ccp( screenSize.x + ( screenSize.x - parent->center.x ), parent->center.y );            
            break;
        case RIPPLE_CHILD_BOTTOM:
        default:
            pos = ccp( parent->center.x, -parent->center.y );            
            break;
    }
    
    newRipple->center = pos;
    newRipple->centerCoordinate = ccp( pos.x / [ m_texture contentSize ].width * m_texture.maxS, m_texture.maxT - ( pos.y / [ m_texture contentSize ].height * m_texture.maxT ) );
    newRipple->strength *= RIPPLE_CHILD_MODIFIER;
    
    // indicate child used
    parent->childCreated[ type ] = YES;        
    
    // add ripple to running list 
    [ m_rippleList addObject:[ NSValue valueWithPointer:newRipple ] ];
}

// --------------------------------------------------------------------------
// update any running ripples
// it is parents responsibility to call the method with appropriate intervals

ccTime runTime = 0;

-( void )update:( ccTime )dt {
    
    runTime += dt;
    
    return;
    rippleData* ripple;
    CGPoint pos;
    float distance, correction;
    //CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // test if any ripples at all
    if ( m_rippleList.count == 0 ) return;
    
    // ripples are simulated by altering texture coordinates
    // on all updates, an entire new array is calculated from the base array 
    // not maintainng an original set of texture coordinates, could result in accumulated errors
    memcpy( m_rippleCoordinate, m_textureCoordinate, m_bufferSize * sizeof( CGPoint ) );
    
    // scan through running ripples
    // the scan is backwards, so that ripples can be removed on the fly
    for ( int count = ( m_rippleList.count - 1 ); count >= 0; count -- ) {
        
        // get ripple data
        ripple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];
        
        // scan through all texture coordinates
        for ( int count = 0; count < m_bufferSize; count ++ ) {
            
            // dont modify edge vertices
            if ( m_edgeVertice[ count ] == NO ) {
                
                // calculate distance
                // you might think it would be faster to do a box check first
                // but it really isnt, 
                // ccpDistance is like my sexlife - BAM! - and its all over
                distance = ccpDistance( ripple->center, m_vertice[ count ] );
                
                // only modify vertices within range
                if ( distance <= ripple->currentRadius ) {
                    
                    // load the texture coordinate into an easy to use var
                    pos = m_rippleCoordinate[ count ];  
                    
                    // calculate a ripple 
                    switch ( ripple->rippleType ) {
                            
                        case RIPPLE_TYPE_RUBBER:
                            // method A
                            // calculate a sinus, based only on time
                            // this will make the ripples look like poking a soft rubber sheet, since sinus position is fixed
                            correction = sinf( 2 * M_PI * ripple->runtime / ripple->rippleCycle );
                            break;
                            
                        case RIPPLE_TYPE_GEL:
                            // method B
                            // calculate a sinus, based both on time and distance
                            // this will look more like a high viscosity fluid, since sinus will travel with radius                            
                            correction = sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;
                            
                        case RIPPLE_TYPE_WATER:
                        default:
                            // method c
                            // like method b, but faded for time and distance to center
                            // this will look more like a low viscosity fluid, like water     
                            
                            correction = ( ripple->radius * ripple->rippleCycle / ripple->lifespan ) / ( ripple->currentRadius - distance );
                            if ( correction > 1.0f ) correction = 1.0f;
                            
                            // fade center of quicker
                            correction *= correction;
                            
                            correction *= sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;
                            
                    }
                    
                    // fade with distance
                    correction *= 1 - ( distance / ripple->currentRadius );
                    
                    // fade with time
                    correction *= 1 - ( ripple->runtime / ripple->lifespan );
                    
                    // adjust for base gain and user strength
                    correction *= RIPPLE_BASE_GAIN;
                    correction *= ripple->strength;
                    
                    // finally modify the coordinate by interpolating
                    // because of interpolation, adjustment for distance is needed, 
                    correction /= ccpDistance( ripple->centerCoordinate, pos );
                    pos = ccpAdd( pos, ccpMult( ccpSub( pos, ripple->centerCoordinate ), correction ) );
                    
                    // another approach for applying correction, would be to calculate slope from center to pos
                    // and then adjust based on this
                    
                    // clamp texture coordinates to avoid artifacts
                    pos = ccpClamp( pos, CGPointZero, ccp( m_texture.maxS, m_texture.maxT ) );
                    
                    // save modified coordinate
                    m_rippleCoordinate[ count ] = pos;
                    
                }
            }
        }
        
        // calculate radius
        ripple->currentRadius = ripple->radius * ripple->runtime / ripple->lifespan;
        
        // check if ripple should expire
        ripple->runtime += dt;
        if ( ripple->runtime >= ripple->lifespan ) {
            
            // free memory, and remove from list
            free( ripple );
            [ m_rippleList removeObjectAtIndex:count ];
            
        } else {
            
#ifdef RIPPLE_BOUNCE
            // check for creation of child ripples
            if ( ripple->parent == YES ) {
                
                // left ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_LEFT ] == NO ) && ( ripple->currentRadius > ripple->center.x ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_LEFT ];
                } 
                
                // top ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_TOP ] == NO ) && ( ripple->currentRadius > screenSize.y - ripple->center.y ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_TOP ];
                }
                
                // right ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_RIGHT ] == NO ) && ( ripple->currentRadius > screenSize.width - ripple->center.x ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_RIGHT ];
                }
                
                // bottom ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_BOTTOM ] == NO ) && ( ripple->currentRadius > ripple->center.y ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_BOTTOM ];
                } 
                
                
                
            }
#endif
            
        }
        
    }
}

// --------------------------------------------------------------------------

@end
