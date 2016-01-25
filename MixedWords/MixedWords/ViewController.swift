//
//  ViewController.swift
//  MixedWords
//
//  Created by jhampac on 1/21/16.
//  Copyright © 2016 jhampac. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController
{
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UILabel!
    
    var letterButtons = [UIButton]()
    var activeButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0
    var level = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // FIXME: - Better solution to loop through UISTACKVIEWS
        for subview in view.subviews where subview.tag == 1001
        {
            for subStacks in subview.subviews
            {
                if let buttonStacks = subStacks as? UIStackView
                {
                    for button in buttonStacks.subviews
                    {
                        if let btn = button as? UIButton
                        {
                            btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
                            letterButtons.append(btn)
                        }
                    }
                }
            }
        }
        
        loadLevel()
    }
    
    @IBAction func submitTapped(sender: UIButton)
    {
        if let solutionPosition = solutions.indexOf(currentAnswer.text!)
        {
            activeButtons.removeAll()
            
            var splitClues = answersLabel.text!.componentsSeparatedByString("\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joinWithSeparator("\n")
            
            currentAnswer.text = ""
            ++score
            
            if score % 7 == 0
            {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: levelUp))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clearTapped(sender: UIButton)
    {
        currentAnswer.text = ""
        
        for btn in activeButtons
        {
            btn.hidden = false
        }
        
        activeButtons.removeAll()
    }
    
    func letterTapped(button: UIButton)
    {
        currentAnswer.text = currentAnswer.text! + button.titleLabel!.text!
        activeButtons.append(button)
        button.hidden = true
    }
    
    func levelUp(action: UIAlertAction!)
    {
        ++level
        solutions.removeAll(keepCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons
        {
            btn.hidden = false
        }
    }
    
    func loadLevel()
    {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        // find file in the bundle
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt")
        {
            // get the contents of the file and create one long string
            if let levelContents = try? String(contentsOfFile: levelFilePath, usedEncoding: nil)
            {
                // break the string up into an array at the breaks and randomize
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                // loop through with index and value
                for (index, line) in lines.enumerate()
                {
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    // append at the end of letterBits
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        // configure buttons
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count
        {
            // remember we randomized these arrays using GKRandomSource
            for i in 0..<letterBits.count
            {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
}

