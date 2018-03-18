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
    init(positionX: Int, positionY: Int) {
        self.isBomb = false
        self.isRevealed = false
        self.numberOfAdjacentBomb = 0
        self.positionX = positionX
        self.positionY = positionY
    }
    
    func getNumberColor() -> NSColor {
        switch self.numberOfAdjacentBomb
        {
        case 1:
            return NSColor.blue
        case 2:
            return NSColor.green
        case 3:
            return NSColor.red
        case 4:
            return NSColor.purple
        case 5:
            return NSColor.brown
        case 6:
            return NSColor.magenta
        case 7:
            return NSColor.black
        case 8:
            return NSColor.gray
        default:
            return NSColor.black
        }
    }
    
    var isBomb: Bool
    var isRevealed: Bool
    var isFlagged = false
    var numberOfAdjacentBomb: Int
    var positionX: Int
    var positionY: Int
}

class MSGrid : NSObject
{
    init(numberOfBombs: Int, numberOfRows: Int, numberOfColumns: Int) {
        self.numberOfBombs = numberOfBombs
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        self.tiles = [[MSTile]]()
        for i in 1...numberOfRows {
            var row = [MSTile]()
            for j in 1...numberOfColumns {
                row.append(MSTile(positionX: i, positionY: j))
            }
            self.tiles.append(row)
        }
    }
    
    func generateBombs(positionX: Int, positionY: Int) {
        // There should be no bomb at the position given as argument to this function
        var randX: Int, randY: Int
        var numberOfBombs = 0
        while numberOfBombs < self.numberOfBombs {
            randX = Int(arc4random_uniform(UInt32(self.numberOfColumns))) + 1
            randY = Int(arc4random_uniform(UInt32(self.numberOfRows))) + 1
            let randTile = self.getTileAtPosition(positionX: randX, positionY: randY)
            let isNotSamePosition = (randX != positionX || randY != positionY);
            if isNotSamePosition && !randTile.isBomb {
                randTile.isBomb = true
                numberOfBombs += 1
            }
        }
    }
    
    func getTileAtPosition(positionX: Int, positionY: Int) -> MSTile {
        // Note Tile at position (1,1) is the top left tile of the grid
        return self.tiles[positionX - 1][positionY - 1]
    }
    
    func getAdjacentTiles(positionX: Int, positionY: Int) -> [MSTile] {
        var adjacentX: [Int] = [positionX]
        if positionX > 1 { adjacentX.append(positionX - 1) }
        if positionX < numberOfColumns { adjacentX.append(positionX + 1) }
        var adjacentY: [Int] = [positionY]
        if positionY > 1 { adjacentY.append(positionY - 1) }
        if positionY < numberOfRows { adjacentY.append(positionY + 1) }
        var adjacentPositions: [(Int, Int)] = []
        for i in adjacentX {
            for j in adjacentY {
                if i != positionX || j != positionY {
                    adjacentPositions.append((i, j))
                }
            }
        }
        
        var adjacentTiles: [MSTile] = []
        for (posX, posY) in adjacentPositions {
            adjacentTiles.append(self.getTileAtPosition(positionX: posX, positionY: posY))
        }
        return adjacentTiles
    }
    
    func generateNumbersOfAdjacentBombs() {
        for i in 1...numberOfRows {
            for j in 1...numberOfColumns {
                let tile = self.getTileAtPosition(positionX: i, positionY: j)
                if tile.isBomb {
                    tile.numberOfAdjacentBomb = 0 // We don't care how many bombs are adjacent to a bomb tile
                }
                else {
                    var numberOfAdjacentBombs = 0
                    let adjacentTilesList = getAdjacentTiles(positionX: i, positionY: j)
                    for tile in adjacentTilesList {
                        if tile.isBomb {
                            numberOfAdjacentBombs += 1
                        }
                    }
                    tile.numberOfAdjacentBomb = numberOfAdjacentBombs
                }
            }
        }
    }
    
    func getNumberOfRemainingTilesToReveal() -> Int {
        let numberOfTiles = self.numberOfRows * self.numberOfColumns
        var numberOfRevealedTiles = 0
        for row in self.tiles {
            for tile in row {
                if tile.isRevealed && !tile.isBomb { numberOfRevealedTiles += 1 }
            }
        }
        return numberOfTiles - numberOfRevealedTiles - self.numberOfBombs
    }
    
    func revealTile(tile: MSTile?) {
        tile?.isRevealed = true
        if tile != nil && tile?.numberOfAdjacentBomb == 0 {
            let adjacentTiles = self.getAdjacentTiles(positionX: (tile?.positionX)!, positionY: (tile?.positionY)!)
            for adjacentTile in adjacentTiles {
                if (!adjacentTile.isRevealed) {
                    self.revealTile(tile: adjacentTile)
                }
            }
        }
    }
    
    var tiles: [[MSTile]]
    let numberOfBombs: Int
    let numberOfRows: Int
    let numberOfColumns: Int
}
