//
//  AAPLViewController.swift
//  FourInARow
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/6/27.
//
//
/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information

	Abstract:
	View controller runs the Four-In-A-Row game. Handles UI input for player turns and uses GKMinmaxStrategist for AI turns.
 */

import UIKit
import GameplayKit

@objc(AAPLViewController)
class AAPLViewController: UIViewController {
    
    // Switch this off to manually make moves for the black (O) player.
    // -DUSE_AI_PLAYER=1    //###See Build Settings>Swift Compiler - Custom Flags>Other Swift Flags
    
    private var board: AAPLBoard!
    private var strategist: GKMinmaxStrategist!
    @IBOutlet var columnButtons: [UIButton]!
    
    private var chipPath: UIBezierPath?
    private var chipLayers: [NSMutableArray] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.strategist = GKMinmaxStrategist()
        
        // 4 AI turns + 3 human turns in between = 7 turns for dominant AI (if heuristic good).
        self.strategist.maxLookAheadDepth = 7
        self.strategist.randomSource = GKARC4RandomSource()
        
        self.chipLayers.reserveCapacity(AAPLBoard.width())
        for _ in 0..<AAPLBoard.width() {
            self.chipLayers.append(NSMutableArray(capacity: AAPLBoard.height()))
        }
        
        self.resetBoard()
    }
    
    override func viewDidLayoutSubviews() {
        let button = self.columnButtons[0]
        let length = min(button.frame.size.width - 10, button.frame.size.height / 6 - 10)
        let rect = CGRectMake(0, 0, length, length)
        self.chipPath = UIBezierPath(ovalInRect: rect)
        
        for (column, columnLayers) in self.chipLayers.enumerate() {
            columnLayers.enumerateObjectsUsingBlock {chip, row, stop in
                let theChip = chip as! CAShapeLayer
                theChip.path = self.chipPath!.CGPath
                theChip.frame = self.chipPath!.bounds
                theChip.position = self.positionForChipLayerAtColumn(column, row: row)
            }
        }
    }
    
    @IBAction func makeMove(sender: UIButton) {
        let column = sender.tag
        
        if self.board.canMoveInColumn(column) {
            self.board.addChip(self.board.currentPlayer.chip, inColumn: column)
            self.updateButton(sender)
            self.updateGame()
        }
    }
    
    private func updateButton(button: UIButton) {
        let column = button.tag
        button.enabled = self.board.canMoveInColumn(column)
        
        var row = AAPLBoard.height()
        var chip = AAPLChip.None
        while chip == .None && row > 0 {
            chip = self.board.chipInColumn(column, row: --row)
        }
        
        if chip != AAPLChip.None {
            self.addChipLayerAtColumn(column, row: row, color: AAPLPlayer.playerForChip(chip)!.color!)
        }
    }
    
    private func positionForChipLayerAtColumn(column: Int, row: Int) -> CGPoint {
        let columnButton = self.columnButtons[column]
        let xOffset = CGRectGetMidX(columnButton.frame)
        let yStride = self.chipPath!.bounds.size.height + 10
        let yOffset = CGRectGetMaxY(columnButton.frame) - yStride / 2
        return CGPointMake(xOffset, yOffset - yStride * CGFloat(row))
    }
    
    private func addChipLayerAtColumn(column: Int, row: Int, color: UIColor) {
        if (self.chipLayers[column].count < row + 1) {
            // Create and position a layer for the new chip.
            let newChip = CAShapeLayer()
            newChip.path = self.chipPath!.CGPath
            newChip.frame = self.chipPath!.bounds
            newChip.fillColor = color.CGColor
            newChip.position = self.positionForChipLayerAtColumn(column, row: row)
            
            // Animate the chip falling into place.
            self.view.layer.addSublayer(newChip)
            let animation = CABasicAnimation(keyPath: "position.y")
            animation.fromValue = -newChip.frame.size.height
            animation.toValue = newChip.position.y
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            newChip.addAnimation(animation, forKey: nil)
            self.chipLayers[column][row] = newChip
        }
    }
    
    private func resetBoard() {
        self.board = AAPLBoard()
        for button in self.columnButtons {
            self.updateButton(button)
        }
        self.updateUI()
        
        self.strategist.gameModel = self.board
        
        for column in self.chipLayers {
            for chip in column as NSArray as! [CAShapeLayer] {
                chip.removeFromSuperlayer()
            }
            column.removeAllObjects()
        }
    }
    
    private func updateGame() {
        var gameOverTitle: String? = nil
        if self.board.isWinForPlayer(self.board.currentPlayer) {
            gameOverTitle = "\(self.board.currentPlayer.name!) Wins!"
        } else if self.board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if let title = gameOverTitle {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertAction = UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default) {_ in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        self.board.currentPlayer = self.board.currentPlayer.opponent!
        
        self.updateUI()
    }
    
    private func updateUI() {
        self.navigationItem.title = "\(self.board.currentPlayer.name!) Turn"
        self.navigationController!.navigationBar.backgroundColor = self.board.currentPlayer.color!
        
        #if USE_AI_PLAYER
            if self.board.currentPlayer.chip == AAPLChip.Black {
                // Disable buttons & show spinner while AI player "thinks".
                for button in self.columnButtons {
                    button.enabled = false
                }
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                
                spinner.startAnimating()
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
                
                // Invoke GKMinmaxStrategist on background queue -- all that lookahead might take a while.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let strategistTime = CFAbsoluteTimeGetCurrent()
                    let column = self.columnForAIMove()
                    let delta = CFAbsoluteTimeGetCurrent() - strategistTime
                    
                    let  aiTimeCeiling: NSTimeInterval = 2.0
                    
                    /*
                    Make the player wait for the AI for a minimum time so that they
                    notice the AI moving even if it's fast.
                    */
                    let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                        self.makeAIMoveInColumn(column)
                    }
                
                }
            }
        #endif
    }
    
    private func columnForAIMove() -> Int {
        
        let aiMove = self.strategist.bestMoveForPlayer(self.board.currentPlayer) as! AAPLMove?
        
        assert(aiMove != nil, "AI should always be able to move (detect endgame before invoking AI)")
        
        let column = aiMove!.column
        
        return column
    }
    
    private func makeAIMoveInColumn(column: Int) {
        // Done "thinking", hide spinner.
        self.navigationItem.leftBarButtonItem = nil
        
        self.board.addChip(self.board.currentPlayer.chip, inColumn: column)
        for button in self.columnButtons {
            self.updateButton(button)
        }
        
        self.updateGame()
    }
    
}