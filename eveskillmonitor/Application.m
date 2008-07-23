#import "Application.h"


@implementation Application


/**
 * Application awakeFromNib
 * Does a lot of various things. First sets up a few instance classes, 
 * then loads saved character tabs from the cache.
 **/
- (void) awakeFromNib
{
	[completion_indicator stopAnimation:self];
	active_char = -1;
	overlayActive = NO;
	characters = [[NSMutableArray alloc] initWithCapacity:1];
	
	// Make sure the database has been initialized before.
	// If not, copy over the default settings from the Resources
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:[self pathForDataFile:@"skilldata.db"]])
	{
		NSString *fromPath = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/skillmonitor.db"];
		[manager copyPath:fromPath toPath:[self pathForDataFile:@"skilldata.db"] handler:nil];
	}
	
	// Okay let's go now.
	db = [[FMDatabase alloc] initWithPath:[self pathForDataFile:@"skilldata.db"]];
	if (![db open])
	{
		NSLog(@"Couldn't open database.");
	}
	
	/**
	 * THIS IS AN UPGRADE FUNCTIONS
	 **/
	FMResultSet *upgrade = [db executeQuery:@"select name from sqlite_master where type='table' order by name"];
	BOOL found = NO;
	while ([upgrade next])
	{
		if ([[upgrade stringForColumn:@"name"] isEqual:@"prerequisites"])
		{
			found = YES;
		}
	}
	[upgrade close];
	if (!found)
	{
		FMDatabase *db2 = [FMDatabase databaseWithPath:
			[NSString stringWithFormat:@"%@%@",
				[[NSBundle mainBundle] resourcePath],@"/skillmonitor.db"]];
		[db executeUpdate:@"create table prerequisites ( typeID int, required_id int, required_level int )"];
		[db2 open];
		upgrade = [db2 executeQuery:@"select * from prerequisites"];
		while ([upgrade next])
		{
			[db executeUpdate:[NSString stringWithFormat:@"insert into prerequisites values (%i, %i, %i)",
				[upgrade intForColumn:@"typeID"], [upgrade intForColumn:@"required_id"], [upgrade intForColumn:@"required_level"]]];
		}
		// UPGRADE COMPLETE
	}

		
	sp = [[SkillPool alloc] initWithDB:db];
	
	NSButton *add_button = [tab_strip addTabButton];
	[add_button setTarget:self];
	[add_button setAction:@selector(new_character:)];
	
	int numRows = 0;
	
	[tabs removeTabViewItem:[tabs tabViewItemAtIndex:0]];
	FMResultSet *rs = [db executeQuery:@"select count(1) as count from cache"];
	if ([rs next])
		numRows = [rs intForColumn:@"count"];
	
	NSLog(@"Num Rows: %i", numRows);
	
	rs = [db executeQuery:@"select * from cache order by ordinal asc"];
	
	int i = 0;
	while([rs next])
	{
		Character *ch = [[Character alloc] initWithCharacterId:[rs intForColumn:@"charid"]
														  name:@""
													  database:db];
		[ch setRace:@""];
		[ch setBloodline:@""];
		[ch setGender:@""];
		[ch setCorp:@""];
		[ch setBalance:0.0];
		[ch setIntelligence:0.0];
		[ch setCharisma:0.0];
		[ch setPerception:0.0];
		[ch setMemory:0.0];
		[ch setWillpower:0.0];
		[ch setNumSkills:0];
		[ch setVSkills:0];
		[ch setSkillPoints:0];
		[ch setLearning:0.0];
		
		CharacterSet *cs = [[CharacterSet alloc] init];
		[cs setCharacter:ch];
		
		EveAPI *api = [[EveAPI alloc] initWithCharId:[rs intForColumn:@"charid"]
											  userId:[rs intForColumn:@"userid"]
											  apiKey:[rs stringForColumn:@"apikey"]];
		[cs setApi:api];
		
		[cs setCharacter:[[cs api] characterSheetWithPool:sp database:db]];
		[characters addObject:cs];
		
		i = [characters indexOfObject:cs];
		
		[api release];
		
		NSTabViewItem *tab_view = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%i",i]];
		[tab_view setLabel:[[cs chara] name]];
				
		/*
		[db executeUpdate:[@"delete from cache where charid = " stringByAppendingString:[NSString stringWithFormat:@"%i",[rs intForColumn:@"charid"]]]];
		
		
		NSString *query = [NSString stringWithFormat:@"insert into cache values (0, %i, '%@', '%@', '%@', '%@', '%@', %f, %f, %f, %f, %f, %f, %i, %i, %i, %f, %i, %i, '%@')",
			[ch charid], [ch name], [ch race], [ch bloodline], [ch gender], [ch corp], [ch balance],
			[ch intelligence], [ch charisma], [ch perception], [ch memory], [ch willpower], [ch numskills],
			[ch vskills], [ch skillpoints], [ch learning], 0, [rs intForColumn:@"userid"], [rs stringForColumn:@"apikey"]];
		[db executeUpdate:query];
		*/
		
		i++;
		
		[tabs addTabViewItem:tab_view];
		
		[cs release];
		[ch release];
	}
	
	[tabs selectFirstTabViewItem:self];
	[self refreshTab];
	
	[self refreshLoginTable];		
	
	[mainWindow makeKeyAndOrderFront:self];
		
	// Start the ticker
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
													  target:self 
													selector:@selector(updateTimer:)
													userInfo:nil 
													 repeats:YES];
	
	// And attach an observer to the computer wake event
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(workspaceDidWake:)
															   name:NSWorkspaceDidWakeNotification object:nil];
}


/**
 * Application cancelLogin
 * Hides the login window. This much is obvious.
 **/
- (IBAction)cancelLogin:(id)sender
{
	[loginWindow orderOut:sender];
}


/**
 * Application showPieChart
 * Displays the skill Pie Chart Window
 **/
- (IBAction)showPieChart:(id)sender
{
	if (active_char == -1)
		return;
	[pieChartWindow makeKeyAndOrderFront:self];
	PieChartDS *chart = [pieChart dataSource];
	CharacterSet *cs = [characters objectAtIndex:active_char];
	[chart clearSkillGroups];
	NSEnumerator *enumerator = [[[cs chara] skillgroups] objectEnumerator];
	id group;
	while (group = [enumerator nextObject])
	{
		[chart addSkillGroup:[[group group] name] skillpoints:[group skillpoints]];
	}
	// Force this stupid fucking shit-ass pie-chart class to actually fucking refresh properly.
	int i;
	for (i = 0;i < 2; i++)
	{
		[pieChart reloadAttributes];
		[pieChart reloadData];
	}
}


/**
 * Application closeTab
 * Manually closes a character tab.
 **/
- (IBAction)closeTab:(id)sender
{
	NSTabViewItem *item = [tabs selectedTabViewItem];
	[self tabView:tabs willCloseTabViewItem:item];
	[tabs removeTabViewItem:item];
}


/**
 * Application deleteSaved
 * Removes a saved character from the saved character list on the login window
 **/
- (IBAction)deleteSaved:(id)sender
{
	LoginChar *ch = [login_table getCharacterAtIndex:[login_tab selectedRow]];
	[db executeUpdate:[NSString stringWithFormat:@"delete from characters where charid = %i", [ch charid]]];
	[login_table clearCharList];
	[self refreshLoginTable];
}


/**
 * Application displayImplants
 * Sets up the implant panel for the current character and shows it.
 **/
- (IBAction)displayImplants:(id)sender
{
	if (active_char == -1)
		return;
	Character *ch = [[characters objectAtIndex:active_char] chara];
	[intmod setIntValue:[ch intmod]];
	[memmod setIntValue:[ch memmod]];
	[chamod setIntValue:[ch chamod]];
	[permod setIntValue:[ch permod]];
	[wilmod setIntValue:[ch wilmod]];
	
	[intmod_text setIntValue:[ch intmod]];
	[memmod_text setIntValue:[ch memmod]];
	[chamod_text setIntValue:[ch chamod]];
	[permod_text setIntValue:[ch permod]];
	[wilmod_text setIntValue:[ch wilmod]];
	
	[implantDisclosure setState:NSOffState];
		
	[implant_window makeKeyAndOrderFront:sender];
}

/**
 * Application cancelImplants
 * Hides the implant window without making changes.
 **/
- (IBAction)cancelImplants:(id)sender
{
	[implant_window orderOut:self];
}


/**
 * Application saveImplants
 * Takes the changed implant values from the panel and saves, 
 * then displays the changes.
 **/
- (IBAction)saveImplants:(id)sender
{
	if (active_char == -1)
		return;
	Character *ch = [[characters objectAtIndex:active_char] chara];
	[ch saveImplantsWithDb:db intelligence:[intmod intValue] 
					memory:[memmod intValue] charisma:[chamod intValue]
				perception:[permod intValue] willpower:[wilmod intValue]];
	[self refreshTab];
	[implant_window orderOut:sender];
}


/**
 * Application doLogin
 * Takes the values from the login screen and initializes a new character,
 * caching it, and saving if requested.
 **/
- (IBAction)doLogin:(id)sender
{
	[login_spinner startAnimation:self];
	int charid = 0, userid = 0, new_chr = 0;
	NSString *apikey;
	// First, make sure something is selected or entered.
	if ([[login_userid stringValue] length] > 0)
	{
		if ([[login_apikey stringValue] length] == 0 || [[login_charid stringValue] length] == 0)
		{
			[self showInfo:@"All Information Needed" withInfoText:@"In order to log in, you need to provide all three bits of information, or none at all."];
			[login_spinner stopAnimation:self];
			return;
		}
	
		NSString *temp = [login_charid stringValue];
		NSArray *charItems = [temp componentsSeparatedByString:@" - "];
		charid = [[charItems objectAtIndex:1] intValue];
		userid = [login_userid intValue];
		apikey = [login_apikey stringValue];
		
		EveAPI *api = [[EveAPI alloc] initWithCharId:charid userId:userid apiKey:apikey];
		CharacterSet *cs = [[CharacterSet alloc] init];
		
		[cs setApi:api];
		
		Character *cha = [[cs api] characterSheetWithPool:sp database:db];
		if (cha == nil)
		{
			[login_spinner stopAnimation:self];
			return;
		}
		
		NSEnumerator *enumerator = [characters objectEnumerator];
		id obj;
		while (obj = [enumerator nextObject])
		{
			if ([[obj chara] charid] == [cha charid])
			{
				[self showInfo:@"This character is already being monitored." withInfoText:@"This character is already being monitored. You may have meant to add a different character."];
				[login_spinner stopAnimation:self];
				return;
			}
		}		
		
		[cs setCharacter:cha];
		[characters addObject:cs];
		
		new_chr = [characters indexOfObject:cs];
		
		[api release];
		
		if ([login_save_box state] == NSOnState)
		{
			NSImage *cimg = [[NSImage alloc] initWithContentsOfURL:
				[NSURL URLWithString:[NSString stringWithFormat:@"http://img.eve.is/serv.asp?s=64&c=%i", charid]]];
			NSData *imgData = [cimg TIFFRepresentation];
			// int length = [imgData length];
			NSString *base64 = [imgData base64EncodingWithLineLength:64];
			[cimg release];
			
			[db executeUpdate:[NSString stringWithFormat:@"insert into characters values('%@', %i, %i, '%@', '%@', '%@')",[[cs chara] name], 
				charid, userid, apikey, base64, [[cs chara] corp]]];
			
			[self refreshLoginTable];
		}
		[cs release];
	}
	else
	{
		// There's nothing entered, so they must've selected from the list, right?
		int index = [login_tab selectedRow];
		LoginChar *ch = [login_table getCharacterAtIndex:index];
		charid = [ch charid];
		EveAPI *api = [[EveAPI alloc] initWithCharId:[ch charid] userId:[ch userid] apiKey:[ch apikey]];
		CharacterSet *cs = [[CharacterSet alloc] init];
		
		[cs setApi:api];
		
		Character *cha = [[cs api] characterSheetWithPool:sp database:db];
		if (cha == nil)
		{
			[login_spinner stopAnimation:self];
			return;
		}
		
		NSEnumerator *enumerator = [characters objectEnumerator];
		id obj;
		while (obj = [enumerator nextObject])
		{
			if ([[obj chara] charid] == [cha charid])
			{
				[self showInfo:@"This character is already being monitored." withInfoText:@"Select another. You don't need to watch the same character twice."];
				[login_spinner stopAnimation:self];
				return;
			}
		}
				
		
		[cs setCharacter:cha];
		[characters addObject:cs];
		
		new_chr = [characters indexOfObject:cs];
		
		[api release];
		[cs release];
	}
	
	// Reset the login window to its original state
	[login_charid removeAllItems];
	[login_charid setEnabled:NO];
	[login_save_box setState:NSOffState];
	[login_userid setStringValue:@""];
	[login_apikey setStringValue:@""];
			
	// Now add a new tab
	NSTabViewItem *tab_view = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%i",new_chr]];
	[tab_view setLabel: [[[characters objectAtIndex:new_chr] chara] name]];
	
	EveAPI *tapi = [[characters objectAtIndex:new_chr] api];
	NSLog([tapi apikey]);
	[db executeUpdate:[NSString stringWithFormat:@"delete from cache where charid = %i", [tapi charid]]];
	NSString *query = [NSString stringWithFormat:@"insert into cache (ordinal, charid, userid, apikey) VALUES (0, %i, %i, '%@')",
		[tapi charid], [tapi userid], [tapi apikey]];
	NSLog(query);
	[db executeUpdate:query];
	
	[tabs addTabViewItem:tab_view];
	[tabs selectLastTabViewItem:self];
	active_char = new_chr;
	[self refreshTab];
	[loginWindow orderOut:self];
	[login_spinner stopAnimation:self];
}


/**
 * Application findCharIds
 * Takes the values from the login window and retrieves
 * that apikey information's character list.
 **/
- (IBAction)findCharIds:(id)sender
{
	[login_spinner startAnimation:self];
	NSString *apikey = [login_apikey stringValue];
	int userid = [login_userid intValue];
	if ([apikey length] == 0 || userid == 0)
	{
		[self showInfo:@"Please enter your user ID and ApiKey." withInfoText:@"In order to find your character IDs, you will need to first enter your User ID and API Key from the Eve Online API Website."];
		[login_spinner stopAnimation:self];
		return;
	}
	EveAPI *api = [EveAPI apiWithCharId:0 user:userid apiKey:apikey];
	NSArray *char_list = [api characterList];
	
	if (char_list == nil)
	{
		[login_spinner stopAnimation:self];
		return;
	}
	
	[login_charid removeAllItems];
	NSEnumerator *enumerator = [char_list objectEnumerator];
	id anObject;
	while (anObject = [enumerator nextObject])
	{
		[login_charid addItemWithObjectValue:anObject];
	}
	
	[login_charid selectItemAtIndex:0];
	[login_charid setEnabled:YES];
	[login_spinner stopAnimation:self];
}


/**
 * Application new_character:
 * Shows the login Window for a new character's login
 **/
- (IBAction)new_character:(id)sender
{
	[loginWindow makeKeyAndOrderFront:self];
}

- (void) refreshAllData
{
	if (active_char == -1)
		return;
	[spinner startAnimation:self];
	NSEnumerator *enumerator = [characters objectEnumerator];
	id ch;
	while (ch = [enumerator nextObject])
	{
		[ch setTimer: 1];
		[ch decrementTimersWithPool:sp database:db];
	}
	[spinner stopAnimation:self];
}

- (IBAction)refreshData:(id)sender
{
	if (active_char == -1)
		return;
	CharacterSet *cs = [characters objectAtIndex:active_char];
	if ([cs timer] < 600)
	{
		[spinner startAnimation:self];
		[cs setTimer: 1];
		[cs decrementTimersWithPool:sp database:db];
		[self refreshTab];
		[spinner stopAnimation:self];
	}
	else if ([cs training] < 60)
	{
		[spinner startAnimation:self];
		[cs setTraining:1];
		[cs decrementTimersWithPool:sp database:db];
		[self refreshTab];
		[spinner stopAnimation:self];
	} 
	else
	{
		[self showInfo:@"Unable to Refresh Information" 
		  withInfoText:@"It has not yet been long enough to refresh information. Try again when the 'All' timer has less than 10 minutes remaining, or the 'Training' timer has less than 1 minute."];
	}
}


/**
 * Application showHideOverlay:
 * Shows/Hides the overlay. Duh.
 **/
- (IBAction)showHideOverlay:(id)sender
{
	if (active_char == -1)
		return;
	if (!overlayActive)
	{
		overlayActive = YES;
		overlay_char = active_char;
		NSRect screen = [[NSScreen mainScreen] frame];
		NSPoint oOrigin;
		oOrigin.x = screen.origin.x+10;
		oOrigin.y = screen.origin.y+10;
		[overlay_window setTitle:[[[characters objectAtIndex:overlay_char] chara] name]];
		[overlay_portrait setImage:[[[characters objectAtIndex:overlay_char] chara] portrait]];
		[overlay_window setFrameOrigin:oOrigin];
		[overlay_window setHidesOnDeactivate:NO];
		[overlay_window setLevel:NSFloatingWindowLevel];
		[overlay_window orderFrontRegardless];
	}
	else
	{
		overlayActive = NO;
		[overlay_window setHidesOnDeactivate:YES];
		[overlay_window orderOut:self];
	}
}


// NON IBActions FOLLOW


/**
 * Application refreshTab
 * Changes the visible information to be based upon what character 
 * is currently visible.
 **/
- (void) refreshTab
{
	if (active_char == -1)
	{
		[mainWindow setTitle:@"No One Selected"];
		[char_box setTitle:@"To Begin, Add a Tab Above"];
		[char_race setStringValue:@"To Begin, Add a Tab Above"];
		[char_charisma setStringValue:@"-"];
		[char_intelligence setStringValue:@"-"];
		[char_memory setStringValue:@"-"];
		[char_perception setStringValue:@"-"];
		[char_willpower setStringValue:@"-"];
		[char_known_skills setStringValue:@"-"];
		[char_vskills setStringValue:@"-"];
		[char_total_sp setStringValue:@"-"];
		[sp_hour setStringValue:@"-"];
		[cur_training setStringValue:@"- - -> -"];
		[completion_field setStringValue:@"Complete: -"];
		[char_image setImage:nil];
		[completion_indicator setDoubleValue:0.0];
	}
	else
	{
		CharacterSet *cs = [characters objectAtIndex:active_char];
		Character *ch = [cs chara];
		[char_image setImage:[ch portrait]];
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y %I:%M %p" allowNaturalLanguage:NO] autorelease];
		[formatter setFormat:@"#,##0.00"];
		[char_box setTitle:[NSString stringWithFormat:@"%@ - %@ - %@ ISK", 
			[ch name], [ch corp], [formatter stringFromNumber:[NSNumber numberWithFloat:[ch balance]]]]];
		[char_race setStringValue:[ch genderRaceBloodline]];
		[char_charisma setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch adjustedCharisma]]]];
		[char_intelligence setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch adjustedIntelligence]]]];
		[char_memory setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch adjustedMemory]]]];
		[char_perception setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch adjustedPerception]]]];
		[char_willpower setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch adjustedWillpower]]]];
		[char_known_skills setStringValue:[NSString stringWithFormat:@"%i",[ch numskills]]];
		[char_vskills setStringValue:[NSString stringWithFormat:@"%i", [ch vskills]]];
		[formatter setFormat:@"#,##0"];
		[char_total_sp setStringValue:[formatter stringFromNumber:[NSNumber numberWithFloat:[ch skillpoints]]]];
		[sp_hour setStringValue:[NSString stringWithFormat:@"%i", [[ch training] spPerHour]]];
		[cur_training setStringValue:[NSString stringWithFormat:@"%@ %@ -> %@", 
			[[[ch training] skill] name], [RomanNumerals toRoman:[[ch training] trainingToLevel] -1], 
			[RomanNumerals toRoman:[[ch training] trainingToLevel]]]];
		
		NSString *finalString = [[ch training] countdown];
		[mainWindow setTitle:[NSString stringWithFormat:@"%@ (%@)", [ch name], finalString]];
		[completion_field setStringValue:[NSString stringWithFormat:@"Complete: %@ (%@)", 
			[dateFormat stringFromDate:[[ch training] end]], finalString]];
		
		Skill *s = [[ch training] skill];
		NSEnumerator *e = [[s prereqs] objectEnumerator];
		NSLog(@"%@ requires: ", [s name]);
		id obj;
		while (obj = [e nextObject])
			NSLog(@"%@ at %i", [[obj skill] name], [obj level]);
		
	}		
}


/**
 * Application updateTimer:
 * Updates the application with every tick of a second
 **/
- (void) updateTimer:(NSTimer *) timer
{
	if (active_char == -1)
		return;
	NSEnumerator *enumerator = [characters objectEnumerator];
	id ch;
	while (ch = [enumerator nextObject])
	{
		[ch decrementTimersWithPool:sp database:db];
	}
	CharacterSet *cs = [characters objectAtIndex:active_char];
	TrainingSkill *ts = [[cs chara] training];
	int percent_done = 0;
	if ([[ts skill] typeID] != 0)
		percent_done = (((float)([ts actualSP] + [ts accumulatedSP]) / (float)[ts endsp]) * 100);
	[completion_indicator setDoubleValue:percent_done];
	
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setFormat:@"#,##0"];
	[char_total_sp setStringValue:[formatter stringFromNumber:
		[NSNumber numberWithFloat:[[cs chara] skillpoints] + [ts accumulatedSP]]]];
	
	[all_timer setStringValue:[cs formattedTimer]];
	[training_timer setStringValue:[cs formattedTraining]];
	
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y %I:%M %p" allowNaturalLanguage:NO] autorelease];
	NSString *finalString = [[[cs chara] training] countdown];
	[mainWindow setTitle:[NSString stringWithFormat:@"%@ (%@)", [[cs chara] name], finalString]];
	[completion_field setStringValue:[NSString stringWithFormat:@"Complete: %@ (%@)",
		[dateFormat stringFromDate:[[[cs chara] training] end]], finalString]];
	
	if (overlayActive)
	{
		ch = [[characters objectAtIndex:overlay_char] chara];
		finalString = [[ch training] countdown];
		percent_done = (((float)([[ch training] actualSP] + [[ch training] accumulatedSP]) / (float)[[ch training] endsp]) * 100);
		[self doOverlayWithCountdown:finalString andPercent: percent_done];
	}
}


/**
 * Application doOverlay
 * Updates the Always-On-Top overlay, if it is active.
 **/
- (void) doOverlayWithCountdown: (NSString *) finalString andPercent:(int) percent
{
	if (![overlay_window isVisible])
		overlayActive = NO;
	if (!overlayActive)
		return;
	CharacterSet *cs = [characters objectAtIndex:overlay_char];
	
	[overlay_cur_training setStringValue:
		[NSString stringWithFormat:@"%@ %@ -> %@", [[[[cs chara] training] skill] name],
			[RomanNumerals toRoman:[[[cs chara] training] trainingToLevel] - 1],
			[RomanNumerals toRoman:[[[cs chara] training] trainingToLevel]]]];
	
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y %I:%M %p" allowNaturalLanguage:NO] autorelease];
	[overlay_complete setStringValue:[NSString stringWithFormat:@"Complete: %@",
		[dateFormat stringFromDate:[[[cs chara] training] end]]]];
	[overlay_completion setStringValue:[NSString stringWithFormat:@"%@ Remaining", finalString]];
	[overlay_percent setStringValue:[NSString stringWithFormat:@"%i%% Complete", percent]];
}
	

/*********
*** TAB VIEW DELEGATE METHODS
**********/


/**
 * Application tabView:willCloseTabViewItem:
 * Cleans up after closed tabs
 **/
- (void) tabView:(NSTabView *)tabView willCloseTabViewItem:(NSTabViewItem *) tabViewItem
{
	/* 
    NSTabViewItem *ch;
	if ([tabs numberOfTabViewItems] > 1)
	{
		ch = [tabs tabViewItemAtIndex:[tabs numberOfTabViewItems] - 1];
		if ([ch identifier] == [tabViewItem identifier])
			ch = [tabs tabViewItemAtIndex:[tabs numberOfTabViewItems] - 2];
		active_char = [[ch identifier] intValue];
		[tabs selectLastTabViewItem:self];
	}
	else
	{
		active_char = -1;
		SkillTable *table = [skills dataSource];
		[table clearSkills];
	}
	*/
    int old = [[tabViewItem identifier] intValue];
	if ([tabs numberOfTabViewItems] > 1)
	{
		[tabs selectLastTabViewItem:self];
		if (active_char == old)
			[tabs selectPreviousTabViewItem:self];
	} else
	{
		active_char = -1;
		SkillTable *table = [skills dataSource];
		[table clearSkills];
		[table reloadData];
		[self refreshTab];
	}
		
	//NSLog([characters description]);
	
	[db executeUpdate:[NSString stringWithFormat:@"delete from cache where charid = %i", 
		[[[characters objectAtIndex:old] chara] charid]]];
	[characters removeObjectAtIndex:old];
	[self refreshTab];
}

- (void) tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *) tabViewItem
{
	int index = [[tabViewItem identifier] intValue];
	active_char = index;
	// Skill View stuff goes here
	SkillTable *table = [skills dataSource];
	[table setSkillGroups:[[[characters objectAtIndex:active_char] chara] skillgroups] 
				   skills:[[[characters objectAtIndex:active_char] chara] skills]
				 training:[[[characters objectAtIndex:active_char] chara] training]];
	[table setActiveGroup:[[[[characters objectAtIndex:active_char] chara] skillgroups] 
		objectAtIndex:0]];
	[table setSelectedGroup:0];
	[table reloadData];
	[self refreshTab];
}

- (BOOL) tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *) tabViewItem
{
	return YES;
}


/**
 * Application nextTab:
 * Selects the next tab
 **/
- (IBAction)nextTab:(id)sender
{
	[tabs selectNextTabViewItem:self];
}


/**
 * Application prevTab:
 * Selects the previous tab
 **/
- (IBAction)prevTab:(id)sender
{
	[tabs selectPreviousTabViewItem:self];
}


// ***
// Notification code
// ***


- (void) showInfo:(NSString *) title withInfoText:(NSString *) infoText
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:title];
	[alert setInformativeText:infoText];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:nil
					  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[alert release];
}


/**
 * Application refreshLoginTable
 * Refreshes the login table's data
 **/
- (void) refreshLoginTable
{
	login_table = [login_tab dataSource];
	[login_table clearCharList];
	
	FMResultSet *rs2 = [db executeQuery:@"select * from characters order by name asc"];
	while ([rs2 next])
	{
		LoginChar *chr = [[LoginChar alloc] initWithName:[rs2 stringForColumn:@"name"]
													corp:[rs2 stringForColumn:@"corp"]
												  charid:[rs2 intForColumn:@"charid"]
												  userid:[rs2 intForColumn:@"userid"]
												  apikey:[rs2 stringForColumn:@"apikey"]];
		
		NSData *imgData = [NSData dataWithBase64EncodedString:[rs2 stringForColumn:@"portrait"]];
		NSImage *img = [[NSImage alloc] initWithData:imgData];
		[chr setPortrait:img];
		[img release];
		
		[login_table addToCharList:chr];
		[chr release];
	}
	[login_tab reloadData];
}


/**
 * When the computer wakes up, the application will
 * refresh data
 **/
- (void) workspaceDidWake: (NSNotification *) note
{
	[self refreshAllData];
}


/**
 * Application pathForDataFile
 * Return the application support folder
 **/
- (NSString *) pathForDataFile: (NSString *) fileName
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Skill Monitor Cocoa/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
		[fileManager createDirectoryAtPath: folder attributes: nil];
	}
    
	return [folder stringByAppendingPathComponent: fileName];    
}


- (void) applicationWillTerminate:(NSNotification *) notification
{
	NSArray *order = [tab_strip representedTabViewItems];
	NSEnumerator *enumerator = [order objectEnumerator];
	id tab;
	int count = 1, charid = 0;
	while (tab = [enumerator nextObject])
	{
		charid = [[[characters objectAtIndex:[[tab identifier] intValue]] chara] charid];
		[db executeUpdate:[NSString stringWithFormat:@"update cache set ordinal = %i where charid = %i", count, charid]];
		count += 1;
	}
	[db close];
	[db release];
}

@end
