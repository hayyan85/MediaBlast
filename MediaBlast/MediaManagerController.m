//
//  MediaManagerController.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/6/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "DBManager.h"
#import "MediaManagerController.h"
#import "MediaMgrTableCell.h"
#import "Common.h"
#import "MediaPlayer.h"
#import "PlayListSaveController.h"
#import "CommonFunctions.h"
#import "FlatButton.h"


@interface MediaManagerController ()

@end





@implementation MediaManagerController

//********************************************************************************************************************************************************************************
//*******************************************************START:FILE MANAGEMENT (PLAYLISTS / DELETE /HOME**************************************************************************
//********************************************************************************************************************************************************************************

//Takes you back to the main option screen
-(IBAction)BackHome:(id)sender
{
    [self.mplayer.RunningTimer invalidate]; //Disable the timer of the Media Player. If not disabled the song playing will continue playing
     self.mplayer = nil;                    //Make sure destructor of MediaPlayer is called.
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


-(IBAction)DeleteFiles:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Remove Song? "
                                                 message:@"Are you sure you want to remove these files from your phone ?"
                                                delegate:self
                                       cancelButtonTitle:@"No"
                                       otherButtonTitles:@"Yes", nil];
    
    
    [av show];
    
}



//This method is called by the media player whenever a song is changed.
//This method is then responsible for highlighting the playbutton of that song
//Remember to update cell.row -->  self.RowBeingPlayed = cell.RowNo;
-(void) SongChanged : (NSString*) SongName
{
    MediaMgrTableCell* mcell = (MediaMgrTableCell*) [self.tableViewObject.visibleCells objectAtIndex:0];
    self.RowBeingPlayed = [mcell TogglePlay:SongName];
}


//Shuffle the songs
-(IBAction)shuffle:(id)sender
{
    
    [self.ArraySongNamePath  removeAllObjects];
    
    [CommonFunctions shuffle:self.tableData];
    
    //Make up an that has Dictionary (SongName , path)
    for(NSString* filename in self.tableData)
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
        NSString* song_path =  [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0] , filename] ;
        [dict setObject:song_path forKey:filename];
        [self.ArraySongNamePath addObject:dict];
    }
    
    [self.tableViewObject reloadData];
    
    
    //if a song was beig played and the shuffle button was pressed then after shuffling highlight the play button
    //that was active
    if(self.mplayer!=nil)
    {
        [self.tableViewObject layoutIfNeeded];
        MediaMgrTableCell* tc =  (MediaMgrTableCell*)[self.tableViewObject.visibleCells objectAtIndex:0];
        self.RowBeingPlayed = [tc    TogglePlay:self.mplayer.SongInProgress_Name];
    }
    

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self DeleteSelectedFiles];
    }
}


//Hiding the separators of empty cells
//Setting the table's separatorStyle to UITableViewCellSeparatorStyleNone (in code or in IB) should do the trick.

//********************************************************************************************************************************************************************************
//*******************************************************END:FILE MANAGEMENT (PLAYLISTS / DELETE /HOME**************************************************************************
//********************************************************************************************************************************************************************************


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



-(NSString*) GetFilePathFromIndex:(int)index
{
    NSMutableDictionary * dict = [self.ArraySongNamePath objectAtIndex:index];
    NSString* path;
    for(id key in dict)
    {
        path = [dict objectForKey:key];
    }
    return path;
}


- (void) StyleButtons
{

   [self.ButtonCreatePlayList SetupButton:FBPrimary];
   [self.ButtonDelete SetupButton:FBDanger];
   [self.ButtonHome SetupButton:FBPrimary];
   [self.ButtonShuffle SetupButton:FBPrimary];
    
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



- (void) BackFromPlayListSaved
{
    //Dismiss the oldscreen
    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:nil];

    //Clear the checkMarks
    
    for(UITableViewCell* cell in self.tableViewObject.visibleCells)
    {
        MediaMgrTableCell* tc = (MediaMgrTableCell*)cell;
        [tc RemoveChecks];
    }
}


//This method scans the space for all music files
- (void) ScanSpaceForMusic
{
   // dirPaths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
     dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    [self.ArraySongNamePath  removeAllObjects];
    NSString* MusicDir = [dirPaths objectAtIndex:0];
   
    NSFileManager * fmgrdefault = [NSFileManager defaultManager];
    NSMutableArray* tempData = [[NSMutableArray alloc]initWithArray:[fmgrdefault contentsOfDirectoryAtPath:MusicDir error:nil]];
    self.tableData = [[NSMutableArray alloc]init];
    
    for(NSString* filename in tempData)
    {
        if ([filename hasSuffix:@".mp3"])
        {
            [self.tableData addObject:filename];
        }
    }
    
    [self.tableViewObject reloadData];
    
    
    //Make up an that has Dictionary (SongName , path)
    for(NSString* filename in self.tableData)
    {
           NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
           NSString* song_path =  [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0] , filename] ;
          [dict setObject:song_path forKey:filename];
        
        
          [self.ArraySongNamePath addObject:dict];
    }

    [self.tableViewObject reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    SearchBar.delegate = (id)self;
    isFiltered = FALSE; //For the search bar
    self.tableViewObject.delegate = self;
    self.tableViewObject.dataSource = self;
    self.ArraySongNamePath = [[NSMutableArray alloc]init];
    [self ScanSpaceForMusic];
    [self StyleButtons];
    self.SongsChecked = [[NSMutableArray alloc]init];
    self.RowBeingPlayed = -1;
    self.tableViewObject.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mplayer = nil;
}


-(IBAction)CreatePlayList:(id)sender
{
   
   if(self.SongsChecked.count > 0)
   {
       PlayListSaveController* pl = [[PlayListSaveController alloc] initWithNibName:@"PlayListSaveController" bundle:nil];
       pl.SongsSelected = self.SongsChecked ;
       [self presentViewController:pl animated:TRUE completion:nil];
   }
   else
   {
       UIAlertView* alview = [[UIAlertView alloc]initWithTitle:@"No songs selected" message:@"Please select songs to place in a playlist" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alview show];
   }
}


- (void) DeleteSelectedFiles
{
    
    if(self.SongsChecked.count > 0)
    {
        //NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
        NSString* MusicDir = [dirPaths objectAtIndex:0];
        
        for (NSString* sname in self.SongsChecked)
        {
            NSString* songnamepath = [NSString stringWithFormat:@"%@/%@" , MusicDir , sname];
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:songnamepath error:nil];
        }
        
        //Clear the selected arrays
        [self.SongsChecked removeAllObjects];
        
        [self ScanSpaceForMusic];
    }
    else
    {
        UIAlertView* alview = [[UIAlertView alloc]initWithTitle:@"No songs selected" message:@"Please select songs to place in a playlist" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alview show];
    }
    
}


- (void) didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method is inherited from the search bar
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        isFiltered = FALSE;
    }
    else
    {
        isFiltered = true;
        self.filteredTableData = [[NSMutableArray alloc] init];
        
        for (NSString* str in self.tableData)
        {
            NSRange nameRange = [str rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound )
            {
                [self.filteredTableData addObject:str];
            }
        }
    }
    
    [self.tableViewObject reloadData];
    
    
    if(self.mplayer!=nil) //If a song is being played/
    {
        [self.tableViewObject layoutIfNeeded];
        NSArray* arr =  self.tableViewObject.visibleCells;
        if(arr)
        {
           
            if(arr.count > 0)
            {
                MediaMgrTableCell* tc =  (MediaMgrTableCell*)[arr objectAtIndex:0];
                int r = [tc TogglePlay:self.mplayer.SongInProgress_Name]; //Will it be okay if this is -1 ?
                if(r != -1)
                    self.RowBeingPlayed = r;
            }
            
        }
        else
        {
            NSLog(@"No array returned");
        }
        
    }
    

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
    //else [cell setBackgroundColor:[UIColor clearColor]];
    else [cell setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:239.0f/255.0f blue:245.0f/255.0f alpha:1]];
}


//this is the implementation of tableView delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
   if(isFiltered)
       return [self.filteredTableData count];
    else
        return [self.tableData count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


/*
   The dequeueReusableCellWithIdentifier: method makes sure only a specific number of UITableViewCells
   are created. For instance if a UITableView can visibly display only 4 rows and the array attached to the table has 10 items
   then only visible region rows + 2 objects of UITableViewCells are created. this means only 4+6 UITableViewCells are created.
   These TableViewCells are then recycled.This means that a UITableViewCell that was used to display the item in row1 could
   probably be used to display items in row9.Thus storing pointers to a UITableViewCell with the assumption that it will always 
   point to row 2 is strongly wrong as the UITableViewCells are recycled.
 
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    static NSString *simpleTableIdentifier = @"MediaMgrTableCellIdentifier";
    
    MediaMgrTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil)
    {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MediaMgrTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    NSString* sng =  isFiltered ?  [self.filteredTableData objectAtIndex:indexPath.row] : [self.tableData objectAtIndex:indexPath.row] ;
    cell.delegate_song_check_status = self;
    cell.RowNo = indexPath.row;
    cell.labelDuration.text = [self ExtractTotalAudioTime:indexPath.row];
    cell.ImageAlbum.image = [self getMP3Pic:indexPath.row];
    cell.table = self.tableViewObject;
    cell.labelSongName.text = [NSString stringWithFormat:@"%@", sng ];
    
   
    //Check if the song has a check next to it
    if( [self.SongsChecked containsObject:cell.labelSongName.text]   )  //Check if this entry had a checkbox next to it
        [cell Togglecheck:cell.labelSongName.text Visible:TRUE];
    else
        [cell Togglecheck:cell.labelSongName.text Visible:FALSE];
    
    //Check if this song has a play sign next to it
    if ([self.mplayer.SongInProgress_Name isEqualToString:cell.labelSongName.text])
        [cell TogglPlay:cell.labelSongName.text Visible:TRUE];
    else
        [cell TogglPlay:cell.labelSongName.text Visible:FALSE];

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Selected Value is %@",[self.tableData objectAtIndex:indexPath.row]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alertView show];
     */
}

//********************************************************************************************************************************************************************************
//**************************************************END:UITABLEVIEW METHODS*******************************************************************************************************
//********************************************************************************************************************************************************************************


//Closes the form that was loaded - Its Assumed its the MediaPlayer
//Give the playbutton the default icon again ONLY if the song is not in progress
- (void) BackHere ;
{
    [self.presentedViewController dismissViewControllerAnimated:FALSE completion:nil];
}


//This is a callback that tells us if a song was checked.
- (void) SongCheckActivity : (NSString*) SongName andCheckStatus : (BOOL) status
{
    //[self dismissViewControllerAnimated:YES completion:Nil];
    
    if(status==TRUE)
    {
        //This means the song just got checked - Add T0 Mutable Array
        [self.SongsChecked addObject:SongName];
    }
    else
    {
        //Thsi means song got unchecked - Remove from MutableArray
        [self.SongsChecked removeObject:SongName];
    }
}

//Takes it to the play screen form and only plays that song
- (void) PlaySong : (NSString*)songName UsingMediaMgrTableCell:(MediaMgrTableCell*) cell
{
    NSString* song_path;
    song_path=  [NSString stringWithFormat:@"%@/%@", [dirPaths objectAtIndex:0] , songName] ;
 
    MediaPlayer* temp_play ;
    
    
    //Note:
    //What if this is a from a search bar ? In search bar songs move up and down thats why we have the second condition
    //Play yop most song and then filter so that last song comes to top then play that song
    if(cell.RowNo == self.RowBeingPlayed  && [self.mplayer.SongInProgress_Name isEqualToString:songName] )
    {
        temp_play = self.mplayer;
    }
    else
    {
        [self.mplayer.RunningTimer invalidate];
        temp_play= [[ MediaPlayer alloc] initWithNibName:@"MediaPlayer" bundle:nil ];
    }
    
    self.RowBeingPlayed = cell.RowNo;
    
    (temp_play).SongInProgress_Name= songName;
    (temp_play).SongInProgress_Path= song_path;
    (temp_play).MusicCollectionPath= self.ArraySongNamePath;
    
    
    self.mplayer = temp_play;
    [self presentViewController:temp_play animated:TRUE completion:nil];
    
    
}

-(void) dealloc
{
    NSLog(@"Destructor of Media Manager Controller called");
}

@end
