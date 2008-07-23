//
//  Skill.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/6/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Prereq.h"

@interface Skill : NSObject {
	int typeID, groupID, rank;
	NSString *name, *description;
	//NSMutableDictionary *prereqs;
	NSMutableArray *prereqs;
}

- (Skill *) initWithId: (int) type;
- (int) typeID;
- (int) groupID;
- (int) rank;
- (NSString *) name;
- (NSString *) description;
- (NSDictionary *) prereqs;

- (void) setGroupID: (int) group;
- (void) setRank: (int) rk;
- (void) setName: (NSString *) nm;
- (void) setDescription: (NSString *) desc;
- (void) addPrereq: (Skill *)sk atLevel:(int) level;

@end
