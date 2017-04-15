//
//  FileTransferTableCell.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/21/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileTransferTableCell : UITableViewCell
@property(weak,nonatomic) IBOutlet UIActivityIndicatorView* Activity_View;
@property(weak,nonatomic) IBOutlet UILabel* LabelSong_name;
@property(weak,nonatomic) IBOutlet UIButton* Button_Complete_Image;
@end
