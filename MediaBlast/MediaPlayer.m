//
//  MediaPlayer.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/12/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "MediaPlayer.h"
#import "BackgroundColor.h"
#import "DKTuner.h"
#import "MediaManagerController.h"
#import "PlayListPlayController.h"
#import "FlatButton.h"

@interface MediaPlayer ()

@end




@implementation MediaPlayer

- (void) StyleButtons
{
     [self.ButtonBack SetupButton:FBDanger];
     [self.ButtonNextTrack SetupButton:FBPrimary];
}


//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              HELPER FUNCTIONS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************

//Resize Image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
  
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//Extract the total Audio Time
NSString* ExtractTotalAudioTime(NSTimeInterval TimeInterval_)
{
    NSTimeInterval theTimeInterval = TimeInterval_;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
    // Get conversion to hours, minutes, seconds
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    NSString *p = [NSString stringWithFormat:@"%02d:%02d",  [breakdownInfo minute], [breakdownInfo second]];
    
    return p;
}


//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              START:   TIME SLIDER MANAGEMENTS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************

-(void) SetupTimeSlider
{
    self.sliderProgress.maximumValue = 255.0;
    self.sliderProgress.minimumValue = 0;
    self.sliderProgress.popUpViewCornerRadius = 12.0;
    self.sliderProgress.value = 0;
    [self.sliderProgress setMaxFractionDigitsDisplayed:0];
    self.sliderProgress.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    self.sliderProgress.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
    self.sliderProgress.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    self.sliderProgress.dataSource = self;
}


- (NSString *) slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    value = roundf(value);
    NSString *s = ExtractTotalAudioTime(value);
    return s;
}


-(IBAction)TimeSliderDragged:(id)sender
{
    
  [self.player setCurrentTime: ((ASValueTrackingSlider*)sender).value ];
}


//INITIALIZE THE PLAYER TIMER
-(void) ActivatePlayerTimer : (Playerstate) pstate
{
    
    if(pstate == EnumStart)
    {
        
        self.RunningTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                     target: self
                                     selector:@selector(TimerTriggered:)
                                     userInfo: nil repeats:YES];
    }
    
}

//THIS IS CALLED WHEN THE TIMER TIMES OUT
-(void) TimerTriggered:(NSTimer *)timer
{
    self.sliderProgress.value++;
}


//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              END:   TIME SLIDER MANAGEMENTS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************




//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              START: VOLUME SLIDER MANAGEMENTS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************

- (void) SetVolumeTuner
{
    DKTuner* sensitivityTuner = [[DKTuner alloc] initWithFrame:CGRectMake(40, 80, 115 ,115 )
                                                    usingImage:[UIImage imageNamed:@"tunerImage"]
                                              usingDescription:@"VOLUME"
                                               descriptionFont:[UIFont fontWithName:@"Arial" size:10]
                                                      maxValue:100
                                                      minValue:1
                                               backgroundColor:[UIColor clearColor]
                                                     foreColor:UIColor.whiteColor
                                                    objectFont:[UIFont fontWithName:@"Arial" size:30]];
    
    sensitivityTuner.VolumeDelegate = self;
    
    [self.sliderVolumeView addSubview:sensitivityTuner];
    
    sensitivityTuner.center = [self.sliderVolumeView  convertPoint:self.sliderVolumeView.center fromView:self.sliderVolumeView.superview];
    self.sliderVolumeView.layer.borderColor = [UIColor clearColor].CGColor;
    self.sliderVolumeView.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.Volume_Child_top_Center = sensitivityTuner.center;
    sensitivityTuner.tag = 100; //Secret no. Like an id to access this child when traversing through parent

}


//A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full volume for the audio player instance
//This is the callback which handles increase in volume
- (void) VolumeNo : (NSNumber*) volume
{
    int val = [volume intValue];

    if(val % 10 == 0)
    {
        //NSLog(@"Value is %d",val);
        float newvolume = val/100.0;
        [self.player setVolume:newvolume];
    }
    
}
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              END: VOLUME SLIDER MANAGEMENTS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************

-(UIImage *)getMP3Pic:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    for (AVMetadataItem *metadataItem in asset.commonMetadata) {
        if ([metadataItem.commonKey isEqualToString:@"artwork"]){
            return [UIImage imageWithData:(NSData *)metadataItem.value];
        }
    }
    return [UIImage imageNamed:@"music"];
}


- (void) ExtractAndPopulateSongMetaData
{
    NSURL *fileURL1 = [NSURL fileURLWithPath:self.SongInProgress_Path];
    
    self.medallionView.image = [self getMP3Pic:fileURL1];
    
    
    //Extract Total Time of Audio to Display in View
    self.LabelPlayTime.text = ExtractTotalAudioTime(self.player.duration);
    
    //Load the name of song being playes
    self.LabelSongInProgress.text = self.SongInProgress_Name;
    
    //Setup the slider with values
    self.sliderProgress.maximumValue = self.player.duration;
    self.sliderProgress.minimumValue = 0;
    
    [self.player play];
    
    //Start the time so it could move the lsider as the song progresses
    [self ActivatePlayerTimer:EnumStart];
    
}

//Does all the initiations
- (void) InitiatePageLoad
{
    
    //Set the medallion ring view of the media image
    
    self.MediaImageView.backgroundColor = [UIColor clearColor];
    self.medallionView = [[AGMedallionView alloc] init];
    self.medallionView.image = [UIImage imageNamed:@"music"];
    
    
    [ self.MediaImageView  addSubview:self.medallionView];
    self.medallionView.center = [self.MediaImageView  convertPoint:self.MediaImageView.center fromView:self.MediaImageView.superview];
    
    
    [self SetVolumeTuner];
    

    //Make a copy of the height constraint because that will be changed in landscape mode
    self.original_volumeControl_constraint = self.height_volumeControl_constraint.constant ;
    
}





- (void)didReceiveMemoryWarning
{
    //[super didReceiveMemoryWarning];
    // self.isSongPaused = FALSE;
}



//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              START : AUDIO PLAYER CONTROLS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.RepeatEnabled)
        [self PlayAudio:self];
    [self NextTrack:nil];
}


-(IBAction)PlayAudio:(id)sender
{
    
    if(!self.isSongPaused)
    {
        
        //This statement will prevent restart playing if play is clicked twice
        if(self.sliderProgress.value != 0)  return;
            
        NSURL *pathAsURL = [[NSURL alloc] initFileURLWithPath:self.SongInProgress_Path];

        // Init the audio player.
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:pathAsURL error:&error];
        [self.player setDelegate:self];
        
        // Check out what's wrong in case that the player doesn't init.
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            
            
            //This method populates the metaData and plays the song
            [self ExtractAndPopulateSongMetaData];
            
            //Highlight the play Button
            [self.ButtonPlay setImage:[UIImage imageNamed:@"Play_Active.png"] forState:UIControlStateNormal];
            
            //Enable the UISlider again
            self.sliderProgress.userInteractionEnabled = TRUE;
            
            //Inform the parent controller that the song was changed.
            //I understand the first time would be a waste but it saves a lot of extra effort and its 4:21 Am right now.
            [self.presentingViewController performSelector:@selector(SongChanged:) withObject:self.SongInProgress_Name afterDelay:0];
            
            
        }
        
       
    }
    else
    {
        //The song was paused just play the song in progress
        [self.player play];
        [self ActivatePlayerTimer:EnumStart];
        self.isSongPaused = !self.isSongPaused;
        
        //Unhighlight the pause button
        [self.ButtonPause setImage:[UIImage imageNamed:@"pause_inactive"] forState:UIControlStateNormal]; //Is this safe ARC ?
        //Highlight the play Button
        [self.ButtonPlay setImage:[UIImage imageNamed:@"Play_Active.png"] forState:UIControlStateNormal];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

//Stop the timer
//Return the slider back to original position
-(IBAction)StopAudio:(id)sender
{
     self.isSongPaused = false;
    
     [self.RunningTimer invalidate];
     self.RunningTimer= nil;
   
     self.sliderProgress.value = 0;
     [self.player stop];
    
     //Unhighlight all the buttons Play and Pause
     [self.ButtonPause setImage:[UIImage imageNamed:@"pause_inactive"] forState:UIControlStateNormal];
     [self.ButtonPlay setImage:[UIImage imageNamed:@"Play_Inactive"] forState:UIControlStateNormal];
    
     //Lock the slider so the user does not move it
    self.sliderProgress.userInteractionEnabled = FALSE;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}


//Stop the timer
-(IBAction)PauseAudio:(id)sender
{
  
    //Stop the timer
    [self.RunningTimer invalidate];
     self.RunningTimer= nil;
    
    self.isSongPaused = TRUE;

   [self.player pause];
    
      //Highligt the pause button
      [self.ButtonPause setImage:[UIImage imageNamed:@"pause_active"] forState:UIControlStateNormal]; //Is this safe ARC ?
      //Unhiglight the play button
      [self.ButtonPlay setImage:[UIImage imageNamed:@"Play_Inactive"] forState:UIControlStateNormal];
}

-(IBAction)RepeatAudio:(id)sender{
    
}


//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              END : AUDIO PLAYER CONTROLS
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************


//Return to previous screen
-(IBAction)GoBack:(id)sender
{
    //[self.RunningTimer invalidate];
    //NSNumber *num =  [[NSNumber alloc]initWithBool:self.isSongPaused];
    [ self.presentingViewController performSelector:@selector(BackHere) withObject:nil afterDelay:0 ];
   
}


-(int) RetrieveSongIndex
{
    
    for(int i=0 ; i<self.MusicCollectionPath.count ; i++)
    {
        NSMutableDictionary* dict = [self.MusicCollectionPath objectAtIndex:i];
        for(id key in dict)
        {
            if([self.SongInProgress_Name isEqualToString:(NSString*)key])
            {
                return i;
            }
        }
    }
    return -1;
}


-(IBAction)NextTrack:(id)sender
{
     //Find the index of current playing song
    int newIndex;
    int index = [self RetrieveSongIndex];
    
    //Check if this was the last song
    if(index == self.MusicCollectionPath.count-1)
    {
        //Yes that was the last song. Start back
        newIndex = 0;
    }
    else
    {
        //No it was not the last song.
        newIndex = ++index;
    }
    NSMutableDictionary* m = [self.MusicCollectionPath objectAtIndex:newIndex];
    
    for(id key in m)
    {
        self.SongInProgress_Name = key;
        self.SongInProgress_Path = [m objectForKey:key];
 
    }
    
    self.isSongPaused = FALSE;
    self.sliderProgress.value = 0;
    
    [self.RunningTimer invalidate];  //Invalidate the timer if its running
    self.RunningTimer= nil;

    [self PlayAudio:nil]; //Play the song
    
}


-(void) PlayReceivedMusic
{
    //The songNAme and SongPath have already been set by previous form
    [self PlayAudio:Nil];
}

//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                               START : DEVICE FRAMEWORK METHODS
//********************************************************************************************************************************************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self SetupTimeSlider];

    self.sliderProgress.value = 0;  //Slider value - Progress of song played
    self.RepeatEnabled = FALSE;     //Repeat Functionality
    self.isSongPaused = FALSE;      //Song is not paused
   
    
    [self InitiatePageLoad];
    
    
    //Set the background color of the entire form
    self.bgLayer = [BackgroundLayer blueGradient];
    self.bgLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:self.bgLayer atIndex:0];
    self.has_Bottom_center = FALSE;
    
    
    //Test buttons
    [self StyleButtons];
    
    
    [self PlayReceivedMusic];
    
}

//check if its in landscape mode
- (void)viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {

        //[self viewWillTransitionToSize:[UIScreen mainScreen].bounds.size withTransitionCoordinator:nil];
        [self viewWillTransitionToSize:[self presentingViewController].view.bounds.size withTransitionCoordinator:nil];
    }
    
}


//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                               START : PORTRAIT and LANDSCAPE MODE
//********************************************************************************************************************************************************************************

//This method is called when device AutoRotates
- (void)viewDidLayoutSubviews
{
    //Fix the background color
    self.bgLayer.frame = self.view.frame;
    
}



//When device rotates
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
    DKTuner* sensitivityTuner;
    if (size.width > size.height)
    {   //Yes this is the landscape mode
        
       
        //Remove subview from sliderVolumeView
        for (UIView *subview in [self.sliderVolumeView subviews])
        {
            
            sensitivityTuner = (DKTuner*)subview;
            [subview removeFromSuperview];
        }
        
        
        //If it doesnt have the center cordinates to the bottom position then
        //calculate it.
        if(!self.has_Bottom_center)
        {
        
                //Extract the view of the circle image
                CGPoint medallion_center;
                AGMedallionView *medallionView ;
            
                for (UIView *subview in [self.MediaImageView subviews])
                {
                    medallionView = (AGMedallionView*)subview;
                    medallion_center = medallionView.center;
                }
                
                //Insert this in the picture view
                [self.MediaImageView addSubview:sensitivityTuner];
            
            
                CGFloat x = medallionView.center.x + (medallionView.frame.size.width/2) + 20 + (sensitivityTuner.frame.size.width/2);
            
                sensitivityTuner.center = CGPointMake(x,medallionView.center.y);
            
                self.Volume_Child_bottom_Center =  sensitivityTuner.center;
            
        }
        else
        {
            [self.MediaImageView addSubview:sensitivityTuner];
            sensitivityTuner.center = self.Volume_Child_bottom_Center;
        }
        
        //Hide the parent container of the volume slider at the bottom.
        self.sliderVolumeView.hidden = TRUE;
        
        
        self.height_volumeControl_constraint.constant = 3;
        
        //Make sure to track that you have the center cordinates for the top so we dont have to do this every time
        self.has_Bottom_center = TRUE;
        
        
    }
    else
    {
        // This is the portrait mode
        
        //Set the original Height constraints back
        //self.height_volumeControl_constraint = self.original_volumeControl_constraint;
        
        //Unhide the parent host for the volume control.
        self.sliderVolumeView.hidden = FALSE;
        
        UIView* tempView;

        //Remove the child volume controle from the parent picture View - The picture view was sharing its container
        for (UIView *subview in [self.MediaImageView subviews])
        {
            if(subview.tag == 100)
            {
                //Yes remove this view
                tempView = subview;
            }
            
        }
        
        [tempView removeFromSuperview];
       
        //Add the view to the parent that was hidden and  its unhidden now
        [self.sliderVolumeView addSubview:tempView];
        
        tempView.center = self.Volume_Child_top_Center;
        
        //Set the original Height constraints back
        self.height_volumeControl_constraint.constant = self.original_volumeControl_constraint;
        

    }
    

    
    //Align the object(s)
    //Extract size align the objects next to each other
    CGFloat SingleObjectwidth = [self.MediaImageView viewWithTag:100].bounds.size.width ;
    CGFloat EntireViewWidth = /*self.MediaImageView.frame.size.width;*/size.width - 20;
    CGFloat RemainingSpace = EntireViewWidth - ((SingleObjectwidth*2)+20);
    
    CGFloat x = -1;
    CGPoint np;
    for (UIView *subview in [self.MediaImageView subviews])
    {
        if(x == -1 )
        {
            np = CGPointMake((RemainingSpace/2) + (SingleObjectwidth/2) , subview.center.y);
            subview.center = np;
            x= 0;
        }
        else
        {
            np = CGPointMake( np.x + (SingleObjectwidth/2) + 20 + (SingleObjectwidth/2), subview.center.y);
            subview.center = np;
        }
    }

}

//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                               END : PORTRAIT and LANDSCAPE MODE
//********************************************************************************************************************************************************************************


-(void)dealloc {

    NSLog(@"Media Player Destructor called");
}
@end
//********************************************************************************************************************************************************************************
//********************************************************************************************************************************************************************************
//                                                              END: DEVICE FRAMEWORK METHODS
//********************************************************************************************************************************************************************************
