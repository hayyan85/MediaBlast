//
//  CommonFunctions.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/29/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "CommonFunctions.h"


@interface CommonFunctions ()
{
    
}
@end



@implementation CommonFunctions

+ (void) AStyleButtons : (UIButton*) btn;
{
    //Background
    UIColor* bak = [UIColor colorWithRed:96.0f/255.0f
                                   green:118.0f/255.0f
                                    blue:135.0f/255.0f
                                   alpha:1.0f];
    
    UIColor* bord = [UIColor colorWithRed:93.0f/255.0f
                                    green:106.0f/255.0f
                                     blue:117.0f/255.0f
                                    alpha:1.0f];
    
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = bak;
    btn.layer.borderColor=bord.CGColor;
    [[btn layer] setCornerRadius:4.0f];
    [[btn layer] setBorderWidth:1.0f];
}


+(void) shuffle : (NSMutableArray*) ArrSongs
{
    NSUInteger count = [ArrSongs count];
    for (uint i = 0; i < count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [ArrSongs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
