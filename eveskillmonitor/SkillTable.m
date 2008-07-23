#import "SkillTable.h"

@implementation SkillTable

- (SkillTable *) init
{
	skill_list = [[NSMutableArray alloc] initWithCapacity:40];
	group_list = [[NSMutableArray alloc] initWithCapacity:7];
	active_skill_list = [[NSMutableArray alloc] initWithCapacity:10];
	return self;
}

- (void) clearSkills
{
	[skill_list removeAllObjects];
	[group_list removeAllObjects];
	[active_skill_list removeAllObjects];
}

- (void) setSkillGroups:(NSMutableArray *)groups skills:(NSMutableArray *)skills training:(TrainingSkill *)train
{
	[training release];
	[train retain];
	training = train;
	[skill_list removeAllObjects];
	[group_list removeAllObjects];
	[active_skill_list removeAllObjects];
	[skill_list addObjectsFromArray:skills];
	[group_list addObjectsFromArray:groups];
}

- (void) setActiveGroup:(LearnedSkillGroup *) group
{
	int groupid = [[group group] groupID];
	[active_skill_list removeAllObjects];
	[active_skill_list addObjectsFromArray:skill_list];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupid == %i", groupid];
	[active_skill_list filterUsingPredicate:predicate];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setFormat:@"#,##0"];
	[[[[skill_table tableColumns] objectAtIndex:0]headerCell]
		setStringValue:[NSString stringWithFormat:@"SP: %@", 
		[formatter stringFromNumber:[NSNumber numberWithInt:[group skillpoints]]]]];
}

- (void) setSelectedGroup:(int) index
{
	[skill_group_table selectRow:index byExtendingSelection:NO];
}

- (void) reloadData
{
	[skill_table reloadData];
	[skill_group_table reloadData];
}

- (int) numberOfRowsInTableView:(NSTableView *) table
{
	if ([active_skill_list count] == 0)
		return 0;
	if ([[table tableColumns] count] == 1)
		return [group_list count];
	else
		return [active_skill_list count];
}

- (id) tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *) col row:(int) row
{
	if ([[table tableColumns] count] == 1)
	{
		NSString *string = [NSString stringWithFormat:@" %@", [[[group_list objectAtIndex:row] group] name]];
		NSMutableAttributedString *mstring = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
		NSRange range;
		range.location = 0;
		range.length = [mstring length];
		NSFont *font = [NSFont systemFontOfSize:10];
		[mstring addAttribute:NSFontAttributeName value:font range:range];
		return mstring;
	}
	else
	{
		if (active_skill_list == nil)
			return @"";
		int column = [[col identifier] intValue];
		if (column == 0)
		{
			NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
			[formatter setFormat:@"#,##0"];
			NSMutableAttributedString *string;
			LearnedSkill *sk = [active_skill_list objectAtIndex:row];
			NSString *itemName = [NSString stringWithFormat:@"%@ %@", [[sk skill] name], [RomanNumerals toRoman:[sk level]]];
			if ([[sk skill] typeID] == [[training skill] typeID])
			{
				string = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (Rank %i)\nSP: %@",
					itemName, [[sk skill] rank], 
					[formatter stringFromNumber:[NSNumber numberWithInt:([sk skillpoints] + (int)[training accumulatedSP])]]]] autorelease];
			}
			else
			{
				string = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (Rank %i)\nSP: %@",
					itemName, [[sk skill] rank], 
					[formatter stringFromNumber:[NSNumber numberWithInt:[sk skillpoints]]]]] autorelease];
			}
			NSRange range;
			range.location = 0;
			range.length = [string length];
			NSFont *font = [NSFont systemFontOfSize:9];
			[string addAttribute:NSFontAttributeName value:font range:range];
			font = [NSFont boldSystemFontOfSize:9];
			range.length = [itemName length];
			[string addAttribute:NSFontAttributeName value:font range:range];
			return string;
		}
		else if (column == 1)
		{
			NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Level %i", 
				[[active_skill_list objectAtIndex:row] level]]] autorelease];
			NSRange range;
			range.location = 0;
			range.length = [string length];
			NSFont *font = [NSFont systemFontOfSize:9];
			[string addAttribute:NSFontAttributeName value:font range:range];
			return string;
		}
		else
			return [NSNumber numberWithInt:[[active_skill_list objectAtIndex:row] level]];
	}
}
				
- (void) tableViewSelectionDidChange:(NSNotification *) note
{
	[self setActiveGroup:[group_list objectAtIndex:[skill_group_table selectedRow]]];
	[self reloadData];
}

- (void) dealloc
{
	[skill_list release];
	[group_list release];
	[active_skill_list release];
	[super dealloc];
}

@end
