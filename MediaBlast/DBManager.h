//
//  DBManager.h
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/10/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBManager : NSObject

@property (nonatomic,strong) NSString* docsDir;
-(BOOL) SavePlayListAndExit:(NSString *)PlayListName SongCollection:(NSArray*)SngCollection;
-(NSMutableArray*) RetrieveAllSongsInPlayList : (NSString*) PlistName;
-(BOOL) DeleteSongFromPlayist:(NSString*)PlayListName SongName:(NSString*)song;
- (BOOL) UpdateSongsInPlayList : (NSString*)PlayListName SongsCollect:(NSMutableArray*)SongsArray;
@end
