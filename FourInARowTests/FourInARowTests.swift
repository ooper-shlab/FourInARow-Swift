//
//  FourInARowTests.swift
//  FourInARow
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/6/27.
//
//
/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information

    Abstract:
    This file contains tests for board logic.
*/

import UIKit
import XCTest

@testable import FourInARow

class FourInARowTests: XCTestCase {

    func testHorizontalWin1() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 0)
        board.addChip(.red, inColumn: 1)
        board.addChip(.black, inColumn: 1)
        board.addChip(.red, inColumn: 2)
        board.addChip(.black, inColumn: 2)
        board.addChip(.red, inColumn: 3)

        XCTAssert(board.debugDescription == " . . . . . . \n . . . . . . \n . . . . . . \n . . . . . . \nO.O.O. . . . \nX.X.X.X. . . ")

        XCTAssert(board.isWin(for: AAPLPlayer.redPlayer()))
    }
    func testHorizontalWin2() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 6)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 4)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 2)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 4)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 6)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \n . . . . . . \nX. . . . . . \nX. . .O.O.O.O\nX. .X.O.X.O.X")

        XCTAssert(board.isWin(for: AAPLPlayer.blackPlayer()))
    }

    func testVerticalWin1() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 0)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \nX. . . . . . \nX. . . . . . \nX. . .O. . . \nX. . .O. .O. ")

        XCTAssert(board.isWin(for: AAPLPlayer.redPlayer()))
    }

    func testVerticalWin2() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 6)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 4)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 2)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 3)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \n . . .O. . . \n . . .O. . . \nX. . .O. . . \nX. .X.O.X.O.X")

        XCTAssert(board.isWin(for: AAPLPlayer.blackPlayer()))
    }

    func diagonalWinBase() -> AAPLBoard {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 1)
        board.addChip(.red, inColumn: 2)
        board.addChip(.black, inColumn: 3)
        board.addChip(.red, inColumn: 1)
        board.addChip(.black, inColumn: 2)
        board.addChip(.red, inColumn: 3)
        board.addChip(.black, inColumn: 0)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 1)
        board.addChip(.red, inColumn: 2)
        board.addChip(.black, inColumn: 3)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \n . . . . . . \nX.O.X.O. . . \nO.X.O.X. . . \nX.O.X.O. . . ")

        return board
    }

    func testNortheastWin() {
        let board = diagonalWinBase()

        board.addChip(.red, inColumn: 3)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \n . . .X. . . \nX.O.X.O. . . \nO.X.O.X. . . \nX.O.X.O. . . ")

        XCTAssert(board.isWin(for: AAPLPlayer.redPlayer()))
    }

    func testSoutheastWin() {
        let board = diagonalWinBase()

        board.addChip(.red, inColumn: 4)

        board.addChip(.black, inColumn: 0)

        XCTAssert(board.debugDescription==" . . . . . . \n . . . . . . \nO. . . . . . \nX.O.X.O. . . \nO.X.O.X. . . \nX.O.X.O.X. . ")
        XCTAssert(board.isWin(for: AAPLPlayer.blackPlayer()))
    }

    func testFull() {
        let board = AAPLBoard()
        for column in 0..<AAPLBoard.width {
            for i in 0..<AAPLBoard.height {
                let chip = AAPLChip(rawValue: i % 2 + 1)!
                board.addChip(chip, inColumn: column)
            }
        }
        XCTAssert(board.isFull())
    }

    //###
    func testNortheastWinEastMost() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 3)
        board.addChip(.black, inColumn: 4)
        board.addChip(.red, inColumn: 4)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 1)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 5)
        board.addChip(.black, inColumn: 6)
        board.addChip(.red, inColumn: 1)
        board.addChip(.black, inColumn: 6)
        board.addChip(.red, inColumn: 0)
        board.addChip(.black, inColumn: 6)
        board.addChip(.red, inColumn: 6)
        
        XCTAssert(board.debugDescription == " . . . . . . \n . . . . . . \n . . . . . .X\n . . . . .X.O\n .X. . .X.O.O\nX.X. .X.O.O.O")

        XCTAssert(board.isWin(for: AAPLPlayer.redPlayer()))
    }
    
    //###
    func testSoutheastWinEastMost() {
        let board = AAPLBoard()
        board.addChip(.red, inColumn: 5)
        board.addChip(.black, inColumn: 6)
        board.addChip(.red, inColumn: 4)
        board.addChip(.black, inColumn: 5)
        board.addChip(.red, inColumn: 4)
        board.addChip(.black, inColumn: 4)
        board.addChip(.red, inColumn: 3)
        board.addChip(.black, inColumn: 2)
        board.addChip(.red, inColumn: 3)
        board.addChip(.black, inColumn: 1)
        board.addChip(.red, inColumn: 3)
        board.addChip(.black, inColumn: 3)
        
        XCTAssert(board.debugDescription == " . . . . . . \n . . . . . . \n . . .O. . . \n . . .X.O. . \n . . .X.X.O. \n .O.O.X.X.X.O")
        
        XCTAssert(board.isWin(for: AAPLPlayer.blackPlayer()))
    }

}
