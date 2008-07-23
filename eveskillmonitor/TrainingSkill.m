//
//  TrainingSkill.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/17/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "TrainingSkill.h"


@implementation TrainingSkill

- (TrainingSkill *) initWithId: (int) type pool: (SkillPool *) sp
{
	skill = [sp fetch:type];
	return self;
}

- (TrainingSkill *) initWithId: (int) type
					 startDate: (NSCalendarDate *) sdate
					   endDate: (NSCalendarDate *) edate
					   startSP: (int) ssp
						 endSP: (int) esp
						  pool: (SkillPool *) sp
{
	skill = [sp fetch:type];
	accumulated = 0.0;
	[self setStartDate: sdate];
	[self setEndDate: edate];
	[self setStartSP: ssp];
	[self setEndSP: esp];
	return self;
}

- (Skill *) skill
{
	return skill;
}

- (NSCalendarDate *) start
{
	return start;
}

- (NSCalendarDate *) end
{
	return end;
}

- (int) startsp
{
	return startsp;
}

- (int) endsp
{
	return endsp;
}

- (int) trainingToLevel
{
	return toLevel;
}

- (float) spPerSecond
{
	return spPerSecond;
}

- (int) actualSP
{
	return actualSP;
}

- (int) spPerHour
{
	return (int)round(spPerSecond * 3600);
}

- (bool) isComplete
{
	return complete;
}

- (float) accumulatedSP
{
	return accumulated;
}

- (NSString *) countdown
{
	if ([self isComplete])
		return @"COMPLETE!";
	NSString *finalString;
	NSTimeInterval timeInt = [[NSDate date] timeIntervalSinceDate:[self end]];
	int time = (int) timeInt;
	time = time < 0 ? -time : time;
	int days = time / 86400;
	int hours = (time - days * 86400) / 3600;
	int minutes = (time - days * 86400 - hours * 3600) / 60;
	int seconds = (time - days * 86400 - hours * 3600 - minutes * 60);
	NSString *dayString, *hourString, *minuteString, *secondString;
	if (days > 0)
		dayString = [NSString stringWithFormat:@"%id ", days];
	else
		dayString = @"";
	if (hours > 0)
		hourString = [NSString stringWithFormat:@"%ih ", hours];
	else
		hourString = @"";
	if (minutes > 0)
		minuteString = [NSString stringWithFormat:@"%im ", minutes];
	else
		minuteString = @"";
	if (seconds > 0)
		secondString = [NSString stringWithFormat:@"%is", seconds];
	else
		secondString = @"";
	
	finalString = [NSString stringWithFormat:@"%@%@%@%@", dayString, hourString, minuteString, secondString];

	return finalString;
}	

- (void) setStartDate: (NSCalendarDate *) date
{
	[date retain];
	start = date;
}

- (void) setEndDate: (NSCalendarDate *) date
{
	[date retain];
	end = date;
}

- (void) setStartDate: (NSCalendarDate *) sdate andEnd: (NSCalendarDate *) edate
{
	[self setStartDate: sdate];
	[self setEndDate: edate];
}

- (void) setStartSP: (int) sp
{
	startsp = sp;
}

- (void) setEndSP: (int) sp
{
	endsp = sp;
}

- (void) setToLevel: (int) level
{
	toLevel = level;
}

- (void) setStartSP: (int) ssp andEnd: (int) esp
{
	[self setStartSP: ssp];
	[self setEndSP: esp];
}

- (void) setActualSP: (int) sp
{
	actualSP = sp;
}

- (void) setSPPerSecond: (float) sp
{
	spPerSecond = sp;
	spPerHour = sp * 60 * 60;
}

- (void) setComplete: (bool) comp
{
	complete = comp;
}

- (void) accumulateSP
{
	accumulated += spPerSecond;
}

- (void) dealloc
{
	[start release];
	[end release];
	[skill release];
	[super dealloc];
}

@end