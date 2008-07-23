//
//  CharacterSet.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/23/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Character.h"
#import "EveAPI.h"

@interface CharacterSet : NSObject {
	Character *character;
	EveAPI *api;
	int timer, training;
}

- (CharacterSet *) init;
- (Character *) chara;
- (EveAPI *) api;
- (int) timer;
- (int) training;
- (NSString *) formattedTimer;
- (NSString *) formattedTraining;

- (void) setCharacter: (Character *) ch;
- (void) setApi: (EveAPI *) eve;
- (void) setTimer:(int) t;
- (void) setTraining:(int) t;
- (void) resetTimer;
- (void) resetTraining;
- (void) decrementTimersWithPool:(SkillPool *)pool database:(FMDatabase *) db;

@end
