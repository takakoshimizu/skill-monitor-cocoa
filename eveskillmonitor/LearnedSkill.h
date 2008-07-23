//
//  LearnedSkill.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Skill.h"
#import "SkillPool.h"

@interface LearnedSkill : NSObject {
	Skill *skill;
	int level, skillpoints;
}

- (LearnedSkill *) initWithId: (int) typeid pool: (SkillPool *)sp;
- (Skill *) skill;
- (int) level;
- (int) skillpoints;
- (int) groupid;

- (void) setLevel: (int) lv;
- (void) setSkillpoints: (int) sp;

@end