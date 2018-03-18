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
let numberOfBombs = 30
var bombsAreSet = false

class MSButton: NSButton
{
    override func mouseDown(with event: NSEvent) {
        if !(self.tile?.isFlagged)! {
            super.mouseDown(with: event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        if (self.tile?.isRevealed)! {
            return
        }
        else if (self.tile?.isFlagged)! {
            self.image = nil
            self.tile?.isFlagged = false
        }
        else {
            self.image = NSImage.init(named: NSImage.Name(rawValue: "flag"))
            self.tile?.isFlagged = true
        }
        
    }
    
    var tile: MSTile?
}

class ViewController: NSViewController
{
    var modelGrid: MSGrid?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Create the model
        self.modelGrid = MSGrid(numberOfBombs: numberOfBombs, numberOfRows: numberOfRows, numberOfColumns: numberOfColumns)
        
        // Create the buttons grid
        let gridView: NSGridView = self.view as! NSGridView
        for i in 1...numberOfRows {
            var columnButtons: [MSButton] = []
            for j in 1...numberOfColumns {
                let button = MSButton()
                button.title = ""
                button.target = self
                button.action = #selector(ViewController.clicButton(_:))
                button.addConstraint(NSLayoutConstraint.init(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
                button.addConstraint(NSLayoutConstraint.init(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
                button.tile = self.modelGrid?.getTileAtPosition(positionX: i, positionY: j)
                columnButtons.append(button)
            }
            gridView.addRow(with: columnButtons)
        }
        gridView.rowSpacing = 0.0
        gridView.columnSpacing = 0.0
        gridView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        gridView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func clicButton(_ sender: MSButton) {
        let tile = sender.tile
        if !(tile?.isFlagged)! {
            if !bombsAreSet {
                bombsAreSet = true
                self.modelGrid?.generateBombs(positionX: tile!.positionX, positionY: tile!.positionY)
                self.modelGrid?.generateNumbersOfAdjacentBombs()
            }
            if (tile?.isBomb)! {
                sender.title = "B"
            }
            else {
                sender.title = String.init(format: "%d", tile!.numberOfAdjacentBomb)
                sender.tile?.isRevealed = true
            }
        }
    }
}

