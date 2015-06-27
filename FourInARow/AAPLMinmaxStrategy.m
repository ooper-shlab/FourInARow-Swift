/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Additions to the game model classes adding GameplayKit protocols for use with the minmax strategist.
 */

#import "AAPLMinmaxStrategy.h"

@implementation AAPLMove

- (instancetype)initWithColumn:(NSInteger)column {
    self = [super init];
    
    if (self) {
        _column = column;
    }
    
    return self;
}

+ (AAPLMove *)moveInColumn:(NSInteger)column {
    return [[self alloc] initWithColumn:column];
}

@end

@implementation AAPLPlayer (MinmaxStrategy)

- (NSInteger)playerId {
    return self.chip;
}

@end

@implementation AAPLBoard (MinmaxStrategy)

- (NSArray<AAPLPlayer *> *)players {
    return [AAPLPlayer allPlayers];
}

- (AAPLPlayer *)activePlayer {
    return self.currentPlayer;
}

- (__nonnull id)copyWithZone:(nullable NSZone *)zone {
    AAPLBoard *copy = [[[self class] allocWithZone:zone] init];
    [copy setGameModel:self];
    return copy;
}

- (void)setGameModel:(AAPLBoard *)gameModel {
	[self updateChipsFromBoard:gameModel];
    self.currentPlayer = gameModel.currentPlayer;
}

- (NSArray<AAPLMove *> *)gameModelUpdatesForPlayer:(AAPLPlayer *)player {
    if ([self isWinForPlayer:player] || [self isWinForPlayer:player.opponent]) {
        return nil;
    }
    
    NSMutableArray<AAPLMove *> *moves = [NSMutableArray arrayWithCapacity:AAPLBoard.width];
    for (NSInteger column = 0; column < AAPLBoard.width; column++) {
        if ([self canMoveInColumn:column]) {
            [moves addObject:[AAPLMove moveInColumn:column]];
        }
    }

    // Will be empty if isFull.
    return moves;
    return nil;
}

- (void)applyGameModelUpdate:(AAPLMove *)gameModelUpdate {
    [self addChip:self.currentPlayer.chip inColumn:gameModelUpdate.column];
    self.currentPlayer = self.currentPlayer.opponent;
}

- (NSInteger)scoreForPlayer:(AAPLPlayer *)player {
    /*
        This heuristic isn't very smart -- it sees an imminent win/loss and
        a future win/loss as equivalent. Try weighting the score based on 
        how many moves have been made, or devising your own metric for how
        close a player is to winning.
    */
    if ([self isWinForPlayer:player]) {
        return 100;
    }
    else if ([self isWinForPlayer:player.opponent]) {
        return -100;
    }
    else {
        /*
            A smarter heuristic would do more with this case:
            The game isn't won yet, but how close is a win?
        */
        return 0;
    }
}

@end