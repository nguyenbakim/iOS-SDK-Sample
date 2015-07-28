//
//  FileLogger.m
//  ooVooSample
//
//  Created by Anton Ianovski on 7/28/14.
//  Copyright (c) 2014 ooVoo. All rights reserved.
//

#import "FileLogger.h"
#import <Foundation/NSFileHandle.h>

@interface LogFileInfo : NSObject
{
    __strong NSString *filePath;
    
    __strong NSDictionary *fileAttributes;
    
    __strong NSDate *creationDate;
    __strong NSDate *modificationDate;
    
    unsigned long long fileSize;
}

@property (strong, nonatomic, readonly) NSString *filePath;

@property (strong, nonatomic, readonly) NSDictionary *fileAttributes;

@property (strong, nonatomic, readonly) NSDate *creationDate;
@property (strong, nonatomic, readonly) NSDate *modificationDate;

@property (nonatomic, readonly) unsigned long long fileSize;

- (instancetype)initWithFilePath:(NSString *)filePath;
- (NSComparisonResult)reverseCompareByCreationDate:(LogFileInfo *)another;
- (NSComparisonResult)reverseCompareByModificationDate:(LogFileInfo *)another;
@end

@interface FileLogger()
{
    NSFileHandle *mLogFile;
    NSString     *mLogFilePath;
}

- (id) init;
- (void) dealloc;

- (void) createLogFile;

- (void) logFatal: (NSString*)message;
- (void) logTrace: (NSString*)message;
- (void) logError: (NSString*)message;
- (void) logWarning: (NSString*)message;
- (void) logInfo: (NSString*)message;
- (void) logDebug: (NSString*)message;

- (void) writeLogToFile: (NSString*)message;

@end


@implementation FileLogger

-(id) init
{
    if (self = [super init]) {
        NSLog(@"FileLogger init");
        mLogFile = nil;
    }
    
    return self;
}

+(FileLogger *) sharedInstance
{
    static FileLogger *instance = nil;
    if (instance == nil) {
        instance = [[FileLogger alloc] init];
    }
    
    return instance;
}

-(void) dealloc
{
    NSLog(@"FileLogger dealloc");
    [mLogFile closeFile];
}

- (NSString*) logsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* result = nil;
    
    if (paths != nil && [paths count] > 0) {
        NSString *documentsDirectory = [paths firstObject];
        
        if (documentsDirectory != nil) {
            
            result = [documentsDirectory stringByAppendingString:@"/Logs"];
        }
    }
    
    return result;
}

-(void) createLogFile
{
    NSString *logFilesFolder = [self logsDirectory];
    
    if (logFilesFolder)
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        BOOL isFolderExists = [fileManager fileExistsAtPath:logFilesFolder];
        
        if (!isFolderExists){
            NSError *createDirError = nil;
            BOOL isDirCreatedSuccess = [fileManager createDirectoryAtPath:logFilesFolder withIntermediateDirectories:NO attributes:nil error:&createDirError];
            if (!isDirCreatedSuccess){
                NSLog(@"Failed to create directory %@ with the error: %@", logFilesFolder, [createDirError localizedDescription]);
                return;
            }
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH.mm.ss.SSS"];
        
        NSDate *now = [NSDate date];
        
        NSString *theDate = [dateFormat stringFromDate:now];
        NSString *theTime = [timeFormat stringFromDate:now];
        
        NSString *filePath = [logFilesFolder stringByAppendingString:[NSString stringWithFormat:@"/ooVooSampleLogFile_%@_%@.txt", theDate, theTime]];

        BOOL isFileExists = [fileManager fileExistsAtPath:filePath];
        
        if (!isFileExists) {
            BOOL isFileCreated = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
            
            if (isFileCreated) {
                mLogFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
                mLogFilePath = filePath;
            }
            else{
                NSLog(@"Failed to create file: %@ %s", filePath, strerror(errno));
            }
        }
    }
}

- (void) logFatal: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[FATAL  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logError: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[ERROR  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logWarning: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[WARNING] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logInfo: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[INFO   ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logTrace: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[TRACE  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logDebug: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[DEBUG  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) writeLogToFile: (NSString*)message
{
    if (mLogFile == nil) {
        return;
    }

    message = [message stringByAppendingString:@"\n"];
    [mLogFile writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) PrintLog:(LogLevel)level WithContent:(NSString *)message
{
    if (mLogFile == nil)
    {
        [self createLogFile];
    }
    
    switch (level)
    {
        case LogLevelFatal:
            [self logFatal:message];
            break;
            
        case LogLevelError:
            [self logError:message];
            break;
            
        case LogLevelWarning:
            [self logWarning:message];
            break;
            
        case LogLevelInfo:
            [self logInfo:message];
            break;
            
        case LogLevelTrace:
            [self logTrace:message];
            break;
            
        case LogLevelDebug:
        default:
            [self logDebug:message];
            break;
    }
}

-(void) log:(LogLevel) level message:(NSString *)message
{
    [self PrintLog:level WithContent:message];
}

-(NSString*) alignToLine:(NSString*)msgIn size:(NSUInteger)size
{
    if (msgIn == nil)
        return @"";
    
    NSRange searchRange;
    searchRange.length   = MIN(size, msgIn.length);
    searchRange.location = msgIn.length - searchRange.length;
    
    NSRange copyRange    = [msgIn rangeOfString:@"\n" options:0 range:searchRange];
    if (copyRange.length == NSNotFound)
        return @"";
    
    copyRange.location += copyRange.length;
    copyRange.length    = msgIn.length - copyRange.location;
    if (copyRange.location + copyRange.length > msgIn.length)
        return @"";
    
    return [msgIn substringWithRange:copyRange];
}

- (NSString *) readLastMessages: (NSUInteger)readSize
{
//    NSArray* log_paths = [[self unsortedLogFilePaths] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
//    {
//        NSComparisonResult result = [(NSString*)obj1 compare:(NSString *)obj2];
//        
//        if (result == NSOrderedAscending)
//            return NSOrderedDescending;
//        
//        if (result == NSOrderedDescending)
//            return NSOrderedAscending;
//        
//        return NSOrderedSame;
//    }];
    
    NSArray* log_paths = [self sortedLogFilePaths];
    
    NSString* content = @"";
    
    if (log_paths.count)
    {
        NSString* currentLogPath = log_paths[0];
        
        NSString* currentMsgs = [NSString stringWithContentsOfFile:currentLogPath
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];

        if ([currentMsgs length] >= readSize)
            return [self alignToLine:currentMsgs size:readSize];

        NSString*  previousMsgs = @"";
        
        NSString* previousLogPath = (log_paths.count>1 ? log_paths[1] : nil);
        if (previousLogPath)
        {
            NSString*  previousMsgs = [NSString stringWithContentsOfFile:previousLogPath
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
            if (![previousMsgs length])
                return currentMsgs;
        }

        previousMsgs = [self alignToLine:previousMsgs size:(readSize - currentMsgs.length)];
        if (![previousMsgs length])
            return currentMsgs;

        NSString*  alignedMsgs = [previousMsgs stringByAppendingString:currentMsgs];
        
        return alignedMsgs;
    }
    
    return content;
}

/**
 * Returns an array of NSString objects,
 * each of which is the filePath to an existing log file on disk.
 **/
- (NSArray *)unsortedLogFilePaths
{
    NSString *logsDirectory = [self logsDirectory];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logsDirectory error:nil];
    
    NSMutableArray *unsortedLogFilePaths = [NSMutableArray arrayWithCapacity:[fileNames count]];
    
    for (NSString *fileName in fileNames)
    {
        NSString *filePath = [logsDirectory stringByAppendingPathComponent:fileName];
        
        [unsortedLogFilePaths addObject:filePath];
    }
    
    return unsortedLogFilePaths;
}

- (NSArray *)unsortedLogFileInfos
{
    NSArray *unsortedLogFilePaths = [self unsortedLogFilePaths];
    
    NSMutableArray *unsortedLogFileInfos = [NSMutableArray arrayWithCapacity:[unsortedLogFilePaths count]];
    
    for (NSString *filePath in unsortedLogFilePaths)
    {
        LogFileInfo *logFileInfo = [[LogFileInfo alloc] initWithFilePath:filePath];
        
        [unsortedLogFileInfos addObject:logFileInfo];
    }
    
    return unsortedLogFileInfos;
}

- (NSArray *)sortedLogFilePaths
{
    NSArray *sortedLogFileInfos = [[self unsortedLogFileInfos] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LogFileInfo* fi1 = (LogFileInfo*)obj1;
        LogFileInfo* fi2 = (LogFileInfo*)obj2;
        
        return [fi1 reverseCompareByCreationDate:fi2];
    }];
    
    NSMutableArray *sortedLogFilePaths = [NSMutableArray arrayWithCapacity:[sortedLogFileInfos count]];
    
    for (LogFileInfo *logFileInfo in sortedLogFileInfos)
    {
        [sortedLogFilePaths addObject:[logFileInfo filePath]];
    }
    
    return sortedLogFilePaths;
}

@end

@implementation LogFileInfo

@synthesize filePath;

@dynamic fileAttributes;
@dynamic creationDate;
@dynamic modificationDate;

- (instancetype)initWithFilePath:(NSString *)aFilePath
{
    if ((self = [super init]))
    {
        filePath = [aFilePath copy];
    }
    return self;
}

- (NSDictionary *)fileAttributes
{
    if (fileAttributes == nil)
    {
        fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    }
    return fileAttributes;
}

- (NSDate *)modificationDate
{
    if (modificationDate == nil)
    {
        modificationDate = [[self fileAttributes] objectForKey:NSFileModificationDate];
    }
    
    return modificationDate;
}

- (NSDate *)creationDate
{
    if (creationDate == nil)
    {
        creationDate = [[self fileAttributes] objectForKey:NSFileCreationDate];
    }
    return creationDate;
}

- (NSComparisonResult)reverseCompareByCreationDate:(LogFileInfo *)another
{
    NSDate *us = [self creationDate];
    NSDate *them = [another creationDate];
    
    NSComparisonResult result = [us compare:them];
    
    if (result == NSOrderedAscending)
        return NSOrderedDescending;
    
    if (result == NSOrderedDescending)
        return NSOrderedAscending;
    
    return NSOrderedSame;
}

- (NSComparisonResult)reverseCompareByModificationDate:(LogFileInfo *)another
{
    NSDate *us = [self modificationDate];
    NSDate *them = [another modificationDate];
    
    NSComparisonResult result = [us compare:them];
    
    if (result == NSOrderedAscending)
        return NSOrderedDescending;
    
    if (result == NSOrderedDescending)
        return NSOrderedAscending;
    
    return NSOrderedSame;
}
@end
