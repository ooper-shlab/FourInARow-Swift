//
//  AAPLBoard.swift
//  FourInARow
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/6/27.
//
//
/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information

	Abstract:
	Basic class representing the Four-In-A-Row game board.
 */

import Foundation

let AAPLBoardWidth = 7
let AAPLBoardHeight = 6
let AAPLCountToWin = 4

@objc(AAPLBoard)
class AAPLBoard: NSObject {
    
    var currentPlayer: AAPLPlayer
    
    var _cells: [AAPLChip] = Array(count: AAPLBoardWidth * AAPLBoardHeight, repeatedValue: .None)
    
    class func width() -> Int {
        return AAPLBoardWidth
    }
    
    class func height() -> Int {
        return AAPLBoardHeight
    }
    
    override init() {
        currentPlayer = AAPLPlayer.redPlayer()
        super.init()
        
    }
    
    func updateChipsFromBoard(otherBoard: AAPLBoard) {
        self._cells = otherBoard._cells
    }
    
    func chipInColumn(column: Int, row: Int) -> AAPLChip {
        assert(0 <= column && column < AAPLBoardWidth && 0 <= row && row < AAPLBoardHeight, "!")
        return _cells[row + column * AAPLBoardHeight]
    }
    
    private func setChip(chip: AAPLChip, inColumn column: Int, row: Int) {
        _cells[row + column * AAPLBoardHeight] = chip
    }
    
    override var debugDescription: String {
        var output = ""
        
        for row in (0..<AAPLBoardHeight).reverse() {
            for column in 0..<AAPLBoardWidth {
                let chip = self.chipInColumn(column, row: row)
                
                let playerDescription = AAPLPlayer.playerForChip(chip)?.debugDescription ?? " "
                output += playerDescription
                
                let cellDescription = (column + 1 < AAPLBoardWidth) ? "." : ""
                output += cellDescription
            }
            
            output += ((row > 0) ? "\n" : "")
        }
        
        return output
    }
    
    private func nextEmptySlotInColumn(column: Int) -> Int {
        for row in 0..<AAPLBoardHeight {
            if self.chipInColumn(column, row: row) == .None {
                return row
            }
        }
        
        return -1
    }
    
    func canMoveInColumn(column: Int) -> Bool {
        return self.nextEmptySlotInColumn(column) >= 0
    }
    
    func addChip(chip: AAPLChip, inColumn column: Int) {
        let row = self.nextEmptySlotInColumn(column)
        
        if row >= 0 {
            self.setChip(chip, inColumn: column, row: row)
        }
    }
    
    func isFull() -> Bool {
        for column in 0..<AAPLBoardWidth {
            if self.canMoveInColumn(column) {
                return false
            }
        }
        
        return true
    }
    
    func runCountsForPlayer(player: AAPLPlayer) -> [Int] {
        let  chip = player.chip
        var counts: [Int] = []
        
        // Detect horizontal runs.
        for row in 0..<AAPLBoardHeight {
            var runCount = 0
            for column in 0..<AAPLBoardWidth {
                if self.chipInColumn(column, row: row) == chip {
                    ++runCount
                } else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 1 { //###
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 1 { //###
                // Note the run if still on one at the end of the row.
                counts.append(runCount)
            }
        }
        
        // Detect vertical runs.
        for column in 0..<AAPLBoardWidth {
            var runCount = 0
            for row in 0..<AAPLBoardHeight {
                if self.chipInColumn(column, row: row) == chip {
                    ++runCount
                } else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 1 { //###
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 1 { //###
                // Note the run if still on one at the end of the column.
                counts.append(runCount)
            }
        }
        
        // Detect diagonal (northeast) runs
        for startColumn in -AAPLBoardHeight..<AAPLBoardWidth {
            // Start from off the edge of the board to catch all the diagonal lines through it.
            var runCount = 0
            for offset in 0..<AAPLBoardHeight {
                let column = startColumn + offset
                if column < 0 || column >= AAPLBoardWidth { //###
                    continue // Ignore areas that aren't on the board.
                }
                if self.chipInColumn(column, row: offset) == chip {
                    ++runCount
                } else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 1 { //###
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 1 {
                // Note the run if still on one at the end of the line.
                counts.append(runCount)
            }
        }
        
        // Detect diagonal (northwest) runs
        for startColumn in 0..<AAPLBoardWidth + AAPLBoardHeight {
            // Iterate through areas off the edge of the board to catch all the diagonal lines through it.
            var runCount = 0
            for offset in 0..<AAPLBoardHeight {
                let column = startColumn - offset
                if column < 0 || column >= AAPLBoardWidth { //###
                    continue // Ignore areas that aren't on the board.
                }
                if self.chipInColumn(column, row: offset) == chip {
                    ++runCount
                } else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 1 { //###
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 1 { //###
                // Note the run if still on one at the end of the line.
                counts.append(runCount)
            }
        }
        
        return counts
    }
    
}