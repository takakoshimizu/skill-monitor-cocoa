#import "FMDatabase.h"

@implementation FMDatabase

+ (id)databaseWithPath:(NSString*)aPath; {
	return [[[FMDatabase alloc] initWithPath:aPath] autorelease];
}

- (id)initWithPath:(NSString*)aPath {
    self = [super init];
	
    if (self) {
        databasePath = [aPath copy];
        db           = nil;
        logsErrors   = NO;
    }
	
	return self;
}

- (void)dealloc {
	[self close];
	[databasePath release];
	[super dealloc];
}

+ (NSString*) sqliteLibVersion; {
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}



- (BOOL)open {
	int err = sqlite3_open( [databasePath fileSystemRepresentation], &db );
	if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
		return NO;
	}
	
	return YES;
}

- (void)close {
	if (!db) {
        return;
    }
    
	int err = sqlite3_close(db);
    if(err != SQLITE_OK) {
        NSLog(@"error closing!: %d", err);
	}
    
	db = nil;
}

- (NSString*) lastErrorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(db)];
}

- (int) lastErrorCode {
    return sqlite3_errcode(db);
}

- (sqlite_int64) lastInsertRowId {
    return sqlite3_last_insert_rowid(db);
}

- (id) executeQuery:(NSString*)objs, ...; {
    
    FMResultSet *rs = nil;
    
    NSString *sql = objs;
    int rc;
    sqlite3_stmt *pStmt;
    
    // use sqlite3_bind_parameter_count , thanks to it being pointed out by Dominic Yu
    
    rc = sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, 0);
    if (rc != SQLITE_OK) {
        rc = sqlite3_finalize(pStmt);
        
        if (logsErrors) {
            NSLog(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
        }
        
        return nil;
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    va_list argList;
    va_start(argList, objs);
    
    while (idx < queryCount) {
        
        obj = va_arg(argList, id);
        idx++;
        
        // FIXME - someday check the return codes on these binds.
        
        if ([obj isKindOfClass:[NSData class]]) {
            sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
        }
        else if ([obj isKindOfClass:[NSDate class]]) {
            sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    
    va_end(argList);
    
    // the statement gets close in rs's dealloc or [rs close];
    rs = [FMResultSet resultSetWithStatement:pStmt];
    
    return rs;
}


- (int) executeUpdate:(NSString*)objs, ...;{
    
    NSString *sql = objs;
    int rc;
    sqlite3_stmt *pStmt;
    
    rc = sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, 0);
    if( rc != SQLITE_OK ){
        int ret = rc;
        rc = sqlite3_finalize(pStmt);
        
        
        if (logsErrors) {
            NSLog(@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
        }
        
        return ret;
    }
    
    id obj;
    int idx = 0;
    int queryCount = sqlite3_bind_parameter_count(pStmt);
    va_list argList;
    va_start(argList, objs);
    
    while (idx < queryCount) {
        
        obj = va_arg(argList, id);
        idx++;
        
        if ([obj isKindOfClass:[NSData class]]) {
            sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
        }
        else if ([obj isKindOfClass:[NSDate class]]) {
            sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    
    va_end(argList);
    
    /* Call sqlite3_step() to run the virtual machine. Since the SQL being
    ** executed is not a SELECT statement, we assume no data will be returned.
    */
    rc = sqlite3_step(pStmt);
    assert( rc!=SQLITE_ROW );
    
    
    /* Finalize the virtual machine. This releases all memory and other
    ** resources allocated by the sqlite3_prepare() call above.
    */
    rc = sqlite3_finalize(pStmt);
    
    return rc;
}

- (BOOL) rollback; {
    return ([self executeUpdate:@"ROLLBACK TRANSACTION;", nil] == SQLITE_OK);
}

- (BOOL) commit; {
    return ([self executeUpdate:@"COMMIT TRANSACTION;", nil] == SQLITE_OK);
}

- (BOOL) beginTransaction; {
    return ([self executeUpdate:@"BEGIN DEFERRED TRANSACTION;", nil] == SQLITE_OK);
}


- (BOOL)logsErrors {
    return logsErrors;
}
- (void)setLogsErrors:(BOOL)flag {
    logsErrors = flag;
}


@end
