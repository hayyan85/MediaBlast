//
//  MediaMgrTableCell.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/8/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MediaManagerController.h"

@interface MediaMgrTableCell : UITableViewCell

@property(nonatomic , weak) IBOutlet UIImageView* ImageAlbum;
@property(nonatomic , weak) IBOutlet UILabel* labelSongName;
@property(nonatomic , weak) IBOutlet UILabel* labelDuration;

@property(nonatomic , weak) IBOutlet UIButton* btnplay;
@property(nonatomic) BOOL isPlaying;
@property(nonatomic , weak) IBOutlet UITableView* table;
@property(nonatomic , weak) IBOutlet UIButton* btncheckstatus;
@property(nonatomic) BOOL isChecked;
@property(strong) CAGradientLayer *bgLayer;
@property(weak) id<ProtoSongSelection> delegate_song_check_status;
@property int RowNo;

- (void) Togglecheck : (NSString*) SongName  Visible : (BOOL)visible;
- (void) SetBackGroundGradient;
- (void) RemoveChecks;
- (IBAction)PlaySong:(id)sender;
- (IBAction)CheckSong:(id)sender;
- (int) TogglePlay : (NSString*) SongName;
- (void) TogglPlay : (NSString*) SongName  Visible : (BOOL) visible;
@end
