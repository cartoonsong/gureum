//
//  CIMInputHandler.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"

#import "CIMInputHandler.h"
#import "CIMInputController.h"
#import "CIMComposer.h"

#define DEBUG_INPUTHANDLER TRUE

@implementation CIMInputHandler
@synthesize manager;

- (id)initWithManager:(CIMInputManager *)aManager {
    self = [super init];
    ICLog(DEBUG_INPUTHANDLER, @"** CIMInputHandler inited: %@ / with manage: %@", self, aManager);
    if (self) {
        self->manager = aManager;
    }
    return self;
}

- (void)setManager:(CIMInputManager *)aManager {
    self->manager = aManager;
}

#pragma - IMKServerInputTextData

enum {
    KeyCodeLeftArrow = 123,
    KeyCodeRightArrow = 124,
    KeyCodeDownArrow = 125,
    KeyCodeUpArrow = 126
};

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    // 입력기용 특수 커맨드 우선 처리
    CIMInputTextProcessResult result = [controller.composer inputController:controller commandString:string key:keyCode modifiers:flags client:sender];
    if (result == CIMInputTextProcessResultNotProcessedAndNeedsCommit) {
        return result;
    }
    if (result == CIMInputTextProcessResultProcessed) {
        goto finalize;
    }
    
    // 화살표 키가 입력으로 들어오면 강제 커밋
    if (KeyCodeLeftArrow <= keyCode && keyCode <= KeyCodeUpArrow) {
        ICLog(DEBUG_INPUTHANDLER, @"!! Commit composition on arrow keys");
        return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
    }
    
    // 특정 애플리케이션에서 커맨드/옵션 키 입력을 선점하지 못하는 문제를 회피한다
    if (flags & (NSCommandKeyMask|NSAlternateKeyMask)) {
        ICLog(TRUE, @"-- CIMInputHandler -inputText: Command/Option key input / returned NO");
        return CIMInputTextProcessResultNotProcessed;
    }
    
    result = [controller.composer inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
    
finalize:
    ICLog(FALSE, @"******* FINAL STATE: %d", result);
    // 합성 후보가 있다면 보여준다
    if (controller.composer.hasCandidates) {
        IMKCandidates *candidates = self.manager.candidates;
        [candidates updateCandidates];
        [candidates show:kIMKLocateCandidatesLeftHint];
    }
    return result;
}

@end