//
//  RomanNumerals.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/27/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "RomanNumerals.h"


@implementation RomanNumerals

+ (NSString *) toRoman:(int) val
{
	if (val == 1)
		return @"I";
	if (val == 2)
		return @"II";
	if (val == 3)
		return @"III";
	if (val == 4)
		return @"IV";
	if (val == 5)
		return @"V";
	return @"O";
}

@end
