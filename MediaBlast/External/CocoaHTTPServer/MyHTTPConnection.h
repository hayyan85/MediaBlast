
#import "HTTPConnection.h"
#import "FileTransferController.h"

@class MultipartFormDataParser;


@interface MyHTTPConnection : HTTPConnection
{
    MultipartFormDataParser*         parser;
	NSFileHandle*					 storeFile;
	NSMutableArray*					 uploadedFiles;
    bool                             TransferStarted;
}


@end
