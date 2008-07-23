//
//  Prereq.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 9/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Prereq.h"


@implementation Prereq

- (Prereq *) initWithSkill:(id) sk andLevel: (int) l
{
	skill = sk;
	level = l;
	return self;
}

- (id) skill
{
	return skill;
}

- (int) level
{
	return level;
}

@end
