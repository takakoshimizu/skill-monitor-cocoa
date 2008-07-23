//
//  EveAPI.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/19/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLTree.h"
#import "SkillPool.h"
#import "Character.h"
#import "LearnedSkillGroup.h"
#import "TrainingSkill.h"
#import "FMDatabase.h"


@interface EveAPI : NSObject {
	NSString *API_ADDR;
	int charid, userid;
	NSString *apikey;
	bool authenticationFailed;
}

- (EveAPI *) initWithCharId: (int) ch 
				 userId: (int) user 
				 apiKey: (NSString *) key;

+ (EveAPI *) apiWithCharId: (int) ch
					  user: (int) user
					apiKey: (NSString *) key;

- (int) charid;
- (int) userid;
- (NSString *) apikey;
- (XMLTree *) request: (NSString *) uri;
- (Character *) characterSheetWithPool: (SkillPool *) sp database: (FMDatabase *) db;
- (TrainingSkill *) trainingSkillWithPool: (SkillPool *) sp;
- (NSArray *) characterList;
- (void) authenticationFailed;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;


@end
