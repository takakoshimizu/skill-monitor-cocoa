/* SkillPlanner */

#import <Cocoa/Cocoa.h>

@interface SkillPlanner : NSObject
{
    IBOutlet NSTableView *items_attributes;
    IBOutlet NSTextField *items_category;
    IBOutlet NSTextView *items_description;
    IBOutlet NSOutlineView *items_list;
    IBOutlet NSTextField *items_name;
    IBOutlet NSImageView *items_picture;
    IBOutlet NSTextView *items_required;
    IBOutlet NSSearchField *items_search;
    IBOutlet NSTableView *plan_table;
    IBOutlet NSTableView *plans_table;
    IBOutlet NSTableView *ships_attributes;
    IBOutlet NSTextField *ships_category;
    IBOutlet NSOutlineView *ships_list;
    IBOutlet NSTextField *ships_name;
    IBOutlet NSImageView *ships_picture;
    IBOutlet NSTextView *ships_required;
    IBOutlet NSSearchField *ships_search;
    IBOutlet NSTextField *skills_attributes;
    IBOutlet NSTextField *skills_category;
    IBOutlet NSTextField *skills_description;
    IBOutlet NSTextField *skills_level1;
    IBOutlet NSTextField *skills_level2;
    IBOutlet NSTextField *skills_level3;
    IBOutlet NSTextField *skills_level4;
    IBOutlet NSTextField *skills_level5;
    IBOutlet NSOutlineView *skills_list;
    IBOutlet NSTextField *skills_name;
    IBOutlet NSComboBox *skills_plan_to;
    IBOutlet NSSearchField *skills_search;
}
- (IBAction)addItemPlan:(id)sender;
- (IBAction)addShipPlan:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)deletePlan:(id)sender;
- (IBAction)planTo:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)searchItems:(id)sender;
- (IBAction)searchShips:(id)sender;
- (IBAction)searchSkills:(id)sender;
@end
