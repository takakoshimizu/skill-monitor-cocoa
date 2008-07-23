//
//  EveAPI.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "EveAPI.h"


@implementation EveAPI

- (EveAPI *) initWithCharId: (int) ch 
				 userId: (int) user 
				 apiKey: (NSString *) key
{
	API_ADDR = [[NSString alloc] initWithString:@"http://api.eve-online.com/"];
	charid = ch;
	userid = user;
	apikey = [key retain];
	authenticationFailed = NO;
	return self;
}

+ (EveAPI *) apiWithCharId: (int) ch
					  user: (int) user
					apiKey: (NSString *) key
{
	return [[[EveAPI alloc] initWithCharId:ch userId:user apiKey:key] autorelease];
}

- (int) charid
{
	return charid;
}

- (int) userid
{
	return userid;
}

- (NSString *) apikey
{
	return apikey;
}

- (XMLTree *) request: (NSString *) uri
{
	if (authenticationFailed)
		return nil;
	NSString *url = [[API_ADDR stringByAppendingString:uri] 
			stringByAppendingString:
				[NSString stringWithFormat:@"?userid=%i&characterid=%i&apikey=%@", userid, charid, apikey]];
	NSURL *theURL = [NSURL URLWithString:url];
	XMLTree *tree = [[XMLTree alloc] initWithURL:theURL];
	if ([tree descendentNamed:@"error"])
	{
		NSLog(@"%@", [tree xml]);
		[self authenticationFailed];
		return nil;
	}	
	return tree;
}

- (Character *) characterSheetWithPool: (SkillPool *) sp database: (FMDatabase *) db
{
	Character *ch;
	XMLTree *tree = [self request:@"char/CharacterSheet.xml.aspx"];
	if(authenticationFailed || tree == nil)
	{
		return nil;
	}
	XMLTree *tree2 = [tree descendentNamed:@"result"];
	//[tree release];
	int cid = [[[tree2 descendentNamed:@"characterID"] description] intValue];
	ch = [[Character alloc] initWithCharacterId:cid
										   name:[[tree2 descendentNamed:@"name"] description]
									   database:db];
	[ch setRace:[[tree2 descendentNamed:@"race"] description]];
	[ch setBloodline:[[tree2 descendentNamed:@"bloodLine"] description]];
	[ch setGender:[[tree2 descendentNamed:@"gender"] description]];
	[ch setCorp:[[tree2 descendentNamed:@"corporationName"] description]];
	[ch setBalance:[[[tree2 descendentNamed:@"balance"] description] floatValue]];
		
	XMLTree *tree3 = [tree2 descendentNamed:@"attributes"];
	[ch setIntelligence:[[[tree3 descendentNamed:@"intelligence"] description] floatValue]];
	[ch setMemory:[[[tree3 descendentNamed:@"memory"] description] floatValue]];
	[ch setCharisma:[[[tree3 descendentNamed:@"charisma"] description] floatValue]];
	[ch setPerception:[[[tree3 descendentNamed:@"perception"] description] floatValue]];
	[ch setWillpower:[[[tree3 descendentNamed:@"willpower"] description] floatValue]];
	
	XMLTree *tree4 = [tree2 descendentNamed:@"rowset"];
	
	[ch setTraining:[self trainingSkillWithPool:sp]];
	
	int i = 0, skp = 0, numskills = 0, vskills = 0, groupsp = 0, lastgroup = 0;
	LearnedSkillGroup *sg = nil;
	XMLTree *sk;
	[ch flushSkills];
	for (i; i < [tree4 count];i++)
	{
		sk = [tree4 childAtIndex:i];
		LearnedSkill *ls = [[LearnedSkill alloc] initWithId:[[sk attributeNamed:@"typeID"] intValue] pool:sp];
		if ([[ls skill] typeID] == [[[ch training] skill] typeID])
		{
			if (![[ch training] isComplete])
				[ls setLevel:[[sk attributeNamed:@"level"] intValue]];
			else
				[ls setLevel:[[ch training] trainingToLevel]];
			[ls setSkillpoints:[[ch training] actualSP]];
		}
		else
		{
			[ls setLevel:[[sk attributeNamed:@"level"] intValue]];
			[ls setSkillpoints:[[sk attributeNamed:@"skillpoints"] intValue]];
		}
		skp += (int)[ls skillpoints];
		numskills += 1;
		if ([ls level] == 5)
			vskills += 1;
		// populate skillgroups
		if (lastgroup == 0)
		{
			sg = [[LearnedSkillGroup alloc] initWithGroupId:[[ls skill] groupID] pool:sp];
			lastgroup = [[ls skill] groupID];
		}
		if ([[ls skill] groupID] != lastgroup)
		{
			[sg setPoints:groupsp];
			[ch addSkillGroup:sg];
			[sg release];
			lastgroup = [[ls skill] groupID];
			sg = [[LearnedSkillGroup alloc] initWithGroupId:[[ls skill] groupID] pool:sp];
			groupsp = (int)[ls skillpoints];
		} else
			groupsp += (int) [ls skillpoints];
		[ch addSkill:ls];
		
		// Consider learning
		if ([[ls skill] typeID] == 3378 || [[ls skill] typeID] == 12385)
			[ch setMemory:([ch memory] + (1.0 * [ls level]))];
		if ([[ls skill] typeID] == 3377 || [[ls skill] typeID] == 12376)
			[ch setIntelligence:([ch intelligence] + (1.0 * [ls level]))];
		if ([[ls skill] typeID] == 3379 || [[ls skill] typeID] == 12387)
			[ch setPerception:([ch perception] + (1.0 * [ls level]))];
		if ([[ls skill] typeID] == 3375 || [[ls skill] typeID] == 12386)
			[ch setWillpower:([ch willpower] + (1.0 * [ls level]))];
		if ([[ls skill] typeID] == 3376 || [[ls skill] typeID] == 12383)
			[ch setCharisma:([ch charisma] + (1.0 * [ls level]))];
		if ([[ls skill] typeID] == 3374)
			[ch setLearning:(0.02 * [ls level])];
	}
	
	[sg setPoints:groupsp];
	[ch addSkillGroup:sg];
	[sg release];
	
	[ch setSkillPoints:(float)skp];
	[ch setNumSkills:numskills];
	[ch setVSkills:vskills];
	
	NSImage *portrait = [[NSImage alloc] initWithContentsOfURL:
		[NSURL URLWithString:[NSString stringWithFormat:@"http://img.eve.is/serv.asp?s=256&c=%i", [ch charid]]]];
	[ch setPortrait:portrait];
	[portrait release];
		
	return ch;
}

- (TrainingSkill *) trainingSkillWithPool: (SkillPool *) sp
{
	id skill;
	XMLTree *tree = [self request:@"char/SkillInTraining.xml.aspx"];
	if (authenticationFailed || tree == nil)
	{
		skill = [[TrainingSkill alloc] initWithId:0 pool:sp];
		return skill;
	}
	XMLTree *tree2 = [tree descendentNamed:@"result"];
	[tree release];
	if ([[NSString stringWithString:[[tree2 descendentNamed:@"skillInTraining"] description]] intValue] == 0)
	{
		skill = [[TrainingSkill alloc] initWithId:0 pool:sp];
		return skill;
	}
	int typeId = [[[tree2 descendentNamed:@"trainingTypeID"] description] intValue];
	skill = [[TrainingSkill alloc] initWithId:typeId pool:sp];
	// Change time zones on dates
	//int hour_diff = [[NSTimeZone localTimeZone] secondsFromGMT];
	NSDate *start = [[NSDate alloc] initWithTimeInterval:0 
											   sinceDate:[NSDate dateWithNaturalLanguageString:
												   [[tree2 descendentNamed:@"trainingStartTime"] description]]];
	NSDate *end = [[NSDate alloc] initWithTimeInterval:0 
											 sinceDate:[NSDate dateWithNaturalLanguageString:
												   [[tree2 descendentNamed:@"trainingEndTime"] description]]];	
	
	[skill setStartDate:start];
	[skill setEndDate:end];
	[skill setStartSP:[[[tree2 descendentNamed:@"trainingStartSP"] description] intValue]];
	[skill setEndSP:[[[tree2 descendentNamed:@"trainingDestinationSP"] description] intValue]];
	[skill setToLevel:[[[tree2 descendentNamed:@"trainingToLevel"] description] intValue]];
	
	[start release];
	[end release];
		
	// Time to parse out all the stupid junk
	int difference;
	float spdiff, sp_per_second;
	
	difference = (int)[[skill end] timeIntervalSinceDate:[(TrainingSkill*)skill start]];
	difference = difference > 0 ? difference : -difference;
	spdiff = [skill endsp] - [skill startsp];
	sp_per_second = (float)spdiff / (float)difference;
	sp_per_second = sp_per_second > 0 ? sp_per_second : -sp_per_second;
	
	[skill setSPPerSecond:sp_per_second];
	
	// And now to figure out completion time
	if ([[skill end] timeIntervalSinceNow] < 0)
	{
		[skill setComplete:YES];
		[skill setActualSP:[skill endsp]];
	}
	else
	{
		[skill setComplete:NO];
		int num_secs = [[(TrainingSkill *)skill start] timeIntervalSinceNow];
		num_secs = num_secs > 0 ? num_secs : -num_secs;
		int actual_sp = ([skill startsp] + (int)(num_secs * [skill spPerSecond]));
		[skill setActualSP:actual_sp];
	}
	
	// Finally, return the parsed training object
	return skill;
}

- (NSArray *) characterList
{
	int i = 0, count = 0;
	NSMutableArray *chars = [NSMutableArray arrayWithCapacity:3];
	XMLTree *tree = [self request:@"account/Characters.xml.aspx"];
	if (authenticationFailed || tree == nil)
		return nil;
	XMLTree *tree2 = [tree descendentNamed:@"rowset"];
	if (!tree2)
	{
		NSLog(@"Didn't find the rowset descendent!");
		return nil;
	}
	count = [tree2 count];
	for (i = 0;i < count;i++)
	{
		[chars addObject:[NSString stringWithFormat:@"%@ - %@",
			[[tree2 childAtIndex:i] attributeNamed:@"name"],
			[[tree2 childAtIndex:i] attributeNamed:@"characterID"]]];
	}
	return chars;
}

- (void) authenticationFailed
{
    // I'm making a note here: huge failure.
	authenticationFailed = YES;
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Authentication Failed"];
	[alert setInformativeText:@"Authentication has failed. Your user ID, character ID, or API Key may be incorrect."];
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

- (void) dealloc
{
	[apikey release];
	[super dealloc];
}

@end