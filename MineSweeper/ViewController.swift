//
//  ViewController.swift
//  MineSweeper
//
//  Created by Nicolas Lafond on 18-03-11.
//  Copyright © 2018 Nicolas Lafond. All rights reserved.
//

import Cocoa

let numberOfRows = 20
let numberOfColumns = 20
let numberOfBombs = 50
var bombsAreSet = false
var gameIsOver = true

class MSButton: NSButton
{
    override func mouseDown(with event: NSEvent) {
        if !gameIsOver && !(self.tile?.isFlagged)! && !(self.tile?.isRevealed)! {
            super.mouseDown(with: event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if gameIsOver || (self.tile?.isRevealed)! {
            return
        }
        else if (self.tile?.isFlagged)! {
            self.image = nil
            self.tile?.isFlagged = false
        }
        else {
            self.image = #imageLiteral(resourceName: "flag")
            self.tile?.isFlagged = true
        }
        
    }
    
    var tile: MSTile?
}

class ViewController: NSViewController
{
    var modelGrid: MSGrid?
    @IBOutlet var gridView: NSGridView?
    @IBOutlet var newGameButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Create the model
        self.modelGrid = MSGrid(numberOfBombs: numberOfBombs, numberOfRows: numberOfRows, numberOfColumns: numberOfColumns)
        
        // Create the buttons grid
        let gridView: NSGridView? = self.gridView
        for i in 1...numberOfRows {
            var columnButtons: [MSButton] = []
            for j in 1...numberOfColumns {
                let button = MSButton()
                button.title = ""
                button.target = self
                button.action = #selector(ViewController.clicButton(_:))
                button.addConstraint(NSLayoutConstraint.init(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
                button.addConstraint(NSLayoutConstraint.init(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
                let tile = self.modelGrid?.getTileAtPosition(positionX: i, positionY: j)
                button.tile = tile
                columnButtons.append(button)
            }
            gridView?.addRow(with: columnButtons)
        }
        gridView?.rowSpacing = 0.0
        gridView?.columnSpacing = 0.0
        gridView?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        gridView?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        gameIsOver = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func gameOver() {
        self.newGameButton?.image = #imageLiteral(resourceName: "Sad")
        gameIsOver = true
        for i in 0...numberOfRows - 1 {
            for j in 0...numberOfColumns -  1 {
                let gridView: NSGridView = (self.gridView)!
                let button = gridView.cell(atColumnIndex: j, rowIndex: i).contentView as! MSButton
                if (button.tile?.isBomb)! && !(button.tile?.isFlagged)! {
                    button.image = #imageLiteral(resourceName: "Bomb")
                    button.imageScaling = .scaleAxesIndependently
                }
            }
        }
    }
    
    func updateRevealed() {
        // This function should probably be replaced by some kind of observing mecanism on the isRevealed property of tile.
        // But for a first iteration it should be fine.
        for i in 0...numberOfRows - 1 {
            for j in 0...numberOfColumns -  1 {
                let gridView: NSGridView = (self.gridView)!
                let button = gridView.cell(atColumnIndex: j, rowIndex: i).contentView as! MSButton
                if (button.tile?.isRevealed)! {
                    button.title = String.init(format: "%d", (button.tile?.numberOfAdjacentBomb)!)
                }
            }
        }
    }
    
    func newGame() {
        gameIsOver = false
        self.newGameButton?.image = #imageLiteral(resourceName: "Smile")
        self.modelGrid = MSGrid(numberOfBombs: numberOfBombs, numberOfRows: numberOfRows, numberOfColumns: numberOfColumns)
        bombsAreSet = false
        for i in 1...numberOfRows {
            for j in 1...numberOfColumns {
                let button = self.gridView?.cell(atColumnIndex: j - 1, rowIndex: i - 1).contentView as? MSButton
                button?.tile = self.modelGrid?.getTileAtPosition(positionX: i, positionY: j)
                button?.image = nil
                button?.title = ""
            }
        }
    }
    
    // MARK: Actions
    @IBAction func clicButton(_ sender: MSButton) {
        let tile = sender.tile
        if !(tile?.isFlagged)! {
            if !bombsAreSet {
                bombsAreSet = true
                self.modelGrid?.generateBombs(positionX: tile!.positionX, positionY: tile!.positionY)
                self.modelGrid?.generateNumbersOfAdjacentBombs()
            }
            if (tile?.isBomb)! {
                sender.image = #imageLiteral(resourceName: "Bomb")
                sender.imagePosition = .imageOnly
                sender.imageScaling = .scaleAxesIndependently
                self.gameOver()
            }
            else if !(tile?.isRevealed)! {
                sender.title = String.init(format: "%d", tile!.numberOfAdjacentBomb)
                self.modelGrid?.revealTile(tile: tile)
                self.updateRevealed()
            }
        }
    }
    
    @IBAction func clicNewGame(_ sender: NSButton) {
        self.newGame()
    }
}

