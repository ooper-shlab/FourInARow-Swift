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
    
    func isWinForPlayer(player: AAPLPlayer) -> Bool {
        let  chip = player.chip
        
        // Detect horizontal wins.
        for row in 0..<AAPLBoardHeight {
            var runCount = 0
            for column in 0..<AAPLBoardWidth {
                if self.chipInColumn(column, row: row) == chip {
                    if ++runCount == AAPLCountToWin {
                        return true
                    }
                } else if column >= AAPLBoardWidth - AAPLCountToWin {
                    // No need to check for runs that start past this column.
                    break
                } else {
                    // Run isn't continuing, reset counter.
                    runCount = 0
                }
            }
        }
        
        // Detect vertical wins.
        for column in 0..<AAPLBoardWidth {
            var runCount = 0
            for row in 0..<AAPLBoardHeight {
                if self.chipInColumn(column, row: row) == chip {
                    if ++runCount == AAPLCountToWin {
                        return true
                    }
                } else if row >= AAPLBoardHeight - AAPLCountToWin {
                    // No need to check for runs that start past this row.
                    break
                } else {
                    // Run isn't continuing, reset counter.
                    runCount = 0
                }
            }
        }
        
        /*
        Detect diagonal (northeast) wins.
        Start by looking for a matching chip in column-major order.
        */
        //for column in 0..<(AAPLBoardWidth - AAPLCountToWin) { //### bug?
        for column in 0...(AAPLBoardWidth - AAPLCountToWin) {
            //for row in 0..<(AAPLBoardHeight - AAPLCountToWin) { //### bug?
            for row in 0...(AAPLBoardHeight - AAPLCountToWin) {
                if self.chipInColumn(column, row: row) == chip {
                    // Found a matching chip, switch to searching diagonal.
                    var runCount = 1
                    
                    for i in 1..<AAPLCountToWin {
                        if self.chipInColumn((column + i), row: (row + i)) == chip {
                            if ++runCount == AAPLCountToWin {
                                return true
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
        //for column in 0..<(AAPLBoardWidth - AAPLCountToWin) {   //### bug?
        for column in 0...(AAPLBoardWidth - AAPLCountToWin) {
            //for row in (1 ... (AAPLBoardHeight - AAPLCountToWin) + 1).reverse() {   //### bug?
            for row in (AAPLCountToWin-1 ..< AAPLBoardHeight).reverse() {
                if self.chipInColumn(column, row: row) == chip {
                    // Found a matching chip, switch to searching diagonal.
                    var runCount = 1
                    for i in 1..<AAPLCountToWin {
                        if self.chipInColumn((column + i), row: (row - i)) == chip {
                            if ++runCount == AAPLCountToWin {
                                return true
                            }
                        }
                    }
                }
            }
        }
        
        // No win detected by this point => no win on board.
        return false
    }
    
}