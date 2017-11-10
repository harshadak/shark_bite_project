//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Grant Brooks on 9/9/17.
//  Copyright © 2017 Grant Brooks. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var background = SKSpriteNode(imageNamed: "lose")
    
    init(size: CGSize, won:Bool, score:SKLabelNode) {
        
        
        super.init(size: size)
        
        backgroundColor = SKColor.white
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        // ask Amy a better way to pass a node over and add it as a child
        var score2 = SKLabelNode()
        score2.text = score.text
        score2.fontName = score.fontName
        score2.position = score.position
        score2.fontColor = score.fontColor
        score2.fontSize = score.fontSize
        score2.horizontalAlignmentMode = score.horizontalAlignmentMode
        addChild(score2)
        
        
        if (won) {
            background.texture = SKTexture(imageNamed: "win")
            run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        }
        else {
            background.texture = SKTexture(imageNamed: "lose")
            run(SKAction.playSoundFileNamed("lose2.mp3", waitForCompletion: false))
        }
        
        // 2
        let message = won ? "You Won! 😍" : "You Lose 🤣"
        
        
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.red
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let teamlabel = SKLabelNode(fontNamed: "Chalkduster")
        teamlabel.text = "~Team HEDGER~"
        teamlabel.fontSize = 20
        teamlabel.fontColor = SKColor.red
        teamlabel.position = CGPoint(x: size.width/2, y: size.height/25)
        addChild(teamlabel)
        
        // 4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                // 5
                let reveal = SKTransition.flipHorizontal(withDuration: 1)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
        
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "bubbles.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
