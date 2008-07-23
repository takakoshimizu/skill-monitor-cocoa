//
//  CharacterSet.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/23/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "CharacterSet.h"


@implementation CharacterSet

- (CharacterSet *) init
{
	character = nil;
	api = nil;
	timer = 3600;
	training = 600;
	return self;
}

- (Character *) chara
{
	return character;
}

- (EveAPI *) api
{
	return api;
}

- (int) timer
{
	return timer;
}

- (NSString *) formattedTimer
{
	int mins = timer / 60;
	int secs = timer % 60;
	NSString *secString;
	if (secs < 10)
		secString = [NSString stringWithFormat:@"0%i", secs];
	else
		secString = [NSString stringWithFormat:@"%i", secs];
	NSString *minString = [NSString stringWithFormat:@"%i", mins];
	return [NSString stringWithFormat:@"%@:%@", minString, secString];
}

- (NSString *) formattedTraining
{
	int mins = training / 60;
	int secs = training % 60;
	NSString *secString;
	if (secs < 10)
		secString = [NSString stringWithFormat:@"0%i", secs];
	else
		secString = [NSString stringWithFormat:@"%i", secs];
	NSString *minString = [NSString stringWithFormat:@"%i", mins];
	return [NSString stringWithFormat:@"%@:%@", minString, secString];	
}

- (int) training
{
	return training;
}

- (void) setCharacter: (Character *) ch
{
	[character release];
	[ch retain];
	character = ch;
}

- (void) setApi: (EveAPI *) eve
{
	[api release];
	[eve retain];
	api = eve;
}

- (void) setTimer:(int) t
{
	timer = t;
}

- (void) setTraining:(int) t
{
	training = t;
}

- (void) resetTimer
{
	timer = 3600;
}

- (void) resetTraining
{
	training = 600;
}

- (void) decrementTimersWithPool:(SkillPool *)sp database:(FMDatabase *) db
{
	timer -= 1;
	training -= 1;
	if (timer == 0)
	{
		[character release];
		character = [api characterSheetWithPool:sp database:db];
		timer = 3600;
		training = 600;
	}
	if (training == 0)
	{
		[character setTraining:[api trainingSkillWithPool:sp]];
		training = 600;
	}
	if (![[character training] isComplete])
	{
		[[character training] accumulateSP];
		if ([[[character training] end] timeIntervalSinceNow] <= 0)
		{
			NSSound *sound = [NSSound soundNamed:@"SkillTrained"];
			[sound play];
			[[character training] setComplete:YES];
		}
	}	
}

- (void) dealloc
{
	[api release];
	[character release];
	[super dealloc];
}

@end
