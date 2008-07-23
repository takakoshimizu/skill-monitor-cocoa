//
//  LearnedSkillGroup.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/28/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "LearnedSkillGroup.h"


@implementation LearnedSkillGroup

- (LearnedSkillGroup *) initWithGroupId:(int) groupID pool:(SkillPool *)sp
{
	group = [sp fetchGroup:groupID];
	points = 0;
	return self;
}

- (SkillGroup *) group
{
	return group;
}

- (int) skillpoints
{
	return points;
}

- (void) setPoints: (int) sp
{
	points = sp;
}

@end
