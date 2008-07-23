/* SkillTable */

#import <Cocoa/Cocoa.h>
#import "LearnedSkill.h"
#import "LearnedSkillGroup.h"
#import "TrainingSkill.h"
#import "RomanNumerals.h"

@interface SkillTable : NSObject
{
    IBOutlet NSTableView *skill_group_table;
    IBOutlet NSTableView *skill_table;
	
	NSMutableArray *skill_list, *group_list, *active_skill_list;
	TrainingSkill *training;
}

- (SkillTable *) init;

- (void) clearSkills;
- (void) setSkillGroups:(NSMutableArray *)groups skills:(NSMutableArray *)skills training:(TrainingSkill *)train;
- (void) setActiveGroup:(LearnedSkillGroup *) group;
- (void) setSelectedGroup:(int) index;
- (void) reloadData;

- (int) numberOfRowsInTableView:(NSTableView *) table;
- (id) tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *) col row:(int) row;
- (void) tableViewSelectionDidChange:(NSNotification *) note;

@end
