//
//  TrainingSkill.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/17/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Skill.h"
#import "SkillPool.h"

@interface TrainingSkill : NSObject {
	Skill *skill;
	NSCalendarDate *start, *end;
	int startsp, endsp, actualSP, toLevel;
	float spPerHour, spPerSecond, accumulated;
	bool complete;
}

- (TrainingSkill *) initWithId: (int) type pool: (SkillPool *) sp;
- (TrainingSkill *) initWithId: (int) type
					 startDate: (NSCalendarDate *) sdate
					   endDate: (NSCalendarDate *) edate
					   startSP: (int) ssp
						 endSP: (int) esp
						  pool: (SkillPool *) sp;
- (Skill *) skill;
- (NSCalendarDate *) start;
- (NSCalendarDate *) end;
- (int) startsp;
- (int) endsp;
- (int) trainingToLevel;
- (float) spPerSecond;
- (int) actualSP;
- (int) spPerHour;
- (bool) isComplete;
- (float) accumulatedSP;
- (NSString *) countdown;


- (void) setStartDate: (NSCalendarDate *) date;
- (void) setEndDate: (NSCalendarDate *) date;
- (void) setStartDate: (NSCalendarDate *) sdate andEnd: (NSCalendarDate *) edate;
- (void) setStartSP: (int) sp;
- (void) setEndSP: (int) sp;
- (void) setToLevel: (int) level;
- (void) setStartSP: (int) ssp andEnd: (int) esp;
- (void) setActualSP: (int) sp;
- (void) setSPPerSecond: (float) sp;
- (void) setComplete: (bool) comp;
- (void) accumulateSP;

@end