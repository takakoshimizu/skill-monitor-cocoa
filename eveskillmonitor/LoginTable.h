/* LoginTable */

#import <Cocoa/Cocoa.h>
#import "LoginChar.h"

@interface LoginTable : NSObject
{
	NSMutableArray *charlist;
	LoginTable *me;
}

- (LoginTable *) init;

- (void) addToCharList: (LoginChar *) ch;
- (void) clearCharList;

- (LoginChar *) getCharacterAtIndex: (int) index;

// TableView dataSource methods follow
- (int) numberOfRowsInTableView: (NSTableView *) table;
- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)row;

@end
