//
//  LoginChar.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/23/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginChar : NSObject {
	NSImage *portrait;
	NSString *name, *corp, *apikey;
	int charid, userid;
}

- (LoginChar *) initWithName: (NSString *) nm
						corp: (NSString *) cp
					  charid: (int) ch
					  userid: (int) user
					  apikey: (NSString *) api;

- (id) objectForColumn: (int) col;
- (int) charid;
- (int) userid;
- (NSString *) apikey;

- (void) setPortrait: (NSImage *) port;

@end
