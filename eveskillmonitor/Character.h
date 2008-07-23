//
//  Character.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LearnedSkill.h"
#import "LearnedSkillGroup.h"
#import "TrainingSkill.h"
#import "SkillPool.h"
#import "FMDatabase.h"


@interface Character : NSObject {
	int charid, numskills, vskills, intmod, chamod, permod, memmod, wilmod;
	float skillpoints, learning, balance, intelligence, charisma, perception, memory, willpower;
	NSString *name, *race, *bloodline, *gender, *corp;
	NSMutableArray *skills, *skillgroups;
	TrainingSkill *training;
	NSImage *portrait;
}

- (Character *) initWithCharacterId: (int) charID database: (FMDatabase *) db;
+ (Character *) characterWithId: (int) charID database: (FMDatabase *) db;
- (Character *) initWithCharacterId: (int) charID
							   name: (NSString *) nm
						   database: (FMDatabase *) db;
- (int) charid;
- (int) numskills;
- (int) vskills;
- (int) intmod;
- (int) chamod;
- (int) permod;
- (int) memmod;
- (int) wilmod;
- (float) skillpoints;
- (float) learning;
- (float) balance;
- (float) intelligence;
- (float) charisma;
- (float) perception;
- (float) memory;
- (float) willpower;
- (float) adjustedIntelligence;
- (float) adjustedCharisma;
- (float) adjustedPerception;
- (float) adjustedMemory;
- (float) adjustedWillpower;
- (NSString *) name;
- (NSString *) race;
- (NSString *) bloodline;
- (NSString *) gender;
- (NSString *) corp;
- (NSString *) genderRaceBloodline;
- (NSMutableArray *) skills;
- (NSMutableArray *) skillgroups;
- (TrainingSkill *) training;
- (NSImage *) portrait;

- (void) setPortrait: (NSImage *) img;
- (void) setNumSkills: (int) num;
- (void) setVSkills: (int) num;
- (void) setSkillPoints: (float) num;
- (void) setLearning: (float) num;
- (void) setBalance: (float) num;
- (void) setIntelligence: (float) num;
- (void) setCharisma: (float) num;
- (void) setPerception: (float) num;
- (void) setMemory: (float) num;
- (void) setWillpower: (float) num;
- (void) setName: (NSString *) nm;
- (void) setRace: (NSString *) rc;
- (void) setBloodline: (NSString *) bl;
- (void) setGender: (NSString *) gd;
- (void) setCorp: (NSString *) cp;
- (void) addSkill: (LearnedSkill *) ls;
- (void) addSkillGroup: (LearnedSkillGroup *) sg;
- (void) setTraining: (TrainingSkill *) tr;

- (void) retrieveImplantsWithDb: (FMDatabase *) db;
- (void) saveImplantsWithDb: (FMDatabase *) db intelligence:(int) intel
					 memory: (int) mem charisma: (int) cha perception: (int) per
				  willpower: (int) wil;

- (void) flushSkills;

@end