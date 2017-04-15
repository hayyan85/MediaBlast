//
//  PlayListPlayController.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaManagerController.h"

@class MediaMgrTableCell;


@interface PlayListPlayController : UIViewController <UITableViewDataSource , UITableViewDelegate ,ProtoSongSelection>
{
    
    NSArray* dirPaths;
}

@property int RowBeingPlayed;
@property (weak , nonatomic) IBOutlet UITableView* tableview;
@property (weak , nonatomic) IBOutlet FlatButton* buttonBack;
@property (weak , nonatomic) IBOutlet FlatButton* buttonSavePlayList;
@property (weak , nonatomic) IBOutlet FlatButton* buttonShuffle;
@property (strong , nonatomic) NSMutableArray* ArraySongs;
@property (strong , nonatomic) NSMutableArray* ArraySongNamePath; //Dictionary (SongName, Path)
@property(strong) NSString* PlayListName;
@property(strong,nonatomic) MediaPlayer* MediaPlayerViewController;
-(IBAction) GoBack;
- (void) BackHere;
-(void) SongChanged : (NSString*) SongName;
-(IBAction)SavePlayListOrder:(id)sender;
-(IBAction)ShufflePlayList:(id)sender;
@end
