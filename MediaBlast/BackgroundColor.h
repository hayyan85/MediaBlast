//
//  BackgroundColor.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/14/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) blueGradient;

@end
