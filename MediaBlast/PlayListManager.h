//
//  PlayListManager.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlatButton;
@interface PlayListManager : UIViewController <UITableViewDataSource , UITableViewDelegate>

@property(weak , nonatomic) IBOutlet UITableView* tableView;
@property(strong , nonatomic) NSMutableArray* ArrayplayLists;
@property(weak , nonatomic) IBOutlet FlatButton* back;
@property(weak , nonatomic) IBOutlet FlatButton* Home;
-(IBAction) Goback;
@end
