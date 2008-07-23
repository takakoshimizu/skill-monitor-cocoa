//
//  LearnedSkillGroup.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/28/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SkillGroup.h"
#import "SkillPool.h"

@interface LearnedSkillGroup : NSObject {
	LearnedSkillGroup *group;
	int points;
}

- (LearnedSkillGroup *) initWithGroupId:(int) groupID pool:(SkillPool *)sp;

- (SkillGroup *) group;
- (int) skillpoints;

- (void) setPoints: (int) sp;

@end
