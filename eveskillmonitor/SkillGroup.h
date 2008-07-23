//
//  SkillGroup.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 8/16/07.
//  Copyright 2007 Mahora Gakuen Software Div. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SkillGroup : NSObject {
	int groupID;
	NSString *name;
}

- (SkillGroup *) initWithId: (int) type;
- (int) groupID;
- (NSString *) name;

- (void) setName: (NSString *) nm;

@end