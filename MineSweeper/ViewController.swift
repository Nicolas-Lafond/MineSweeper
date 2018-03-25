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
    var redBackground = false
    
    override func draw(_ dirtyRect: NSRect) {
        if (redBackground) {
            NSGraphicsContext.saveGraphicsState()
            NSColor.red.setFill()
            let path = NSBezierPath(rect: dirtyRect)
            path.fill()
            let image = #imageLiteral(resourceName: "Bomb")
            image.draw(in: dirtyRect)
            NSGraphicsContext.restoreGraphicsState()
        }
        else {
            super.draw(dirtyRect)
        }
    }
    
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
            let viewController = self.target as! ViewController
            viewController.numberOfBombsLeftLabel?.intValue += 1
        }
        else {
            self.image = #imageLiteral(resourceName: "flag")
            self.imageScaling = .scaleAxesIndependently
            self.tile?.isFlagged = true
            let viewController = self.target as! ViewController
            viewController.numberOfBombsLeftLabel?.intValue -= 1
        }
        
    }
    
    var tile: MSTile?
}

class ViewController: NSViewController
{
    var modelGrid: MSGrid?
    var timer: Timer?
    var gridIsCreated = false
    @IBOutlet var gridView: NSGridView?
    @IBOutlet var newGameButton: NSButton?
    @IBOutlet var timerLabel: NSTextField?
    @IBOutlet var numberOfBombsLeftLabel: NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newGame()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func gameOver() {
        self.newGameButton?.image = #imageLiteral(resourceName: "Sad")
        gameIsOver = true
        self.timer?.invalidate()
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
                if let tile = button.tile {
                    if tile.isRevealed {
                        let title = (tile.numberOfAdjacentBomb > 0) ? String.init(format: "%d", (button.tile?.numberOfAdjacentBomb)!) : ""
                        let color = tile.getNumberColor()
                        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                        paragraphStyle.alignment = .center
                        let font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize(for: .regular))
                        let attrTitle = NSAttributedString.init(string: title, attributes: [.foregroundColor : color, .font : font, .paragraphStyle : paragraphStyle])
                        button.attributedTitle = attrTitle
                            button.bezelStyle = .smallSquare
                    }
                }
            }
        }
    }
    
    func createGrid() {
        if self.gridIsCreated { return; }
        let gridView: NSGridView? = self.gridView
        for i in 1...numberOfRows {
            var columnButtons: [MSButton] = []
            for j in 1...numberOfColumns {
                let button = MSButton()
                button.bezelStyle = .shadowlessSquare
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
        self.gridIsCreated = true
    }
    
    func newGame() {
        self.timerLabel?.integerValue = 0
        self.numberOfBombsLeftLabel?.integerValue = numberOfBombs
        gameIsOver = false
        self.newGameButton?.image = #imageLiteral(resourceName: "Smile")
        self.modelGrid = MSGrid(numberOfBombs: numberOfBombs, numberOfRows: numberOfRows, numberOfColumns: numberOfColumns)
        self.createGrid()
        bombsAreSet = false
        for i in 1...numberOfRows {
            for j in 1...numberOfColumns {
                let button = self.gridView?.cell(atColumnIndex: j - 1, rowIndex: i - 1).contentView as? MSButton
                button?.tile = self.modelGrid?.getTileAtPosition(positionX: i, positionY: j)
                button?.image = nil
                button?.title = ""
                button?.bezelStyle = .shadowlessSquare
                button?.redBackground = false
            }
        }
        self.timer?.invalidate()
    }
    
    @objc func updateTimer() {
        if let time = self.timerLabel?.integerValue {
            if time < 999 {
                self.timerLabel?.integerValue = time + 1
            }
        }
    }
    
    // MARK: Actions
    @IBAction func clicButton(_ sender: MSButton) {
        let tile = sender.tile
        if !(tile?.isFlagged)! {
            if !bombsAreSet { // First click on a tile of the game
                bombsAreSet = true
                self.modelGrid?.generateBombs(positionX: tile!.positionX, positionY: tile!.positionY)
                self.modelGrid?.generateNumbersOfAdjacentBombs()
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
            }
            if (tile?.isBomb)! {
                sender.image = #imageLiteral(resourceName: "Bomb")
                sender.redBackground = true
                sender.imagePosition = .imageOnly
                sender.imageScaling = .scaleAxesIndependently
                self.gameOver()
            }
            else if !(tile?.isRevealed)! {
                sender.title = (tile!.numberOfAdjacentBomb > 0) ? String.init(format: "%d", tile!.numberOfAdjacentBomb) : ""
                sender.bezelStyle = .smallSquare
                self.modelGrid?.revealTile(tile: tile)
                self.updateRevealed()
                if self.modelGrid!.gameIsOver() { // The player won the game
                    self.newGameButton?.image = #imageLiteral(resourceName: "Happy")
                    gameIsOver = true
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    @IBAction func clicNewGame(_ sender: NSButton) {
        self.newGame()
    }
}

