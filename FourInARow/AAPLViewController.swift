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
    // -D USE_AI_PLAYER    //###See Build Settings>Swift Compiler - Custom Flags>Other Swift Flags
    
    private var board: AAPLBoard!
    private var strategist: GKMinmaxStrategist!
    @IBOutlet var columnButtons: [UIButton]!
    
    private var chipPath: UIBezierPath?
    private var chipLayers: [[CAShapeLayer]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.strategist = GKMinmaxStrategist()
        
        // 4 AI turns + 3 human turns in between = 7 turns for dominant AI (if heuristic good).
        self.strategist.maxLookAheadDepth = 7
        self.strategist.randomSource = GKARC4RandomSource()
        
        self.chipLayers = Array(repeating: [], count: AAPLBoard.width)
        
        self.resetBoard()
    }
    
    override func viewDidLayoutSubviews() {
        let button = self.columnButtons[0]
        let length = min(button.frame.size.width - 10, button.frame.size.height / 6 - 10)
        let rect = CGRect(x: 0, y: 0, width: length, height: length)
        self.chipPath = UIBezierPath(ovalIn: rect)
        
        for (column, columnLayers) in self.chipLayers.enumerated() {
            for (row, theChip) in columnLayers.enumerated() {
                theChip.path = self.chipPath!.cgPath
                theChip.frame = self.chipPath!.bounds
                theChip.position = self.positionForChipLayerAtColumn(column, row: row)
            }
        }
    }
    
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if self.board.canMoveInColumn(column) {
            self.board.addChip(self.board.currentPlayer.chip, inColumn: column)
            self.updateButton(sender)
            self.updateGame()
        }
    }
    
    private func updateButton(_ button: UIButton) {
        let column = button.tag
        button.isEnabled = self.board.canMoveInColumn(column)
        
        var row = AAPLBoard.height
        var chip = AAPLChip.none
        while chip == .none && row > 0 {
            row -= 1
            chip = self.board.chipInColumn(column, row: row)
        }
        
        if chip != AAPLChip.none {
            self.addChipLayerAtColumn(column, row: row, color: AAPLPlayer.playerForChip(chip)!.color!)
        }
    }
    
    private func positionForChipLayerAtColumn(_ column: Int, row: Int) -> CGPoint {
        let columnButton = self.columnButtons[column]
        let xOffset = columnButton.frame.midX
        let yStride = self.chipPath!.bounds.size.height + 10
        let yOffset = columnButton.frame.maxY - yStride / 2
        return CGPoint(x: xOffset, y: yOffset - yStride * CGFloat(row))
    }
    
    private func addChipLayerAtColumn(_ column: Int, row: Int, color: UIColor) {
        if (self.chipLayers[column].count < row + 1) {
            // Create and position a layer for the new chip.
            let newChip = CAShapeLayer()
            newChip.path = self.chipPath!.cgPath
            newChip.frame = self.chipPath!.bounds
            newChip.fillColor = color.cgColor
            newChip.position = self.positionForChipLayerAtColumn(column, row: row)
            
            // Animate the chip falling into place.
            self.view.layer.addSublayer(newChip)
            let animation = CABasicAnimation(keyPath: "position.y")
            animation.fromValue = -newChip.frame.size.height
            animation.toValue = newChip.position.y
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            newChip.add(animation, forKey: nil)
            self.chipLayers[column] = self.chipLayers[column] + [newChip]
        }
    }
    
    private func resetBoard() {
        self.board = AAPLBoard()
        for button in self.columnButtons {
            self.updateButton(button)
        }
        self.updateUI()
        
        self.strategist.gameModel = self.board
        
        for (columnIndex, column) in self.chipLayers.enumerated() {
            for chip in column {
                chip.removeFromSuperlayer()
            }
            self.chipLayers[columnIndex] = []
        }
    }
    
    private func updateGame() {
        var gameOverTitle: String? = nil
        if self.board.isWin(for: self.board.currentPlayer) {
            gameOverTitle = "\(self.board.currentPlayer.name!) Wins!"
        } else if self.board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if let title = gameOverTitle {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            let alertAction = UIAlertAction(title: "Play Again", style: UIAlertActionStyle.default) {_ in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        self.board.currentPlayer = self.board.currentPlayer.opponent!
        
        self.updateUI()
    }
    
    private func updateUI() {
        self.navigationItem.title = "\(self.board.currentPlayer.name!) Turn"
        self.navigationController!.navigationBar.backgroundColor = self.board.currentPlayer.color!
        
        #if USE_AI_PLAYER
            if self.board.currentPlayer.chip == AAPLChip.black {
                // Disable buttons & show spinner while AI player "thinks".
                for button in self.columnButtons {
                    button.isEnabled = false
                }
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                
                spinner.startAnimating()
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
                
                // Invoke GKMinmaxStrategist on background queue -- all that lookahead might take a while.
                DispatchQueue.global(qos: .default).async {
                    let strategistTime = CFAbsoluteTimeGetCurrent()
                    let column = self.columnForAIMove()
                    let delta = CFAbsoluteTimeGetCurrent() - strategistTime
                    
                    let  aiTimeCeiling: TimeInterval = 2.0
                    
                    /*
                    Make the player wait for the AI for a minimum time so that they
                    notice the AI moving even if it's fast.
                    */
                    let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay) {
                        self.makeAIMoveInColumn(column)
                    }
                
                }
            }
        #endif
    }
    
    private func columnForAIMove() -> Int {
        
        let aiMove = self.strategist.bestMove(for: self.board.currentPlayer) as! AAPLMove?
        
        assert(aiMove != nil, "AI should always be able to move (detect endgame before invoking AI)")
        
        let column = aiMove!.column
        
        return column
    }
    
    private func makeAIMoveInColumn(_ column: Int) {
        // Done "thinking", hide spinner.
        self.navigationItem.leftBarButtonItem = nil
        
        self.board.addChip(self.board.currentPlayer.chip, inColumn: column)
        for button in self.columnButtons {
            self.updateButton(button)
        }
        
        self.updateGame()
    }
    
}
