//
//  AAPLPlayer.swift
//  FourInARow
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/6/27.
//
//
/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information

	Abstract:
	Basic class representing a player in the Four-In-A-Row game.
 */

import UIKit

enum AAPLChip: Int {
    case None = 0
    case Red
    case Black
}

@objc(AAPLPlayer)
class AAPLPlayer: NSObject {
    
    let chip: AAPLChip
    
    init(chip: AAPLChip) {
        self.chip = chip
        super.init()
        
    }
    
    class func redPlayer() -> AAPLPlayer {
        return self.playerForChip(.Red)!
    }
    
    class func blackPlayer() -> AAPLPlayer {
        return self.playerForChip(.Black)!
    }
    
    class func playerForChip(chip: AAPLChip) -> AAPLPlayer? {
        if chip == .None {
            return nil
        }
        
        // Chip enum is 0/1/2, array is 0/1.
        return allPlayers[chip.rawValue - 1]
    }
    
    static var allPlayers: [AAPLPlayer] = [
        
        AAPLPlayer(chip: .Red),
        AAPLPlayer(chip: .Black),
        
    ]
    
    var color: UIColor? {
        switch self.chip {
        case .Red:
            return UIColor.redColor()
            
        case .Black:
            return UIColor.blackColor()
            
        default:
            return nil
        }
    }
    
    var name: String? {
        switch self.chip {
        case .Red:
            return "Red"
            
        case .Black:
            return "Black"
            
        default:
            return nil
        }
    }
    
    override var debugDescription: String {
        switch self.chip {
        case .Red:
            return "X"
            
        case .Black:
            return "O"
            
        default:
            return " "
        }
    }
    
    var opponent: AAPLPlayer? {
        switch self.chip {
        case .Red:
            return AAPLPlayer.blackPlayer()
            
        case .Black:
            return AAPLPlayer.redPlayer()
            
        default:
            return nil
        }
    }
    
}