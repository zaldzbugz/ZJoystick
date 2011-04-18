//
//  Joystick.h
//  BalloonJourney
//
//  Created by Zaldy on 1/25/11.
//  Copyright 2011 PODD Media. All rights reserved.
//


#import "cocos2d.h"

typedef enum {
	kJLowerLeft,
	kLowerRight,
}tJoystickPlacement;

typedef enum {
	kFirstQuadrant,
	kSecondQuadrant,
	kThirdQuadrant,
	kFourthQuadrant,
}tControlQuadrant;

@protocol ZJoystickDelegate<NSObject>

@optional
-(void)joystickControlBegan;
-(void)joystickControlMoved;
-(void)joystickControlEnded;
//version 1.3
-(void)joystickControlDidUpdate:(id)joystick toXSpeedRatio:(CGFloat)xSpeedRatio toYSpeedRatio:(CGFloat)ySpeedRatio;
@end

#define kJoystickRadius 50.0f
#define kControlActionInterval 0.2f

@interface ZJoystick : CCSprite <CCTargetedTouchDelegate>{
	CCTexture2D				*_normalTexture;            //background normal (container)
	CCTexture2D				*_selectedTexture;          //background selected (container)
	NSString				*_controllerSpriteFile;     //controller sprite sfile
	
	tControlQuadrant		_controlQuadrant;           //quadrant where your controller is
	CCSprite				*_controller;               //controller sprite
	BOOL					isCurrentlyControlling;     //check if we touched inside the container
    BOOL                    _isJostickDisabled;         //Check if joystick is enabled
	BOOL					_isControlling;             //check if joystick is currently controlling
	id <ZJoystickDelegate>	_delegate;                  //delegate
	CGFloat					_controllerActualDistance;  //actual distance of controller relative to background and container
	CGFloat					_speedRatio;                //speed ratio for each joysitkc controller movement
	CGPoint					_controllerActualPoint;     //controller actual point relative to background
	id						_controlledObject;          //the object the controller is controlling
    
    //version 1.2
    CGFloat                 _joystickRadius;
    int                     _joystickTag;
}

@property(nonatomic, retain) CCTexture2D				*normalTexture;
@property(nonatomic, retain) CCTexture2D				*selectedTexture;
@property(nonatomic, retain) NSString					*controllerSpriteFile;

@property(nonatomic, assign) BOOL						isControlling;
@property(nonatomic, assign) BOOL                       isJostickDisabled;

@property(nonatomic, assign) CCSprite					*controller;
@property(nonatomic, assign) tControlQuadrant			controlQuadrant;
@property(nonatomic, retain) id <ZJoystickDelegate>		delegate;
@property(nonatomic, assign) CGFloat					controllerActualDistance;
@property(nonatomic, assign) CGFloat					speedRatio;
@property(nonatomic, assign) CGPoint					controllerActualPoint;
@property(nonatomic, retain) id							controlledObject;

//version 1.2
@property(nonatomic, assign) CGFloat                    joystickRadius;
@property(nonatomic, assign) int                        joystickTag;

-(CGRect) getBoundingRect;
-(CGFloat)getYMinimumLimit;
-(CGFloat)getYMaximumLimit;
-(CGFloat)getXMinimumLimit;
-(CGFloat)getXMaximumLimit;

+(id)joystickNormalSpriteFile:(NSString *)filename1 
		   selectedSpriteFile:(NSString *)filename2 
		 controllerSpriteFile:(NSString *)controllerSprite;
-(void)deactivateScheduler;;
@end
