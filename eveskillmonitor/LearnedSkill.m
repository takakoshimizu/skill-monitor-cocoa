//
//  LearnedSkill.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "LearnedSkill.h"


@implementation LearnedSkill

- (LearnedSkill *) initWithId: (int) typeid pool: (SkillPool *)sp
{
	skill = [sp fetch:typeid];
	return self;
}

- (Skill *) skill
{
	return skill;
}

- (int) level
{
	return level;
}

- (int) skillpoints
{
	return skillpoints;
}

- (int) groupid
{
	return [skill groupID];
}

- (void) setLevel: (int) lv
{
	level = lv;
}

- (void) setSkillpoints: (int) sp
{
	skillpoints = sp;
}

- (void) dealloc
{
	[skill release];
	[super dealloc];
}

@end
