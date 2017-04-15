//
//  Common.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/12/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

@end



@interface TypeSong : NSObject

    @property(copy ,nonatomic) NSString* SongName;
    @property(copy ,nonatomic) NSString* DateCreation;
    @property(nonatomic) int Stars;

@end
