//
//  PlayListPlayController.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "PlayListPlayController.h"
#import "MediaMgrTableCell.h"
#import "MediaPlayer.h"
#import "FlatButton.h"
#import "CommonFunctions.h"

@import AVFoundation;

@interface PlayListPlayController ()

@end

@implementation PlayListPlayController



//This is where you end up when the bakc button is pressed in the media player
- (void) BackHere
{
    [self.presentedViewController dismissViewControllerAnimated:FALSE completion:nil];
}


-(void) StyleButtons
{
    [self.buttonBack SetupButton:FBDanger];
    [self.buttonSavePlayList SetupButton:FBPrimary];
    [self.buttonShuffle SetupButton:FBPrimary];
}

-(NSString*) GetFilePathFromIndex:(int)index
{
    NSString* MusicDir = [dirPaths objectAtIndex:0];
    NSString* fpath = [NSString stringWithFormat:@"%@/%@",MusicDir,[self.ArraySongs objectAtIndex:index]];
    return fpath;
}


//Shuffle the songs
-(IBAction)ShufflePlayList:(id)sender
{

    [CommonFunctions shuffle:self.ArraySongs];
    
    
    [self.tableview reloadData];
    
    //if a song was beig played and the shuffle button was pressed then after shuffling highlight the play button
    //that was active
    if(self.MediaPlayerViewController!=nil)
    {
        [self.tableview layoutIfNeeded]; //wait till reloadData of tableview is done
        MediaMgrTableCell* tc =  (MediaMgrTableCell*)[self.tableview.visibleCells objectAtIndex:0];
        self.RowBeingPlayed = [tc  TogglePlay:self.MediaPlayerViewController.SongInProgress_Name];
    }

    
}

-(UIImage *)getMP3Pic:(int)index
{
    NSString* path = [self GetFilePathFromIndex:index];
    NSURL* url = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:url];
    for (AVMetadataItem *metadataItem in asset.commonMetadata) {
        if ([metadataItem.commonKey isEqualToString:@"artwork"]){
            return [UIImage imageWithData:(NSData *)metadataItem.value];
        }
    }
    return [UIImage imageNamed:@"music"];

}


//Extract the total Audio Time
- (NSString*) ExtractTotalAudioTime: (int) ObjectIndex
{
    
    NSString* path = [self GetFilePathFromIndex:ObjectIndex];
    
    
    NSURL * pathToMp3File = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:pathToMp3File error:&error];
    
    
    NSTimeInterval theTimeInterval = [avAudioPlayer duration];
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
    // Get conversion to hours, minutes, seconds
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    NSString *p = [NSString stringWithFormat:@"%02d:%02d",  [breakdownInfo minute], [breakdownInfo second]];
    
    
    avAudioPlayer = nil;
    return p;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.editing = YES; //Show the drag up/down option and dot on left
    //dirPaths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.MediaPlayerViewController = nil;
    self.RowBeingPlayed = -1;
    [self StyleButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) GoBack
{
    [self.MediaPlayerViewController.RunningTimer invalidate];
     self.MediaPlayerViewController = nil;
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


//This method is called by the media player whenever a song is changed.
//This method is then responsible for highlighting the playbutton of that song
//Remember to update cell.row -->  self.RowBeingPlayed = cell.RowNo;
-(void) SongChanged : (NSString*) SongName
{
        MediaMgrTableCell* mcell = (MediaMgrTableCell*) [self.tableview.visibleCells objectAtIndex:0];
        self.RowBeingPlayed = [mcell TogglePlay:SongName];
}
//********************************************************************************************************************************************************************************
//**************************************************START:UITABLEVIEW METHODS*****************************************************************************************************
//********************************************************************************************************************************************************************************

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1]];
    }
    else [cell setBackgroundColor:[UIColor clearColor]];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     return 50;
 }
 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
     return [self.ArraySongs count];
 }



 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
   return @"Play List Songs";
 }


//Display the delete option on swipe left and handle it
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Delete this song in the playlist
        NSString* songName = ((MediaMgrTableCell*)[tableView cellForRowAtIndexPath:indexPath]).labelSongName.text;
        if([[[DBManager alloc]init] DeleteSongFromPlayist:self.PlayListName SongName:songName])
        {
            //Yes Song got deleted successfully update the array
            [self.ArraySongs removeObject:songName];
            [tableView reloadData];
        }
    }
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id thing = [self.ArraySongs objectAtIndex:sourceIndexPath.row];
    [self.ArraySongs removeObjectAtIndex:sourceIndexPath.row];
    [self.ArraySongs insertObject:thing atIndex:destinationIndexPath.row];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     static NSString *simpleTableIdentifier = @"MediaMgrTableCellIdentifier";
     
     MediaMgrTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
     
     if (cell == nil)
     {
         NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MediaMgrTableCell" owner:self options:nil];
         cell = [nib objectAtIndex:0];
     }
     
     cell.delegate_song_check_status = self;
     cell.btncheckstatus.hidden = TRUE;
     cell.showsReorderControl = YES;
     cell.RowNo = indexPath.row;
     cell.table = self.tableview;
     cell.labelSongName.text = [self.ArraySongs objectAtIndex:indexPath.row];
     cell.labelDuration.text = [self ExtractTotalAudioTime:indexPath.row];
     cell.ImageAlbum.image = [self getMP3Pic:indexPath.row];

     return cell;
 }
 
//********************************************************************************************************************************************************************************
//**************************************************END:UITABLEVIEW METHODS*****************************************************************************************************
//********************************************************************************************************************************************************************************


//This is a callback that tells us if a song was checked.
- (void) SongCheckActivity : (NSString*) SongName andCheckStatus : (BOOL) status
{

}





-(void) GenerateSongNamePath
{
    self.ArraySongNamePath = [[NSMutableArray alloc]init];
    NSString* MusicDir = [dirPaths objectAtIndex:0];
    
   for(NSString* song in self.ArraySongs)
   {
       NSString* fpath = [NSString stringWithFormat:@"%@/%@",MusicDir,song];
       NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
       [dict setValue:fpath forKey:song];
       [self.ArraySongNamePath addObject:dict];
   }
    
}


-(IBAction)SavePlayListOrder:(id)sender
{
    UIAlertView* av;
    if( [ [ [DBManager alloc]init] UpdateSongsInPlayList:self.PlayListName SongsCollect:self.ArraySongs ] )
    {
        av = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Your PlayList order has been saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else
    {
        av = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Your PlayList order could not be saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    
    [av show];
}



//Takes it to the play screen form and only plays that song
- (void) PlaySong : (NSString*)songName UsingMediaMgrTableCell:(MediaMgrTableCell*) cell
{
    NSString* song_path;
    
    song_path=  [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0] , songName] ;
    
    MediaPlayer* temp_play ;

    
    if(cell.RowNo == self.RowBeingPlayed)
        temp_play = self.MediaPlayerViewController;
    else
    {
        [self.MediaPlayerViewController.RunningTimer invalidate];
        temp_play= [[ MediaPlayer alloc] initWithNibName:@"MediaPlayer" bundle:nil ];
    }
    
    self.RowBeingPlayed = cell.RowNo;
    (temp_play).SongInProgress_Name= songName;
    (temp_play).SongInProgress_Path= song_path;
    
    [self GenerateSongNamePath];
    
    (temp_play).MusicCollectionPath = self.ArraySongNamePath;
    
    self.MediaPlayerViewController = temp_play;
    
    [self presentViewController:temp_play animated:TRUE completion:nil];
}


-(void) dealloc
{
   // NSLog(@"Destructor of Play List Play Controller called");
}



@end
