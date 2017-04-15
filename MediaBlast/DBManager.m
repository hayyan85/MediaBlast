//
//  DBManager.m
//  MediaBlast
//
//  Created by Hayyan Sheikh on 4/10/15.
//  Copyright (c) 2015 Hayyan. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "Common.h"

@interface DBManager(Def)
  
@end



@implementation DBManager


//Retrieve songs in order

-(NSMutableArray*) RetrieveAllSongsInPlayList : (NSString*) PlistName
{
    sqlite3_stmt* statement;
    sqlite3 *contactDB;
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    
   
    // Get the documents directory
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DocsDir= [dirPaths objectAtIndex:0];
    NSString* PlistNamePath = [NSString stringWithFormat:@"%@/%@" ,DocsDir , PlistName ];
    
 
    if (sqlite3_open([PlistNamePath UTF8String], &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM %@ ORDER BY `Index`" , PlistName];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString* name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [arr addObject:name];
            }
        }
        sqlite3_close(contactDB);
    }
    
    return arr;
}


-(BOOL) DeleteSongFromPlayist:(NSString*)PlayListName SongName:(NSString*)song
{
    //Delete this song from the playlist
    // Get the documents directory
    bool RESULT = FALSE;
    sqlite3 *MusicDB;
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DocsDir= [dirPaths objectAtIndex:0];
    NSString* PlistNamePath = [NSString stringWithFormat:@"%@/%@" ,DocsDir , PlayListName ];
    NSString *querySQL = [NSString stringWithFormat: @"delete from %@ where Name='%@'",PlayListName,song];
    sqlite3_stmt *statement;
    if (sqlite3_open([PlistNamePath UTF8String], &MusicDB) == SQLITE_OK)
    {
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(MusicDB, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            RESULT = TRUE;
        }
        sqlite3_reset(statement);
        sqlite3_close(MusicDB);
    }

    return RESULT;
}




-(BOOL) InsertSongsInPlayList:(NSString*)PlayListName PlayListPath:(NSString*)Path SongCollection:(NSArray*) Arr
{
    char *errMsg;
    BOOL Rslt = FALSE;
    sqlite3 *DbHandle;
    
    if (sqlite3_open([Path UTF8String], &DbHandle) == SQLITE_OK)
    {
        for(int i=0 ; i <Arr.count ; i++)
        {
            NSString  *insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ (`Name`, `Index`, `Stars`) VALUES (\"%@\", %d, %d)",PlayListName,[Arr objectAtIndex:i],i,0];

            if ( sqlite3_exec(DbHandle, [insertStatement UTF8String], NULL, NULL, &errMsg) == SQLITE_OK)
            {
                Rslt = TRUE;
            }
            else
            {
               // NSLog(@"Error: %s", errMsg);
                Rslt= FALSE;
                break;
            }
        }
        sqlite3_close(DbHandle);
        return Rslt;
    }
    return Rslt;
}


-(BOOL) SavePlayListAndExit:(NSString *)PlayListName SongCollection:(NSArray*)SngCollection
{
        //Check if a file exists already
        NSArray *dirPaths;
        sqlite3 *contactDB;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.docsDir = [dirPaths objectAtIndex:0];
        
        // Build the path to the database file
        NSString* PlistPath= [[NSString alloc] initWithString: [self.docsDir stringByAppendingPathComponent:PlayListName]];
    
         
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        if ([filemgr fileExistsAtPath: PlistPath ] == NO)
        {
            const char *dbpath = [PlistPath  UTF8String];
            
            if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
            {
                char *errMsg;
                
                NSString* str = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ (`Name` TEXT , `Index` INTEGER , `Stars` INTEGER )",PlayListName];
                const char *sql_stmt =[str UTF8String];
                
                if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) == SQLITE_OK)
                {
                    sqlite3_close(contactDB);
                    
                    //The next one will open a new connection
                    BOOL rslt =  [self InsertSongsInPlayList:PlayListName PlayListPath:PlistPath SongCollection:SngCollection];
                    return rslt;
                }
                else
                {
                    return FALSE;
                }
                
            }
            else
            {
                return FALSE;
            }
        }
    return FALSE;
}

- (BOOL) UpdateSongsInPlayList : (NSString*)PlayListName SongsCollect:(NSMutableArray*)SongsArray
{
    //Delete the playList first
    bool result = FALSE;
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* plistPathName = [NSString stringWithFormat:@"%@/%@",[dirPaths objectAtIndex:0],PlayListName];
    NSFileManager * fmgrdefault = [NSFileManager defaultManager];
    if([fmgrdefault removeItemAtPath:plistPathName error:nil])
    {
        //PlayList Removed
        //Create new playList
        result = [self SavePlayListAndExit:PlayListName SongCollection:SongsArray];
    }
    return result;
}

@end
