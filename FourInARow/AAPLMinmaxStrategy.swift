//
//  AAPLMinmaxStrategy.swift
//  FourInARow
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/6/27.
//
//
/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information

	Abstract:
	Additions to the game model classes adding GameplayKit protocols for use with the minmax strategist.
 */

import UIKit
import GameplayKit

@objc(AAPLMove)
class AAPLMove: NSObject, GKGameModelUpdate {
    
    // Required by GKGameModelUpdate for storing move ratings during GKMinmaxStrategist move selection.
    var value: Int = 0
    
    // Identifies the column in which to make a move.
    var column: Int
    
    init(column: Int) {
        self.column = column
        super.init()
        
    }
    
    class func moveInColumn(column: Int) -> AAPLMove {
        return AAPLMove(column: column)
    }
    
}

extension AAPLPlayer: GKGameModelPlayer {
    
    var playerId: Int {
        return self.chip.rawValue
    }
}

extension AAPLBoard: GKGameModel {
    
    var players: [GKGameModelPlayer]? {
        return AAPLPlayer.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return self.currentPlayer
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = AAPLBoard()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(gameModel: GKGameModel) {
        let model = gameModel as! AAPLBoard
        self.updateChipsFromBoard(model)
        self.currentPlayer = model.currentPlayer
    }
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let thePlayer = player as! AAPLPlayer
        if self.isWinForPlayer(thePlayer) || self.isWinForPlayer(thePlayer.opponent!) {
            return nil
        }
        
        var moves: [AAPLMove] = []
        moves.reserveCapacity(AAPLBoard.width())
        for column in 0..<AAPLBoard.width() {
            if self.canMoveInColumn(column) {
                moves.append(AAPLMove.moveInColumn(column))
            }
        }
        
        // Will be empty if isFull.
        return moves
        //    return nil;
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        let update = gameModelUpdate as! AAPLMove
        self.addChip(self.currentPlayer.chip, inColumn: update.column)
        self.currentPlayer = self.currentPlayer.opponent!
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        let thePlayer = player as! AAPLPlayer
        /*
        This heuristic isn't very smart -- it sees an imminent win/loss and
        a future win/loss as equivalent. Try weighting the score based on
        how many moves have been made, or devising your own metric for how
        close a player is to winning.
        */
        if self.isWinForPlayer(thePlayer) {
            return 100
        } else if self.isWinForPlayer(thePlayer.opponent!) {
            return -100
        } else {
            /*
            A smarter heuristic would do more with this case:
            The game isn't won yet, but how close is a win?
            */
            return 0
        }
    }
}
