//
//  SoundEffects.m
//  MyMortgage
//
//  Created by Mark Riley on 12/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SoundEffects.h"
#import "SoundEffect.h"

SoundEffect* toiletSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toilet" ofType:@"wav"]];
    
    return click;
}

SoundEffect* youKnowWeveBeenCheatedSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"you_know_weve_been_cheated" ofType:@"wav"]];
    
    return click;
}

SoundEffect* youCannotWaitSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"you_cannot_wait" ofType:@"wav"]];
    
    return click;
}

SoundEffect* weAreInTroubleSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"we_are_in_trouble" ofType:@"wav"]];
    
    return click;
}

SoundEffect* tuckInMoreSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tuck_in_more" ofType:@"wav"]];
    
    return click;
}

SoundEffect* sharpeySound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sharpey" ofType:@"wav"]];
    
    return click;
}

SoundEffect* rightToTheDeathSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"right_to_the_death" ofType:@"wav"]];
    
    return click;
}

SoundEffect* plattySound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"platty" ofType:@"wav"]];
    
    return click;
}

SoundEffect* madeForWrightySound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"made_for_wrighty" ofType:@"wav"]];
    
    return click;
}

SoundEffect* ifYouWereOneOfMyPlayersSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"if_you_were_one_of_my_players" ofType:@"wav"]];
    
    return click;
}

SoundEffect* iSweatALotSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"i_sweat_a_lot" ofType:@"wav"]];
    
    return click;
}

SoundEffect* hitLesSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hit_les" ofType:@"wav"]];
    
    return click;
}

SoundEffect* gottaGoBigSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gotta_go_big" ofType:@"wav"]];
    
    return click;
}

SoundEffect* disgracefulSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"disgraceful" ofType:@"wav"]];
    
    return click;
}

SoundEffect* carltonStartedItSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"carlton_started_it" ofType:@"wav"]];
    
    return click;
}

SoundEffect* canWeNotKnockItSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"can_we_not_knock_it" ofType:@"wav"]];
    
    return click;
}

SoundEffect* doINotLikeThatSound() {
    static SoundEffect *click = nil;
    if (click == nil)
        click = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ooh_do_i_not_like_that" ofType:@"wav"]];
    
    return click;
}

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

