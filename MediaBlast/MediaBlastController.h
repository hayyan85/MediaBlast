//
//  MediaBlastController.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/6/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatButton.h"

@class CHTumblrMenuView;
@interface MediaBlastController : UIViewController
{
    
    CHTumblrMenuView *menuView;
}
@property(weak , nonatomic) IBOutlet FlatButton* buttonFlatMediaPlayer;
@property(weak , nonatomic) IBOutlet FlatButton* buttonImportMusic;
@property(weak , nonatomic) IBOutlet FlatButton* buttonPlayList;
@end
