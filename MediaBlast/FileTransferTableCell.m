//
//  FileTransferTableCell.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/21/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "FileTransferTableCell.h"

@implementation FileTransferTableCell

- (void)awakeFromNib
{
    // Initialization code
    [self.Activity_View startAnimating];
    [self.LabelSong_name setText:@""];
    
   // UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 4.0 ];
   // self.LabelSong_name.font  = myFont;
    //[self.LabelSong_name setFont:[UIFont systemFontOfSize:5]];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
