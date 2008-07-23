//
//  Character.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "Character.h"

@implementation Character

- (Character *) initWithCharacterId: (int) charID database:(FMDatabase *) db
{
	charid = charID;
	portrait = nil;
	skills = [[NSMutableArray alloc] initWithCapacity: 50];
	skillgroups = [[NSMutableArray alloc] initWithCapacity: 7];
	[self retrieveImplantsWithDb:db];
	return self;
}

+ (Character *) characterWithId: (int) charID database:(FMDatabase *) db
{
	return [[[Character alloc] initWithCharacterId:charID database:db] autorelease];
}

- (Character *) initWithCharacterId: (int) charID
							   name: (NSString *) nm
						   database: (FMDatabase *) db
{
	charid = charID;
	[self setName:nm];
	skills = [[NSMutableArray alloc] initWithCapacity: 50];
	skillgroups = [[NSMutableArray alloc] initWithCapacity: 7];
	[self retrieveImplantsWithDb:db];
	return self;
}

- (int) charid
{
	return charid;
}

- (int) numskills
{
	return numskills;
}

- (int) vskills
{
	return vskills;
}

- (int) intmod
{
	return intmod;
}

- (int) chamod
{
	return chamod;
}

- (int) permod
{
	return permod;
}

- (int) memmod
{
	return memmod;
}

- (int) wilmod
{
	return wilmod;
}

- (float) skillpoints
{
	return skillpoints;
}

- (float) learning
{
	return learning;
}

- (float) balance
{
	return balance;
}

- (float) intelligence
{
	return intelligence;
}

- (float) charisma
{
	return charisma;
}

- (float) perception
{
	return perception;
}

- (float) memory
{
	return memory;
}

- (float) willpower
{
	return willpower;
}

- (float) adjustedIntelligence
{
	return intelligence + (intelligence * learning) + intmod;
}

- (float) adjustedCharisma
{
	return charisma + (charisma * learning) + chamod;
}

- (float) adjustedPerception
{
	return perception + (perception * learning) + permod;
}

- (float) adjustedMemory
{
	return memory + (memory * learning) + memmod;
}

- (float) adjustedWillpower
{
	return willpower + (willpower * learning) + wilmod;
}

- (NSString *) name
{
	return name;
}

- (NSString *) race
{
	return race;
}

- (NSString *) bloodline
{
	return bloodline;
}

- (NSString *) gender
{
	return gender;
}

- (NSString *) corp
{
	return corp;
}

- (NSString *) genderRaceBloodline
{
	return [NSString stringWithFormat:@"%@ %@ %@", gender, race, bloodline];
}

- (NSMutableArray *) skills
{
	return skills;
}

- (NSMutableArray *) skillgroups
{
	return skillgroups;
}

- (TrainingSkill *) training
{
	return training;
}

- (NSImage *) portrait
{
	return portrait;
}

- (void) setPortrait: (NSImage *) img
{
	[img retain];
	[portrait release];
	portrait = img;
}

- (void) setNumSkills: (int) num
{
	numskills = num;
}

- (void) setVSkills: (int) num
{
	vskills = num;
}

- (void) setSkillPoints: (float) num
{
	skillpoints = num;
}

- (void) setLearning: (float) num
{
	learning = num;
}

- (void) setBalance: (float) num
{
	balance = num;
}

- (void) setIntelligence: (float) num
{
	intelligence = num;
}

- (void) setCharisma: (float) num
{
	charisma = num;
}
- (void) setPerception: (float) num
{
	perception = num;
}

- (void) setMemory: (float) num
{
	memory = num;
}

- (void) setWillpower: (float) num
{
	willpower = num;
}

- (void) setName: (NSString *) nm
{
	[nm retain];
	name = nm;
}

- (void) setRace: (NSString *) rc
{
	[rc retain];
	race = rc;
}

- (void) setBloodline: (NSString *) bl
{
	[bl retain];
	bloodline = bl;
}

- (void) setGender: (NSString *) gd
{
	[gd retain];
	gender = gd;
}

- (void) setCorp: (NSString *) cp
{
	[cp retain];
	corp = cp;
}

- (void) addSkill: (LearnedSkill *) ls
{
	[skills addObject:ls];
}

- (void) addSkillGroup: (LearnedSkillGroup *) sg
{
	[skillgroups addObject:sg];
}	

- (void) setTraining: (TrainingSkill *) tr
{
	[tr retain];
	[training release];
	training = tr;
}

- (void) retrieveImplantsWithDb: (FMDatabase *) db
{
	FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from implants where charid = %i", charid]];
	if ([rs next])
	{
		intmod = [rs intForColumn:@"intmod"];
		chamod = [rs intForColumn:@"chamod"];
		memmod = [rs intForColumn:@"memmod"];
		permod = [rs intForColumn:@"permod"];
		wilmod = [rs intForColumn:@"wilmod"];
	}
	else
	{
		intmod = 0;
		chamod = 0;
		memmod = 0;
		permod = 0;
		wilmod = 0;
	}
}

- (void) saveImplantsWithDb: (FMDatabase *) db intelligence:(int) intel
					 memory: (int) mem charisma: (int) cha perception: (int) per
				  willpower: (int) wil
{
	[db executeUpdate:[NSString stringWithFormat:@"delete from implants where charid = %i", charid]];
	intmod = intel;
	chamod = cha;
	memmod = mem;
	permod = per;
	wilmod = wil;
	[db executeUpdate:[NSString stringWithFormat:@"insert into implants values (%i, %i, %i, %i, %i, %i)", charid, intel, mem, cha, per, wil]];
}	


- (void) flushSkills
{
	[skills removeAllObjects];
	[skillgroups removeAllObjects];
}

- (void) dealloc
{
	[portrait release];
	[name release];
	[gender release];
	[race release];
	[bloodline release];
	[corp release];
	[skills release];
	[training release];
	[super dealloc];
}

@end