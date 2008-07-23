//
//  SkillPool.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/17/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "SkillPool.h"


@implementation SkillPool

- (SkillPool *) initWithDB: (FMDatabase *) db
{
	skillGroups = [[NSMutableDictionary alloc] initWithCapacity: 20];
	skills = [[NSMutableDictionary alloc] initWithCapacity: 200];
	
	Skill *nil_skill = [[Skill alloc] initWithId:0];
	[nil_skill setName:@"Nothing"];
	[skills setObject:nil_skill forKey:@"0"];
	[nil_skill release];
	
	FMResultSet *rs = [db executeQuery:@"select * from skillgroups"];
	
	while ([rs next])
	{
		SkillGroup *sg = [[SkillGroup alloc] initWithId:[rs intForColumn:@"groupid"]];
		[sg setName:[rs stringForColumn:@"name"]];
		[skillGroups setObject:sg forKey:[NSString stringWithFormat:@"%i",[rs intForColumn:@"groupid"]]];
	}
	[rs close];
	
	rs = [db executeQuery:@"select * from skills"];
	
	while ([rs next])
	{
		Skill *skill = [[Skill alloc] initWithId:[rs intForColumn:@"typeid"]];
		[skill setName:[rs stringForColumn:@"name"]];
		[skill setGroupID:[rs intForColumn:@"groupid"]];
		[skill setRank:[rs intForColumn:@"rank"]];
		[skill setDescription:@""];
		[skills setObject:skill forKey:[NSString stringWithFormat:@"%i",[rs intForColumn:@"typeid"]]];
	}
	[rs close];
	[self doPrereqsWithDb:db];
	return self;
}

- (Skill *) fetch: (int) skillID
{
	Skill *skill = [skills objectForKey:[NSString stringWithFormat:@"%i",skillID]];
	return skill;
}
	
- (SkillGroup *) fetchGroup: (int) groupID
{
	SkillGroup *group = [skillGroups objectForKey:[NSString stringWithFormat:@"%i",groupID]];
	return group;
}

- (void) doPrereqsWithDb:(FMDatabase *) db
{
	NSEnumerator *e = [skills objectEnumerator];
	id obj;
	while (obj = [e nextObject])
	{
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from prerequisites where typeid = %i", [obj typeID]]];
		while ([rs next])
		{
			[obj addPrereq:[self fetch:[rs intForColumn:@"required_id"]] atLevel:[rs intForColumn:@"required_level"]];
		}
	}
}

- (void) dealloc
{
	[skills release];
	[skillGroups release];
	[super dealloc];
}
@end
