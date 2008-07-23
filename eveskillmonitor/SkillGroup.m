//
//  SkillGroup.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/16/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "SkillGroup.h"


@implementation SkillGroup

- (SkillGroup *) initWithId: (int) type
{
	groupID = type;
	return self;
}

- (int) groupID
{
	return groupID;
}

- (NSString *) name
{
	return name;
}

- (void) setName: (NSString *) nm
{
	[nm retain];
	name = nm;
}

- (void) dealloc
{
	[name release];
	[super dealloc];
}

@end
