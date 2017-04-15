//
//  MediaManagerController.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/6/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DBManager.h"


@class MediaMgrTableCell;
@class MediaPlayer;
@class FlatButton;

@protocol ProtoSongSelection <NSObject>
- (void) SongCheckActivity : (NSString*) SongName andCheckStatus : (BOOL) status;
- (void) PlaySong : (NSString*) songName UsingMediaMgrTableCell:(MediaMgrTableCell*) cell;
@end




@interface MediaManagerController : UIViewController <UITableViewDataSource,UITableViewDelegate,ProtoSongSelection>
{
    IBOutlet UISearchBar* SearchBar;
    BOOL isFiltered;
    NSArray* dirPaths;
}

@property int RowBeingPlayed;
@property(weak) CAGradientLayer *bgLayer;
@property(weak , nonatomic) IBOutlet UITableView *tableViewObject;

@property(nonatomic, strong)  NSMutableArray* tableData;                   //Contains the actual tableData
@property (strong, nonatomic) NSMutableArray* filteredTableData;    //Contains the filterTable data

@property(nonatomic,  strong) NSMutableArray* ArraySongNamePath;
@property(nonatomic,  strong) DBManager *dbManager;
@property(nonatomic,  strong) NSMutableArray *SongsChecked;
@property(weak , nonatomic) IBOutlet UIView*   PlayListView;
@property(weak , nonatomic) IBOutlet FlatButton* ButtonDelete;
@property(weak , nonatomic) IBOutlet FlatButton* ButtonHome;
@property(weak , nonatomic) IBOutlet FlatButton* ButtonShuffle;
@property(weak , nonatomic) IBOutlet FlatButton* ButtonCreatePlayList;
@property(strong,nonatomic) MediaPlayer* mplayer;

- (void) SongCheckActivity : (NSString*) SongName andCheckStatus : (BOOL) status;
- (void) PlaySong : (NSString*) songName UsingMediaMgrTableCell:(MediaMgrTableCell*) cell;
- (void) BackHere;
- (void) BackFromPlayListSaved;
-(void) SongChanged : (NSString*) SongName;

-(IBAction)BackHome:(id)sender;
-(IBAction)DeleteFiles:(id)sender;
-(IBAction)CreatePlayList:(id)sender;
-(IBAction)shuffle:(id)sender;
@end
