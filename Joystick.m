//
//  Joystick.m
//  BalloonJourney
//
//  Created by Zaldy on 1/25/11.
//  Copyright 2011 PODD Media. All rights reserved.
//

#import "Joystick.h"

@interface Joystick (PrivateMethods)
CGFloat getDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2);
@end

@implementation Joystick
@synthesize normalTexture			= _normalTexture;
@synthesize selectedTexture			= _selectedTexture;
@synthesize controllerSpriteFile	= _controllerSpriteFile;

@synthesize controller				= _controller;
@synthesize delegate				= _delegate;
@synthesize isControlling			= _isControlling;
@synthesize isJostickDisabled        = _isJostickDisabled;
@synthesize controlQuadrant			= _controlQuadrant;
@synthesize controllerActualDistance= _controllerActualDistance;
@synthesize speedRatio				= _speedRatio;
@synthesize controllerActualPoint	= _controllerActualPoint;
@synthesize controlledObject		= _controlledObject;

//m = y2-y1 / x2-x1
CGFloat getSlope(CGPoint point1, CGPoint point2) {
	
	if (point2.x <= 1.0f && point2.x >= -1.0f) {
		//point2.x = 1.0f;
	}
	
	CGFloat my = point2.y - point1.y;
	CGFloat mx = point2.x - point1.x;
	CGFloat m = my/mx;
	
	if (m == INFINITY || m == -INFINITY) {
		//CCLOG(@"INFINITE");
		//m = 2;
	}
	
	return m;
};

//b = y - mx
//y = mx + b
//we dont need b since b = 0 always
//distance  = sqrt((X2 - X1)^2 + )
CGPoint getCPoint(CGFloat slope, CGFloat distance) {
	
	//y = mx + b
	//b = 0
	CGFloat x = sqrt(((distance * distance) / (1 + (slope*slope))));
	CGFloat y = slope * x;
	return CGPointMake(x, y);
};

CGFloat getDistanceBetweenTwoPoints(CGPoint point1,CGPoint point2)
{
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	return sqrt(dx*dx + dy*dy );
};

-(CGRect) getBoundingRect
{
	CGSize size = [self contentSize];
	size.width	*= scaleX_;
	size.height *= scaleY_;
	return CGRectMake(position_.x - size.width * anchorPoint_.x, 
					  position_.y - size.height * anchorPoint_.y, 
					  size.width, size.height);
}

tControlQuadrant getQuadrantForPoint (CGPoint point) {

	tControlQuadrant controlQuadrant;
	
	//Quadrants setup
	if (point.x >= 0 && point.y >= 0) {
		controlQuadrant = kFirstQuadrant;
	} else if (point.x >= 0 && point.y < 0) {
		controlQuadrant = kSecondQuadrant;
	} else if (point.x < 0 && point.y >= 0) {
		controlQuadrant = kThirdQuadrant;
	} else if (point.x < 0 && point.y < 0) {
		controlQuadrant = kFourthQuadrant;
	}
	
	return controlQuadrant;
};

-(CGFloat)getYMinimumLimit {
	CCSprite *l_controlledObject = (CCSprite *)_controlledObject;
	CGSize  cSize  = l_controlledObject.contentSize;
	return cSize.height/2;
}

-(CGFloat)getYMaximumLimit {
	CGSize winSize  = [CCDirector sharedDirector].winSize;
	CCSprite *l_controlledObject = (CCSprite *)_controlledObject;
	CGSize  cSize  = l_controlledObject.contentSize;
	
	return winSize.height - cSize.height/2;
}

-(CGFloat)getXMinimumLimit {
	CCSprite *l_controlledObject = (CCSprite *)_controlledObject;
	CGSize  cSize  = l_controlledObject.contentSize;
	return cSize.width/2;
}

-(CGFloat)getXMaximumLimit {
	CGSize winSize  = [CCDirector sharedDirector].winSize;
	CCSprite *l_controlledObject = (CCSprite *)_controlledObject;
	CGSize  cSize  = l_controlledObject.contentSize;
	return winSize.width - cSize.width/2;
}

#pragma mark -

#pragma mark Scheduler methods
-(void)activateScheduler {
	[self schedule:@selector(update:)];
}

-(void)deactivateScheduler {
	[self unschedule:@selector(update:)];
}

#pragma mark -
#pragma mark Set Timers For Objects to move
-(void)update:(ccTime) dt {
	CCSprite *l_controlledObject = (CCSprite *)_controlledObject;
	
	CGPoint cPoint = l_controlledObject.position;
	
	CGFloat xMinLimit = [self getXMinimumLimit];
	CGFloat xMaxLimit = [self getXMaximumLimit];
	
	CGFloat yMinLimit = [self getYMinimumLimit];
	CGFloat yMaxLimit = [self getYMaximumLimit];
	
	//N = point * 1 / kJoystickRadius
	CGFloat xSpeedRatio = _controllerActualPoint.x / kJoystickRadius;
	CGFloat ySpeedRatio = _controllerActualPoint.y / kJoystickRadius;
	
	//BORDERS
	//X limits
	if (cPoint.x < xMinLimit) {
		if (xSpeedRatio < 0) {
			xSpeedRatio = 0;
		}
	} else if (cPoint.x > xMaxLimit) {
		if (xSpeedRatio > 0) {
			xSpeedRatio = 0;
		}
	}
	
	//Y limits
	if (cPoint.y < yMinLimit) {
		if (ySpeedRatio < 0) {
			ySpeedRatio = 0;
		}
	} else if (cPoint.y > yMaxLimit) {
		if (ySpeedRatio > 0) {
			ySpeedRatio = 0;
		}
	}
	
    //if we dont set speed ration, we give it deafault value to 1
    if (_speedRatio == 0) {
        _speedRatio = 1;
    }
    
    xSpeedRatio = xSpeedRatio * _speedRatio;
    ySpeedRatio = ySpeedRatio * _speedRatio;
    
	//position object
	l_controlledObject.position = ccp(l_controlledObject.position.x + xSpeedRatio, l_controlledObject.position.y + ySpeedRatio);
	
	/*
	//check if our object does not reach the screen borders
	if (cPoint.x >= xMinLimit && cPoint.x <= xMaxLimit && cPoint.y >= yMinLimit && cPoint.y <= yMaxLimit) {
		//N = point * 1 / kJoystickRadius
		CGFloat xSpeedRatio = _controllerActualPoint.x / kJoystickRadius;
		CGFloat ySpeedRatio = _controllerActualPoint.y / kJoystickRadius;
		
		l_controlledObject.position = ccp(l_controlledObject.position.x + xSpeedRatio, l_controlledObject.position.y + ySpeedRatio);
	}
	 */
}

+(id)joystickNormalSpriteFile:(NSString *)filename1 selectedSpriteFile:(NSString *)filename2 controllerSpriteFile:(NSString *)controllerSprite{
	
	Joystick *joystick		= [[[self alloc] initWithFile:filename2] autorelease];
	joystick.normalTexture	= [[CCTextureCache sharedTextureCache] addImage:filename1];
	joystick.selectedTexture= [[CCTextureCache sharedTextureCache] addImage:filename2];
	joystick.controllerSpriteFile = controllerSprite;
	return joystick;
}

#pragma mark -
#pragma mark Touches
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
	CCLOG(@"Joystick ccTouchBegan");
    CGPoint location	= [touch locationInView: [touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	//CGRect rect			= [self getBoundingRect];
	
    //check if we already have touched the background
    //and check if our jostick is enabled
	if (isCurrentlyControlling || _isJostickDisabled ) {
        CCLOG(@"Joystick Disabled");
		return NO;
	}
	
	CGPoint actualPoint = CGPointMake(location.x - self.position.x, location.y - self.position.y);
	
	//actual distance of joystick and the touch point
	//this is when the touch is inside the joystick
	CGFloat actualPointDistance = getDistanceBetweenTwoPoints(self.position, location);
	
	//check if the touch point is within the joystick container's radius
	if (actualPointDistance <= kJoystickRadius){
	//if (CGRectContainsPoint(rect, location)) {
		CCLOG(@"Joystick Touched");
		
		[_delegate joystickControlBegan];	//call delegate method
		
		//Speed ratio
		//distance of joystick center point to touch point
		self.controllerActualDistance = getDistanceBetweenTwoPoints(self.position, location);
		
		//Point Ratio
		self.controllerActualPoint = actualPoint;
		
		//Quadrants
		self.controlQuadrant = getQuadrantForPoint(actualPoint);
		
		//set touch began to YES
		isCurrentlyControlling = YES;
		
		//change joystick to normal image
		//CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JoystickContainer_norm.png"];
		//[self setDisplayFrame:frame];
		[self setTexture:_normalTexture];
		
		//jostick button controller
		_controller.position = ccp(self.contentSize.width/2 + actualPoint.x, self.contentSize.height/2 + actualPoint.y);

		//add fadeIn animation
		id inAction = [CCFadeIn actionWithDuration:kControlActionInterval];
		[_controller runAction:inAction];
		
		CCLOG(@"POINT DISTANCE - %f", getDistanceBetweenTwoPoints(self.position, location));
		
		self.isControlling = YES;			//our joystick is now controlling
		
		//Activate Scheduler
		[self activateScheduler];
		
		
	}
	
	CCLOG(@"Quadrant = %d", _controlQuadrant);
	

	
	return YES; //we return yes to gain access control of MOVE and ENDED delegate methods
}

 - (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
	CCLOG(@"Joystick ccTouchMoved");
	CGPoint location	= [touch locationInView: [touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
	//CGRect rect			= [self getBoundingRect];

	
	CGPoint actualPoint = CGPointMake(location.x - self.position.x, location.y - self.position.y);
	
	
	 
	if (isCurrentlyControlling) {
		
		//execute our delegate method
		[_delegate joystickControlMoved];
		
		//actual distance of joystick and the touch point
		//this is when the touch is inside the joystick
		CGFloat actualPointDistance = getDistanceBetweenTwoPoints(self.position, location);
		
		//check if touch is inside the 
		if (actualPointDistance <= kJoystickRadius){
			//if (CGRectContainsPoint(rect, location)) {
			
			//Speed ratio
			//distance of joystick center point to touch point
			self.controllerActualDistance = actualPointDistance;
			
			//Point Ratio
			self.controllerActualPoint = actualPoint;
			
			//jostick button controller
			_controller.position = ccp(self.contentSize.width/2 + actualPoint.x, self.contentSize.height/2 + actualPoint.y);
			//call delegate method
			
		} else {
			//CCLOG(@"JOYSTICK POSITION = (%f, %f)", self.position.x, self.position.y);
			//CCLOG(@"TOUCH POSITION = (%f, %f)", location.x, location.y);
			//CCLOG(@"RELATIVE TOUCH AND JOYSTICK POSITION = (%f, %f)", actualPoint.x, actualPoint.y);
			
			//Speed ratio
			//radius of joystick
			self.controllerActualDistance = kJoystickRadius;
			
			//we compute our SLOPE 
			//Slope are the same in ever points that passes the slope line
			CGFloat slope = getSlope(CGPointMake(0, 0), actualPoint);
			//CCLOG(@"SLOPE VALUE = %f",slope);
			
			CGPoint point;
			
			//X = 0 or -0
			//if we have an Infinite slope result 
			//means that we are in the 4th Quadrant
			if (slope == -INFINITY) {
				point = ccp(0 , -kJoystickRadius);
			//3rd Quadrant
			} else if (slope == INFINITY) {
				point = ccp(0 , kJoystickRadius);
			//1st & 2nd Quadrant
			} else {
				//no matter if SLOPE and DISTANCE are (-), it would still result a positive value since they are computed by ^2
				point = getCPoint(slope, kJoystickRadius);
			}
			
			//X > or < 0
			//We check our actual points if we reach points of in 3rd Quadrant
			if (actualPoint.x < 0 && actualPoint.y >= 0) {
				point = CGPointMake(-1 * point.x, point.y * -1);
			//We check our actual points if we reach points of in 4th Quadrant
			} else if (actualPoint.x < 0 && actualPoint.y <= 0) {
				point = CGPointMake(-1 * point.x, -1 * point.y);
			}
			
			//we add the position of joystick since we need to position the controller surrounding the joystick
			CGPoint controllerPoint = CGPointMake(point.x + self.contentSize.width/2, point.y + self.contentSize.height/2);
			
			//CCLOG(@"POINT VALUE = (%f, %f)", point.x, point.y);
			//CCLOG(@"SQUAREROOT of 1 = %f",sqrt(1.0f));		
			//CCLOG(@"CONTROLLER POSITION (%f, %f)",controllerPoint.x, controllerPoint.y);
			
			//Point Ratio
			self.controllerActualPoint = point;
			
			//we position out controller
			_controller.position = controllerPoint;
		}
	
		//Quadrants
		self.controlQuadrant = getQuadrantForPoint(actualPoint);
		
		
	}
	
	//CCLOG(@"Quadrant = %d", _controlQuadrant);
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CCLOG(@"Joystick ccTouchEnded");
	
	[_delegate joystickControlEnded];			//call delegate method
	
	//change joystick to transparent image
	//CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"JoystickContainer_trans.png"];
	//[self setDisplayFrame:frame];
	[self setTexture:_selectedTexture];
	
	//to avoid fading out everytime touch is ended anywhere.
	if (isCurrentlyControlling) {
		//use fadeOut action to fade the controller
		id outAction = [CCFadeOut actionWithDuration:kControlActionInterval];
		[_controller runAction:outAction];
	}
	
	//set the boolean if touched inside to NO
	isCurrentlyControlling	= NO;
	
	self.isControlling	= NO;				//our joystick has stopped controlling
	
	//Deactivate Scheduler
	[self deactivateScheduler];
	
	
}

#pragma mark -
#pragma mark OnEnter & OnExit
- (void)onEnter
{	
	CCLOG(@"onEnter");
	[super onEnter];
	
	self.isControlling = NO; //initially our joystick should stop controlling
	
	//we add joystick button sprite initialy
	self.controller		= nil;
	self.controller		= [CCSprite spriteWithFile:_controllerSpriteFile];
	_controller.position= ccp(-200, -200);
	_controller.opacity	= 0.0f;
	[self addChild:_controller];
	
	//we call touch dispatcher to swallow touches
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
													 priority:0 
											  swallowsTouches:YES];
}

- (void)onExit
{
	CCLOG(@"onExit");
	[self removeChild:_controller cleanup:YES];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super onExit];
}

#pragma mark -
-(void)dealloc {
	
	self.controllerSpriteFile = nil;
	self.normalTexture      = nil;
	self.selectedTexture    = nil;
	self.controlledObject   = nil;
	self.delegate           = nil;
   
	[super dealloc];
}

@end
