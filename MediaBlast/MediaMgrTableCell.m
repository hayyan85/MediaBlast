//
//  MediaMgrTableCell.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/8/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "MediaMgrTableCell.h"
#import "BackgroundColor.h"

@interface MediaMgrTableCell()

@end



@implementation MediaMgrTableCell

- (id) init
{
    self = [super init];
    if (self) {
        self.isPlaying = FALSE;
        self.isChecked = FALSE;
    }
    return self;
}


- (void) SetBackGroundGradient
{

    //Set the background color of the entire form
    self.bgLayer = [BackgroundLayer blueGradient];
    self.bgLayer.frame = self.contentView.frame;
    [self.contentView.layer insertSublayer:self.bgLayer atIndex:0];
    
}

- (void) RemoveChecks
{
    if(self.isChecked)
    {
        [self.btncheckstatus setImage:[UIImage imageNamed:@"check_absent.png"] forState:UIControlStateNormal];
    
         self.isChecked = !self.isChecked;
        
        if ([self.delegate_song_check_status respondsToSelector:@selector(SongCheckActivity:andCheckStatus:)])
            //call the delegate
        [self.delegate_song_check_status SongCheckActivity:self.labelSongName.text  andCheckStatus:self.isChecked]; //call the method
       
    }
}



-(void) SwitchOtherPlayButtonOff
{
     for(MediaMgrTableCell* cell in self.table.visibleCells)
     {
         [cell.btnplay setImage:[UIImage imageNamed:@"Play_Inactive.png"] forState:UIControlStateNormal];
     }
 }



//This method will highlight the play of that specific cell
//Will unhighlight other cells.
- (int) TogglePlay : (NSString*) SongName
{
    int rowNo = -1;
    for(MediaMgrTableCell* cell in self.table.visibleCells)
    {
        [cell.btnplay setImage:[UIImage imageNamed:@"Play_Inactive.png"] forState:UIControlStateNormal];
        if( [cell.labelSongName.text isEqualToString:SongName])
        {
            [cell.btnplay setImage:[UIImage imageNamed:@"Play_Active.png"] forState:UIControlStateNormal];
            rowNo = cell.RowNo;
        }
    }
    
    return rowNo;
}

//This method will highlight the check
- (void) TogglPlay : (NSString*) SongName  Visible : (BOOL) visible
{
    
    if(visible)
        [self.btnplay setImage:[UIImage imageNamed:@"Play_Active.png"] forState:UIControlStateNormal];
    else
        [self.btnplay setImage:[UIImage imageNamed:@"Play_Inactive.png"] forState:UIControlStateNormal];
}


//This method will highlight the check
- (void) Togglecheck : (NSString*) SongName  Visible : (BOOL) visible
{

    if(visible)
    [self.btncheckstatus setImage:[UIImage imageNamed:@"check_present.png"] forState:UIControlStateNormal];
    else
    [self.btncheckstatus setImage:[UIImage imageNamed:@"check_absent.png"] forState:UIControlStateNormal];
}

// 0 = Play Button
// 1 = Checked Button
- (void) ToggleImage : (int) Control UsingSender : (id)sender //sender is a button
{
    
    if(Control==0)
    {
        
        [self SwitchOtherPlayButtonOff];
        
        self.isPlaying =true;
        
        //Toggle the play button
        if(self.isPlaying)
        {
            [self.btnplay setImage:[UIImage imageNamed:@"Play_Active.png"] forState:UIControlStateNormal];
        }
        /*else
        { [self.btnplay setImage:[UIImage imageNamed:@"play_active.png"] forState:UIControlStateNormal]; }
        */
        
        
        
        
        
        //Send message back to the UI form that this has been checked
        if ([self.delegate_song_check_status respondsToSelector:@selector(PlaySong:UsingMediaMgrTableCell:)])
        //call the delegate
        [self.delegate_song_check_status PlaySong:self.labelSongName.text  UsingMediaMgrTableCell:self]; //call the method

        
    }
    else
    {
        
        if(self.isChecked)
        {    [self.btncheckstatus setImage:[UIImage imageNamed:@"check_absent.png"] forState:UIControlStateNormal];  }
        else
        {    [self.btncheckstatus setImage:[UIImage imageNamed:@"check_present.png"] forState:UIControlStateNormal]; }
        
         self.isChecked = !self.isChecked;
        
  
        //Send message back to the UI form that this has been checked
        if ([self.delegate_song_check_status respondsToSelector:@selector(SongCheckActivity:andCheckStatus:)])
        //call the delegate
        [self.delegate_song_check_status SongCheckActivity:self.labelSongName.text  andCheckStatus:self.isChecked]; //call the method
   
    }
}

- (IBAction)PlaySong:(id)sender
{
    //Change the icon of the button
    [self ToggleImage:0 UsingSender:sender];
    
    
}

- (IBAction)CheckSong:(id)sender
{
   //Change the icon of the button
   [self ToggleImage:1 UsingSender:sender];
}
@end
