#import "LoginTable.h"

@implementation LoginTable

- (LoginTable *) init
{
	charlist = [[NSMutableArray alloc] init];
	me = self;
	return self;
}

- (void) addToCharList: (LoginChar *) ch
{
	[charlist addObject:ch];
}

- (void) clearCharList
{
	[charlist removeAllObjects];
}

- (LoginChar* ) getCharacterAtIndex: (int) index
{
	return [charlist objectAtIndex:index];
}

	// TableView dataSource methods follow
- (int) numberOfRowsInTableView: (NSTableView *) table
{
	return [charlist count];
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)row;
{
	return [[[charlist objectAtIndex:row] objectForColumn:[[column identifier] intValue]] copy];
}


- (void) dealloc
{
	[charlist release];
	[super dealloc];
}

@end
