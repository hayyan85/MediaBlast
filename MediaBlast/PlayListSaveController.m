//
//  PlayListSaveController.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/26/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "PlayListSaveController.h"
#import "DBManager.h"
#import "MediaManagerController.h"

@interface PlayListSaveController ()

@end

@implementation PlayListSaveController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.TextPlayListName.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources thatdsd can be recreated.
}

-(IBAction) GoBack
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(IBAction) SavePlayList
{
   
   if([self.TextPlayListName.text isEqualToString:@""])
   {
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Play List name"
                                                       message:@"Please enter a Play List name"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
       
       [alert show]; //This is NonBlocking
       return;
   }
    
   
    NSArray* plistName = [self.TextPlayListName.text stringByAppendingString:@".hay"];
   if( [[[DBManager alloc]init] SavePlayListAndExit:self.TextPlayListName.text SongCollection:self.SongsSelected] )
 //  if( [[[DBManager alloc]init] SavePlayListAndExit:plistName SongCollection:self.SongsSelected] )
   {
       
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                       message:@"Your Play List has been saved"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
       
       [alert show]; //This is NonBlocking
       
   }
   else
   {
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:@"Could not save file"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
       
       [alert show]; //This is NonBlocking

   }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [(MediaManagerController*)self.presentingViewController  BackFromPlayListSaved];
}

- (void)dealloc
{
    //NSLog(@"Destructor of Save Playlistc called");
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



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    if  (! ([resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound))
    {
        //White spaces dound
        return NO;
    }  else  {
        return YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.SongsSelected count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Songs selected";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PlayListSaver";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier] ;
    }
    
    cell.textLabel.text = [self.SongsSelected objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];

    return cell;
}

//********************************************************************************************************************************************************************************
//**************************************************END:UITABLEVIEW METHODS*****************************************************************************************************
//********************************************************************************************************************************************************************************


@end
