//
//  Model.swift
//  MineSweeper
//
//  Created by Nicolas Lafond on 18-03-11.
//  Copyright © 2018 Nicolas Lafond. All rights reserved.
//

import Cocoa

class MSTile : NSObject
{
    override init() {
        self.isBomb = false
        self.isRevealed = false
        self.numberOfAdjacentBomb = 0
    }
    
    var isBomb: Bool
    var isRevealed: Bool
    var numberOfAdjacentBomb: Int
}

class MSGrid : NSObject
{
    init(numberOfBombs: Int, numberOfRows: Int, numberOfColumns: Int) {
        self.numberOfBombs = numberOfBombs
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        self.tiles = [[MSTile]]()
        for _ in 1...numberOfRows {
            var row = [MSTile]()
            self.tiles.append(row)
            for _ in 1...numberOfColumns {
                row.append(MSTile())
            }
        }
    }
    
    func generateBombs(positionX: Int, positionY: Int) {
        var randX: Int, randY: Int
        var numberOfBombs = 0
        while numberOfBombs < self.numberOfBombs {
            randX = Int(arc4random_uniform(UInt32(self.numberOfColumns)))
            randY = Int(arc4random_uniform(UInt32(self.numberOfRows)))
            let isNotSamePosition = (randX != positionX || randY != positionY);
            if isNotSamePosition && !self.tiles[randX][randY].isBomb {
                self.tiles[randX][randY].isBomb = true
                numberOfBombs += 1
            }
        }
    }
    
    var tiles: [[MSTile]]
    let numberOfBombs: Int
    let numberOfRows: Int
    let numberOfColumns: Int
}
