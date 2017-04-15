//
//  MediaPlayer.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/12/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ASValueTrackingSlider.h"
#import "AGMedallionView.h"


@class FlatButton;
typedef enum PlayState {EnumStart , EnumStop , EnumPause} Playerstate;

@protocol VolumeResultProtocol <NSObject>
- (void) VolumeNo : (NSNumber*) volume ;
@end


@interface MediaPlayer : UIViewController <AVAudioPlayerDelegate , ASValueTrackingSliderDataSource , VolumeResultProtocol>
-(void)dealloc;
@property (nonatomic, strong)AVAudioPlayer *player;
@property(weak , nonatomic) IBOutlet UILabel* LabelPlayTime;
@property(weak , nonatomic) IBOutlet UILabel* LabelSongInProgress;
@property(weak , nonatomic) IBOutlet ASValueTrackingSlider* sliderProgress;
@property(strong , nonatomic) IBOutlet UIView* sliderVolumeView;
@property (nonatomic, weak)IBOutlet UIView* MediaImageView;
@property (nonatomic,weak) IBOutlet UIView* ViewPlayButtonHost;
@property (nonatomic, weak)IBOutlet FlatButton* ButtonBack;
@property (nonatomic, weak)IBOutlet FlatButton* ButtonNextTrack;
@property (nonatomic, weak)IBOutlet UIButton* ButtonPlay;
@property (nonatomic, weak)IBOutlet UIButton* ButtonPause;
@property (nonatomic, strong)AGMedallionView* medallionView;
@property (nonatomic, strong)NSTimer* RunningTimer;
@property(strong) CAGradientLayer *bgLayer;
@property BOOL isSongPaused;
@property BOOL RepeatEnabled;


//---------------------------------------------------------------------------------------------
//------------Thee fields must be received from the calling form-------------------------------
//---------------------------------------------------------------------------------------------
@property(weak) NSMutableArray* MusicCollectionPath;      //Array of (SongName,Path)
@property(strong,nonatomic) NSString* SongInProgress_Name;  //Stores name of song
@property(strong,nonatomic) NSString* SongInProgress_Path;  //Stores path of song in progress
//---------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_volumeControl_constraint;
@property CGFloat original_volumeControl_constraint;
@property CGPoint Volume_Child_bottom_Center;
@property CGPoint Volume_Child_top_Center;
@property BOOL has_Bottom_center;

//----------------------------------------------------------------------------------------------
//--------------------------------------Methods Available---------------------------------------
//----------------------------------------------------------------------------------------------
-(void) VolumeNo : (NSNumber*) volume ;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
-(IBAction)PlayAudio:(id)sender;
-(IBAction)StopAudio:(id)sender;
-(IBAction)PauseAudio:(id)sender;
-(IBAction)RepeatAudio:(id)sender;
-(IBAction)TimeSliderDragged:(id)sender;
-(IBAction)GoBack:(id)sender;
-(IBAction)NextTrack:(id)sender;

@property Playerstate CrntState;

@end
