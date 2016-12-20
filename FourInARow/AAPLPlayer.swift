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
    case none = 0
    case red
    case black
}

@objc(AAPLPlayer)
class AAPLPlayer: NSObject {
    
    let chip: AAPLChip
    
    init(chip: AAPLChip) {
        self.chip = chip
        super.init()
        
    }
    
    class func redPlayer() -> AAPLPlayer {
        return self.playerForChip(.red)!
    }
    
    class func blackPlayer() -> AAPLPlayer {
        return self.playerForChip(.black)!
    }
    
    class func playerForChip(_ chip: AAPLChip) -> AAPLPlayer? {
        if chip == .none {
            return nil
        }
        
        // Chip enum is 0/1/2, array is 0/1.
        return allPlayers[chip.rawValue - 1]
    }
    
    static var allPlayers: [AAPLPlayer] = [
        
        AAPLPlayer(chip: .red),
        AAPLPlayer(chip: .black),
        
    ]
    
    var color: UIColor? {
        switch self.chip {
        case .red:
            return UIColor.red
            
        case .black:
            return UIColor.black
            
        default:
            return nil
        }
    }
    
    var name: String? {
        switch self.chip {
        case .red:
            return "Red"
            
        case .black:
            return "Black"
            
        default:
            return nil
        }
    }
    
    override var debugDescription: String {
        switch self.chip {
        case .red:
            return "X"
            
        case .black:
            return "O"
            
        default:
            return " "
        }
    }
    
    var opponent: AAPLPlayer? {
        switch self.chip {
        case .red:
            return AAPLPlayer.blackPlayer()
            
        case .black:
            return AAPLPlayer.redPlayer()
            
        default:
            return nil
        }
    }
    
}
