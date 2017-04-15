//
//  PlayListManager.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "PlayListManager.h"
#import "DBManager.h"
#import "PlayListPlayController.h"
#import "CommonFunctions.h"
#import "FlatButton.h"

@interface PlayListManager ()

@end

@implementation PlayListManager

//Closes the form that was loaded - Its Assumed its the MediaPlayer
//Give the playbutton the default icon again


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) StyleButtons
{
  
    [self.back SetupButton:FBDanger];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
    [self LoadAllPlayLists];
    [self StyleButtons];
    //self.tableView.editing = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//scan disk to obtain all playlists available
-(void) LoadAllPlayLists
{
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* PlayLists = [dirPaths objectAtIndex:0];
    self.ArrayplayLists = [[NSMutableArray alloc]init];
    NSFileManager * fmgrdefault = [NSFileManager defaultManager];
    
    NSArray* temp = [fmgrdefault contentsOfDirectoryAtPath:PlayLists error:nil];
    
    for (NSString *tempObject in temp) {
        NSString* extension = [tempObject pathExtension];
        if( [extension isEqualToString:@""]  )
        {
            [self.ArrayplayLists addObject:tempObject];
        }
    }
    //self.ArrayplayLists= [fmgrdefault contentsOfDirectoryAtPath:PlayLists error:nil];
    
    [self.tableView reloadData];
   
    //Iterate through the
}

-(IBAction) Goback
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)dealloc
{
    //NSLog(@"Destrcutor of PlayList Mamanger called");
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



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Delete this song in the playlist
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* plistName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        NSString* plistPathName = [NSString stringWithFormat:@"%@/%@",[dirPaths objectAtIndex:0],plistName];
        NSFileManager * fmgrdefault = [NSFileManager defaultManager];
        if([fmgrdefault removeItemAtPath:plistPathName error:nil])
        {
            //Removed Successfully
            [self LoadAllPlayLists];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    //section text as a label
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textAlignment = NSTextAlignmentCenter;
    
    lbl.text = @"Selected Songs";
    [lbl setBackgroundColor:[UIColor clearColor]];
    
    return lbl;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ArrayplayLists count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* plistName =  [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    self.ArrayplayLists = [[[DBManager alloc]init] RetrieveAllSongsInPlayList:plistName];  //Shouldnt a copy be made as DBMAnager will go out of scope
    PlayListPlayController* p = [[PlayListPlayController alloc]initWithNibName:@"PlayListPlayController" bundle:nil];
    p.ArraySongs = [NSMutableArray arrayWithArray:self.ArrayplayLists];
    p.PlayListName = plistName;
    [self presentViewController:p animated:TRUE completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* plist = @"PlistsDeque";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:plist];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc]init];
        cell.textLabel.text = [self.ArrayplayLists objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.imageView.image = [self imageWithImage:[UIImage imageNamed:@"list.png"] scaledToSize:CGSizeMake(22, 22)];
    }
    return cell;
}


//********************************************************************************************************************************************************************************
//**************************************************END:UITABLEVIEW METHODS*****************************************************************************************************
//********************************************************************************************************************************************************************************


@end
