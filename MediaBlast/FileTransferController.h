//
//  FileTransferController.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/19/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileTransferTableCell.h"

@protocol ProtoFileTransferProgress <NSObject>
-(void) FileTransferStarted : (NSString*) FileName;
-(void) FileTransferEnded : (NSString*) FileName;
@end


@class HTTPServer;
@interface FileTransferController : UIViewController  <UITableViewDelegate, UITableViewDataSource , ProtoFileTransferProgress>

{
    	HTTPServer *httpServer;
        pthread_mutex_t mutex;
}
@property(nonatomic , weak) IBOutlet UITableView* tableview;
@property(nonatomic , weak) IBOutlet UIButton* button_StartServer;
@property(nonatomic , weak) IBOutlet UIButton* button_BackHome;
@property(nonatomic , weak) IBOutlet UILabel* label_console;
@property(nonatomic , weak) IBOutlet UIButton* btn_StartServer;
@property(atomic , strong) NSMutableArray* SongListArray_Started;
@property(atomic , strong) NSMutableArray* SongListArray_Completed;

-(IBAction) StartHttpServer : (id)sender;
-(IBAction) BackHome : (id)sender;
-(void) FileTransferStarted : (NSString*) FileName;
-(void) FileTransferEnded : (NSString*) FileName;
@property bool HttpServerRunning;
@end
