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
        // There should be no bomb at the position given as argument to this function
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
    
    func getTileAtPosition(positionX: Int, positionY: Int) -> MSTile {
        // Note Tile at position (1,1) is the top left tile of the grid
        return self.tiles[positionX - 1][positionY - 1]
    }
    
    func getAdjacentTiles(positionX: Int, positionY: Int) -> [MSTile] {
        var adjacentX: [Int] = [positionX]
        if positionX > 0 { adjacentX.append(positionX - 1) }
        if positionX < numberOfColumns - 1 { adjacentX.append(positionX + 1) }
        var adjacentY: [Int] = [positionY]
        if positionY > 0 { adjacentY.append(positionY - 1) }
        if positionY < numberOfRows - 1 { adjacentY.append(positionY + 1) }
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
        for i in 0...numberOfRows-1 {
            for j in 0...numberOfColumns-1 {
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
    
    var tiles: [[MSTile]]
    let numberOfBombs: Int
    let numberOfRows: Int
    let numberOfColumns: Int
}