//
//  SkillPool.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/17/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "Skill.h"
#import "SkillGroup.h"

@interface SkillPool : NSObject {
	NSMutableDictionary *skillGroups, *skills;	
}

- (SkillPool *) initWithDB: (FMDatabase *) db;
- (Skill *) fetch: (int) skillID;
- (SkillGroup *) fetchGroup: (int) groupID;

- (void) doPrereqsWithDb:(FMDatabase *) db;

@end
