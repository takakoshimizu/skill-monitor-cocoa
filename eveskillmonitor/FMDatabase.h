#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"

@interface FMDatabase : NSObject 
{
	sqlite3*	db;
	NSString*	databasePath;
    BOOL        logsErrors;
}

+ (id)databaseWithPath:(NSString*)inPath;
- (id)initWithPath:(NSString*)inPath;

- (BOOL)open;
- (void)close;

- (NSString*) lastErrorMessage;
- (int) lastErrorCode;
- (sqlite_int64) lastInsertRowId;

- (int) executeUpdate:(NSString*)objs, ...;
- (id) executeQuery:(NSString*)obj, ...;

- (BOOL) rollback;
- (BOOL) commit;
- (BOOL) beginTransaction;

- (BOOL)logsErrors;
- (void)setLogsErrors:(BOOL)flag;

+ (NSString*) sqliteLibVersion;

@end
