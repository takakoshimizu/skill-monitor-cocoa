//
//  Prereq.h
//  Skill Monitor Cocoa
//
//  Created by Takamachi Nanoha on 9/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Prereq : NSObject {
	id skill;
	int level;
}

- (Prereq *) initWithSkill:(id) sk andLevel: (int) l;
- (id) skill;
- (int) level;

@end
