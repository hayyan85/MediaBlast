//
//  PlayListSaveController.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListSaveController : UIViewController <UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate>

@property(weak , nonatomic) NSArray* SongsSelected;
@property(weak) IBOutlet UIButton* ButtonBack;
@property(weak) IBOutlet UIButton* ButtonSave;
@property(weak) IBOutlet UITableView* tableView;
@property(weak) IBOutlet UITextField* TextPlayListName;
-(IBAction) GoBack;
-(IBAction) SavePlayList;
@end
