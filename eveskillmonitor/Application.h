/* Application 
 Based on Cel Halcyon original program
 Thanks you Cel for alowing us the change to work with this. 
 
 */

#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import <SM2DGraphView/SMPieChartView.h>
#import "EveAPI.h"
#import "FMDatabase.h"
#import "SkillPool.h"
#import "Character.h"
#import "CharacterSet.h"
#import "LoginChar.h"
#import "LoginTable.h"
#import "SkillTable.h"
#import "PieChartDS.h"
#import "RomanNumerals.h"
#import "GSNSDataExtensions.h"


@interface Application : NSObject
{
    IBOutlet NSTextField *all_timer;
    IBOutlet NSSlider *chamod;
    IBOutlet NSBox *char_box;
    IBOutlet NSTextField *char_charisma;
    IBOutlet NSImageView *char_image;
    IBOutlet NSTextField *char_intelligence;
    IBOutlet NSTextField *char_known_skills;
    IBOutlet NSTextField *char_memory;
    IBOutlet NSTextField *char_perception;
    IBOutlet NSTextField *char_race;
    IBOutlet NSTextField *char_total_sp;
    IBOutlet NSTextField *char_vskills;
    IBOutlet NSTextField *char_willpower;
    IBOutlet NSTextField *completion_field;
    IBOutlet NSProgressIndicator *completion_indicator;
    IBOutlet NSTextField *cur_training;
    IBOutlet NSPanel *implant_window;
    IBOutlet NSSlider *intmod;
    IBOutlet NSWindow *loading_window;
    IBOutlet NSTextField *login_apikey;
    IBOutlet NSComboBox *login_charid;
    IBOutlet NSButton *login_save_box;
    IBOutlet NSProgressIndicator *login_spinner;
    IBOutlet NSTableView *login_tab;
    IBOutlet NSTextField *login_userid;
    IBOutlet NSWindow *loginWindow;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSSlider *memmod;
    IBOutlet NSMenuItem *next_tab_button;
    IBOutlet NSMenuItem *overlay_button;
    IBOutlet NSTextField *overlay_complete;
    IBOutlet NSTextField *overlay_completion;
    IBOutlet NSTextField *overlay_cur_training;
    IBOutlet NSTextField *overlay_percent;
    IBOutlet NSImageView *overlay_portrait;
    IBOutlet NSPanel *overlay_window;
    IBOutlet NSSlider *permod;
    IBOutlet NSMenuItem *prev_tab_button;
    IBOutlet NSTableView *skillgroups;
    IBOutlet NSTableView *skills;
    IBOutlet NSTextField *sp_hour;
    IBOutlet NSProgressIndicator *spinner;
    IBOutlet NSTextField *startup_detail;
    IBOutlet PSMTabBarControl *tab_strip;
    IBOutlet NSTabView *tabs;
    IBOutlet NSTextField *training_timer;
    IBOutlet NSSlider *wilmod;
	IBOutlet SMPieChartView *pieChart;
	IBOutlet NSPanel *pieChartWindow;
	
	IBOutlet NSTextField *intmod_text;
	IBOutlet NSTextField *memmod_text;
	IBOutlet NSTextField *chamod_text;
	IBOutlet NSTextField *permod_text;
	IBOutlet NSTextField *wilmod_text;
	
	IBOutlet NSButton *implantDisclosure;

	IBOutlet LoginTable *login_table;
	
	bool overlayActive;
	FMDatabase *db;
	SkillPool *sp;
	NSMutableArray *characters;
	int active_char, overlay_char;
	
}
- (IBAction)cancelLogin:(id)sender;
- (IBAction)closeTab:(id)sender;
- (IBAction)deleteSaved:(id)sender;
- (IBAction)displayImplants:(id)sender;
- (IBAction)doLogin:(id)sender;
- (IBAction)findCharIds:(id)sender;
- (IBAction)new_character:(id)sender;
- (IBAction)nextTab:(id)sender;
- (IBAction)prevTab:(id)sender;
- (IBAction)refreshData:(id)sender;
- (IBAction)saveImplants:(id)sender;
- (IBAction)showHideOverlay:(id)sender;
- (IBAction)showPieChart:(id)sender;
- (IBAction)cancelImplants:(id)sender;

- (void) tabView:(NSTabView *)tabView willCloseTabViewItem:(NSTabViewItem *) tabViewItem;
- (void) tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *) tabViewItem;
- (BOOL) tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *) tabViewItem;

- (void) updateTimer:(NSTimer *) timer;
- (void) refreshTab;
- (void) doOverlayWithCountdown: (NSString *) finalString andPercent:(int) percent;
- (void) refreshLoginTable;
- (void) showInfo:(NSString *) title withInfoText:(NSString *) infoText;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (NSString *) pathForDataFile:(NSString *) fileName;

- (void) workspaceDidWake:(NSNotification *) note;
@end
