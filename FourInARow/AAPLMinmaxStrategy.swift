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
    
    //MARK: - Managing players
    
    var players: [GKGameModelPlayer]? {
        return AAPLPlayer.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return self.currentPlayer
    }
    
    //MARK: - Copying board state
    
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
    
    //MARK: - Finding & applying moves
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        
        var moves: [AAPLMove] = []
        moves.reserveCapacity(AAPLBoard.width)
        for column in 0..<AAPLBoard.width {
            if self.canMoveInColumn(column) {
                moves.append(AAPLMove.moveInColumn(column))
            }
        }
        
        // Will be empty if isFull.
        return moves
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        let update = gameModelUpdate as! AAPLMove
        self.addChip(self.currentPlayer.chip, inColumn: update.column)
        self.currentPlayer = self.currentPlayer.opponent!
    }
    
    //MARK: - Evaluating board state
    
    func isWinForPlayer(player: GKGameModelPlayer) -> Bool {
        // Use AAPLBoard's utility method to find all N-in-a-row runs of the player's chip.
        let thePlayer = player as! AAPLPlayer
        let runCounts = self.runCountsForPlayer(thePlayer)
        
        // The player wins if there are any runs of 4 (or more, but that shouldn't happen in a regular game).
        let longestRun = runCounts.maxElement()
        return longestRun >= AAPLCountToWin
    }
    
    func isLossForPlayer(player: GKGameModelPlayer) -> Bool {
        // This is a two-player game, so a win for the opponent is a loss for the player.
        let thePlayer = player as! AAPLPlayer
        return self.isWinForPlayer(thePlayer.opponent!)
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        let thePlayer = player as! AAPLPlayer
        /*
        Heuristic: the chance of winning soon is related to the number and length
        of N-in-a-row runs of chips. For example, a player with two runs of two chips each
        is more likely to win soon than a player with no runs.
        
        Scoring should weigh the player's chance of success against that of failure,
        which in a two-player game means success for the opponent. Sum the player's number
        and size of runs, and subtract from it the same score for the opponent.
        
        This is not the best possible heuristic for Four-In-A-Row, but it produces
        moderately strong gameplay. Try these improvements:
        - Account for "broken runs"; e.g. a row of two chips, then a space, then a third chip.
        - Weight the run lengths; e.g. two runs of three is better than three runs of two.
        */
        
        // Use AAPLBoard's utility method to find all runs of the player's chip and sum their length.
        let playerRunCounts = self.runCountsForPlayer(thePlayer)
        if playerRunCounts.maxElement() >= AAPLCountToWin {return 9999} //###
        let playerTotal = playerRunCounts.map{$0 * $0}.reduce(0, combine: +) //###
        
        // Repeat for the opponent's chip.
        let opponentRunCounts = self.runCountsForPlayer(thePlayer.opponent!)
        if opponentRunCounts.maxElement() >= AAPLCountToWin {return -9999} //###
        let opponentTotal = opponentRunCounts.map{$0 * $0}.reduce(0, combine: +) //###
        
        // Return the sum of player runs minus the sum of opponent runs.
        return playerTotal - opponentTotal
    }
}
