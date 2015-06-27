/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Basic class representing the Four-In-A-Row game board.
 */

#import "AAPLBoard.h"

const static NSInteger AAPLBoardWidth = 7;
const static NSInteger AAPLBoardHeight = 6;
const static NSInteger AAPLCountToWin = 4;

@implementation AAPLBoard {
    AAPLChip _cells[AAPLBoardWidth * AAPLBoardHeight];
}

+ (NSInteger)width {
	return AAPLBoardWidth;
}

+ (NSInteger)height {
	return AAPLBoardHeight;
}

- (instancetype)init {
	self = [super init];

    if (self) {
		_currentPlayer = [AAPLPlayer redPlayer];
	}
	
    return self;
}

- (void)updateChipsFromBoard:(AAPLBoard *)otherBoard {
	memcpy(_cells, otherBoard->_cells, sizeof(_cells));
}

- (AAPLChip)chipInColumn:(NSInteger)column row:(NSInteger)row {
    return _cells[row + column * AAPLBoardHeight];
}

- (void)setChip:(AAPLChip)chip inColumn:(NSInteger)column row:(NSInteger)row {
    _cells[row + column * AAPLBoardHeight] = chip;
}

- (NSString *)debugDescription {
    NSMutableString *output = [NSMutableString string];

    for (NSInteger row = AAPLBoardHeight - 1; row >= 0; row--) {
        for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
            AAPLChip chip = [self chipInColumn:column row:row];
            
            NSString *playerDescription = [AAPLPlayer playerForChip:chip].debugDescription ?: @" ";
            [output appendString:playerDescription];
            
			NSString *cellDescription = (column + 1 < AAPLBoardWidth) ? @"." : @"";
            [output appendString:cellDescription];
        }
    
        [output appendString:((row > 0) ? @"\n" : @"")];
    }

    return output;
}

- (NSInteger)nextEmptySlotInColumn:(NSInteger)column {
    for (NSInteger row = 0; row < AAPLBoardHeight; row++) {
        if ([self chipInColumn:column row:row] == AAPLChipNone) {
            return row;
        }
    }
    
    return -1;
}

- (BOOL)canMoveInColumn:(NSInteger)column {
    return [self nextEmptySlotInColumn:column] >= 0;
}

- (void)addChip:(AAPLChip)chip inColumn:(NSInteger)column {
    NSInteger row = [self nextEmptySlotInColumn:column];

    if (row >= 0) {
        [self setChip:chip inColumn:column row:row];
    }
}

- (BOOL)isFull {
    for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
        if ([self canMoveInColumn:column]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)isWinForPlayer:(AAPLPlayer *)player {
	AAPLChip chip = player.chip;
	
    // Detect horizontal wins.
    for (NSInteger row = 0; row < AAPLBoardHeight; row++) {
        NSInteger runCount = 0;
        for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
            if ([self chipInColumn:column row:row] == chip) {
                if (++runCount == AAPLCountToWin) {
                    return YES;
                }
            }
            else if (column >= AAPLBoardWidth - AAPLCountToWin) {
                // No need to check for runs that start past this column.
                break;
            }
            else {
                // Run isn't continuing, reset counter.
                runCount = 0;
            }
        }
    }
    
    // Detect vertical wins.
    for (NSInteger column = 0; column < AAPLBoardWidth; column++) {
        NSInteger runCount = 0;
        for (NSInteger row = 0; row < AAPLBoardHeight; row++) {
            if ([self chipInColumn:column row:row] == chip) {
                if (++runCount == AAPLCountToWin) {
                    return YES;
                }
            }
            else if (row >= AAPLBoardHeight - AAPLCountToWin) {
                // No need to check for runs that start past this row.
                break;
            }
            else {
                // Run isn't continuing, reset counter.
                runCount = 0;
            }
        }
    }
    
    /*
        Detect diagonal (northeast) wins.
        Start by looking for a matching chip in column-major order.
    */
    for (NSInteger column = 0; column <= (AAPLBoardWidth - AAPLCountToWin); column++) {
        for (NSInteger row = 0; row <= (AAPLBoardHeight - AAPLCountToWin); row++) {
            if ([self chipInColumn:column row:row] == chip) {
                // Found a matching chip, switch to searching diagonal.
                NSInteger runCount = 1;

                for (NSInteger i = 1; i < AAPLCountToWin; i++) {
                    if ([self chipInColumn:(column + i) row:(row + i)] == chip) {
                        if (++runCount == AAPLCountToWin) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    /*
        Detect diagonal (southeast) wins. Start by looking for a matching chip in
        column-major order.
    */
    for (NSInteger column = 0; column <= (AAPLBoardWidth - AAPLCountToWin); column++) {
        for (NSInteger row = (AAPLBoardHeight - AAPLCountToWin) + 1; row > 0; row--) {
            if ([self chipInColumn:column row:row] == chip) {
                // Found a matching chip, switch to searching diagonal.
                NSInteger runCount = 1;
                for (NSInteger i = 1; i < AAPLCountToWin; i++) {
                    if ([self chipInColumn:(column + i) row:(row - i)] == chip) {
                        if (++runCount == AAPLCountToWin) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    // No win detected by this point => no win on board.
    return NO;
}

@end
