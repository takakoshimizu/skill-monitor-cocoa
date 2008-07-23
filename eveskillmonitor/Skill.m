//
//  Skill.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/6/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "Skill.h"


@implementation Skill

- (Skill *) initWithId: (int) type
{
	typeID = type;
	//prereqs = [[NSMutableDictionary alloc] initWithCapacity:1];
	prereqs = [[NSMutableArray alloc] initWithCapacity:1];
	return self;
}

- (int) typeID
{
	return typeID;
}

- (int) groupID
{
	return groupID;
}

- (int) rank
{
	return rank;
}

- (NSString *) name
{
	return name;
}

- (NSString *) description
{
	return description;
}

- (NSDictionary *) prereqs
{
	return [prereqs copy];
}

- (void) setGroupID: (int) group
{
	groupID = group;
}

- (void) setRank: (int) rk
{
	rank = rk;
}

- (void) setName: (NSString *) nm
{
	[nm retain];
	name = nm;
}

- (void) setDescription: (NSString *) desc
{
	[desc retain];
	description = desc;
}

- (void) addPrereq: (Skill *)sk atLevel:(int) level
{
	Prereq *p = [[Prereq alloc] initWithSkill:sk andLevel:level];
	[prereqs addObject:p];
	//[prereqs setObject:[NSString stringWithFormat:@"%i", level] forKey:sk];
}

- (void) dealloc
{
	[name release];
	[description release];
	[prereqs release];
	[super dealloc];
}

@end
