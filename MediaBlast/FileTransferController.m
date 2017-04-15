//
//  FileTransferController.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/19/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "FileTransferController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "FileTransferTableCell.h"
#include <pthread.h>
#include "CommonFunctions.h"

@interface FileTransferController ()

@end



static NSString *TransferIdentifier = @"TransferTableItem";


@implementation FileTransferController

-(void) UpdateTableInMainThread
{
    dispatch_async
    (
        dispatch_get_main_queue(), ^(void)
        {
            [self.tableview reloadData];
        }
    );
}

-(void) FileTransferStarted : (NSString*) FileName
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self.tableview reloadData];
    
    
    pthread_mutex_lock(&mutex);
    if(![self.SongListArray_Started containsObject:FileName])
    {
        //Do not add duplicates
        NSLog(@"-------------------Added the Song: %@",FileName);
        [self.SongListArray_Started addObject:FileName];
        [self.tableview reloadData]; //Refresh the display
        
    }
    
   pthread_mutex_unlock(&mutex);

   [self UpdateTableInMainThread];
   
}

-(void) FileTransferEnded : (NSString*) FileName
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    
    pthread_mutex_lock(&mutex);
    NSLog(@"-------------------finished the Song: %@",FileName);

    //Check if that song is in the list
    if([self.SongListArray_Started containsObject:FileName])
    {
        //Yes it is in the started simply add it to the finished one
        [self.SongListArray_Completed addObject:FileName];
    }
    else
    {
        //No it is not in the started put it in the finished
        [self.SongListArray_Started addObject:FileName];
        [self.SongListArray_Completed addObject:FileName];
    }
    pthread_mutex_unlock(&mutex);
    
    [self UpdateTableInMainThread];
    
}

-(void) Stylebuttons
{

   [CommonFunctions AStyleButtons:[self button_BackHome]];
   [CommonFunctions AStyleButtons:[self button_StartServer]];
}


-(IBAction) BackHome : (id)sender
{
    if(self.HttpServerRunning)
        [httpServer stop];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


-(IBAction) StartHttpServer : (id)sender
{
    
    if(self.HttpServerRunning)
    {
         //Stop the server
        [httpServer stop];
        self.label_console.text = @"HTTP Server Stopped";
        self.HttpServerRunning = FALSE;
    }
    
    else
    {
        
    
            // Log levels: off, error, warn, info, verbose
            static const int ddLogLevel = LOG_LEVEL_VERBOSE;
            
            // Configure our logging framework.
            // To keep things simple and fast, we're just going to log to the Xcode console.
            [DDLog addLogger:[DDTTYLogger sharedInstance]];
            
            // Initalize our http server
            httpServer = [[HTTPServer alloc] init];
        
           
            //Assign a value to the delegates
            httpServer.FileTransferControllerDelegate = self;
        
            // Tell the server to broadcast its presence via Bonjour.
            // This allows browsers such as Safari to automatically discover our service.
            [httpServer setType:@"_http._tcp."];
            
            // Normally there's no need to run our server on any specific port.
            // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
            // However, for easy testing you may want force a certain port so you can just hit the refresh button.
            [httpServer setPort:12345];
            
            // Serve files from the standard Sites folder
            NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" /*inDirectory:@"web"*/] stringByDeletingLastPathComponent];
            DDLogInfo(@"Setting document root: %@", docRoot);
            
            [httpServer setDocumentRoot:docRoot];
            
            [httpServer setConnectionClass:[MyHTTPConnection class]];
            
            NSError *error = nil;
            if(![httpServer start:&error])
            {
                DDLogError(@"Error starting HTTP Server: %@", error);
            }
            else
            {
                //Indicate that the server started
                self.label_console.text = [NSString stringWithFormat:@"Please type http://localhost:%hu",httpServer.PortNo];
                [self.btn_StartServer setTitle:@"Stop Server" forState:UIControlStateNormal];
                self.HttpServerRunning = TRUE;
            }

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self Stylebuttons];
  
    
    self.HttpServerRunning = FALSE;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
    //Initialize the array so it can save data
    self.SongListArray_Started = [[NSMutableArray alloc]init];
    self.SongListArray_Completed = [[NSMutableArray alloc]init];
    
    pthread_mutex_init(&mutex, NULL);
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



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.SongListArray_Started count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *TransferIdentifier = @"TransferTableItem";
    
    FileTransferTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TransferIdentifier];

    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FileTransferTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSString* songName = [self.SongListArray_Started objectAtIndex:indexPath.row];
    
    //Check if this is the started
    if( [self.SongListArray_Started containsObject:songName])
    {
        cell.LabelSong_name.text = [self.SongListArray_Started objectAtIndex:indexPath.row];
    }
    
    if( [self.SongListArray_Completed containsObject:songName])
    {
        //Display the completed status on the cell
        //Do any updates to your label here
        [cell.Activity_View stopAnimating];
        cell.Activity_View.hidesWhenStopped = TRUE ;
        [cell.Button_Complete_Image setImage:[UIImage imageNamed:@"check_present"] forState:UIControlStateNormal];
    }
    
    
    return cell;
}


//********************************************************************************************************************************************************************************
//**************************************************END:UITABLEVIEW METHODS*****************************************************************************************************
//********************************************************************************************************************************************************************************


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
