//
//  LoginChar.m
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/23/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import "LoginChar.h"


@implementation LoginChar

- (LoginChar *) initWithName: (NSString *) nm
						corp: (NSString *) cp
					  charid: (int) ch
					  userid: (int) user
					  apikey: (NSString *) api
{
	[nm retain];
	[cp retain];
	[api retain];
	name = nm;
	corp = cp;
	apikey = api;
	charid = ch;
	userid = user;
	portrait = nil;
	return self;
}	

- (id) objectForColumn: (int) col
{
	if (col == 0)
		return portrait;
	else
	{
		NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", name, corp]] autorelease];
		NSRange range;
		range.location = 0;
		range.length = [name length];
		NSFont *font = [NSFont boldSystemFontOfSize:12];
		[str addAttribute:NSFontAttributeName value:font range:range];
		range.location = range.length;
		range.length = [str length] - range.length;
		font = [NSFont systemFontOfSize:10];
		[str addAttribute:NSFontAttributeName value:font range:range];
		return str;
	}
}

- (int) charid
{
	return charid;
}

- (int) userid
{
	return userid;
}

- (NSString *) apikey
{
	return apikey;
}

- (void) setPortrait: (NSImage *) port
{
	[portrait release];
	[port retain];
	portrait = port;
}

- (void) dealloc
{
	[name release];
	[corp release];
	[apikey release];
	[portrait release];
	[super dealloc];
}

@end
