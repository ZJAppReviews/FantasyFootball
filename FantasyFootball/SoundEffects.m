//
//  SoundEffects.m
//  MyMortgage
//
//  Created by Mark Riley on 12/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundEffects.h"
#import "SoundEffect.h"

SoundEffect* cashSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cash" ofType:@"wav"]];
    
    return click;
}

SoundEffect* clickSound() {
	static SoundEffect *click = nil;
	if (click == nil)
		click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"]];
	
	return click;
}

SoundEffect* swooshSound() {
	static SoundEffect *swoosh = nil;
	if (swoosh == nil)
		swoosh = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"swosh" ofType:@"wav"]];
	
	return swoosh;
}

SoundEffect* wandSound() {
	static SoundEffect *wand = nil;
	if (wand == nil)
		wand = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magic_wand" ofType:@"wav"]];
	
	return wand;
}

