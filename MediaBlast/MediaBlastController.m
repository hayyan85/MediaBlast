//
//  MediaBlastController.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/6/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "MediaBlastController.h"
#import "MediaManagerController.h"
#import "FileTransferController.h"
#import "PlayListManager.h"
#import "FlatButton.h"



@interface MediaBlastController ()
//Methods in class
- (IBAction)DisplayMediaManager:(id)sender;
- (IBAction)PlayListManager:(id)sender;
- (IBAction)ImportMediaManager:(id)sender;
@end


@implementation MediaBlastController


-(void) StyleButtons
{
    [self.buttonFlatMediaPlayer SetupButton:FBPrimary];
    [self.buttonImportMusic SetupButton:FBPrimary];
    [self.buttonPlayList SetupButton:FBPrimary];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self StyleButtons];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DisplayMediaManager:(id)sender {
    
    MediaManagerController* mediaMgrView = [[ MediaManagerController alloc] initWithNibName:@"MediaManagerController" bundle:nil ];
    [self presentViewController:mediaMgrView animated:TRUE completion:nil];
    
}

- (IBAction)PlayListManager:(id)sender
{
    PlayListManager* pmgr = [[PlayListManager alloc] initWithNibName:@"PlayListManager" bundle:nil];
    [self presentViewController:pmgr animated:TRUE completion:nil];
}

- (IBAction)ImportMediaManager:(id)sender
{
    FileTransferController* mediaImportView= [[FileTransferController alloc] initWithNibName:@"FileTransferController" bundle:nil];
    [self presentViewController:mediaImportView animated:TRUE completion:nil];
}


@end
