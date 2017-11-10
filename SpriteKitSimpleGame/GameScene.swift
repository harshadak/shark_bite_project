//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Grant Brooks on 9/9/17.
//  Copyright © 2017 Grant Brooks. All rights reserved.
//

import SpriteKit
import CoreMotion


struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Diver   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b1010      // 10 (2)
    static let Player    : UInt32 = 0b10100          // 20 (3)
    static let TopBorder : UInt32 = 0b100       // 4
    static let BottomBorder : UInt32 = 0b101       // 5
    static let Fish : UInt32 = 0b110       // 6
    
}


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKSpriteNode(imageNamed: "underthesea")
    
    var motionManager: CMMotionManager?
    // 1
    let player = SKSpriteNode(imageNamed: "player")
//    var score = 0
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let topBorder = SKSpriteNode(imageNamed: "player")
    let bottomBorder = SKSpriteNode(imageNamed: "player")
    
    
    
    
    override func didMove(to view: SKView) {
        // 2
        backgroundColor = SKColor.white
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        motionManager = CMMotionManager()
        if let manager = motionManager {

            
            // 3
            player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
            // 4
            addChild(player)
            
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.affectedByGravity = true
            player.physicsBody?.categoryBitMask = PhysicsCategory.Player
            player.physicsBody?.collisionBitMask = PhysicsCategory.TopBorder
            player.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            player.physicsBody?.allowsRotation = false  // set to true to make shark crazy

            
            manager.startAccelerometerUpdates()
            manager.accelerometerUpdateInterval = 0.1
            let myq = OperationQueue()
            manager.startAccelerometerUpdates(to: myq) {
                (data, error) in
                print(data!.acceleration.x)
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -(CGFloat((data?.acceleration.x)!) * 10))
                
            }
            
        }
        else {
            print ("We can't detect motion")
        }
        
//        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run(addDiver),
                SKAction.wait(forDuration: 2.0)
                ])
        ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addFish),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = SKColor.red
        scoreLabel.fontSize = 28
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.maxX - 18, y: frame.maxY - 30)
        addChild(scoreLabel)
        
    
        topBorder.position = CGPoint(x: size.width * 0.1, y: size.height + 50)
        addChild(topBorder)
        topBorder.color = .red
        topBorder.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        topBorder.physicsBody?.affectedByGravity = false
        topBorder.physicsBody?.isDynamic = false
        topBorder.physicsBody?.categoryBitMask = PhysicsCategory.TopBorder
        topBorder.physicsBody?.collisionBitMask = PhysicsCategory.Player
        topBorder.physicsBody?.contactTestBitMask = PhysicsCategory.TopBorder
        
        bottomBorder.position = CGPoint(x: size.width * 0.1, y: -50)
        addChild(bottomBorder)
        bottomBorder.color = .red
        bottomBorder.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        bottomBorder.physicsBody?.affectedByGravity = false
        bottomBorder.physicsBody?.isDynamic = false
        bottomBorder.physicsBody?.categoryBitMask = PhysicsCategory.BottomBorder
        bottomBorder.physicsBody?.collisionBitMask = PhysicsCategory.Player
        bottomBorder.physicsBody?.contactTestBitMask = PhysicsCategory.BottomBorder
        
    }
    
    
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addDiver() {
        
        // Create sprite
        let diver = SKSpriteNode(imageNamed: "diver")
        
        // Determine where to spawn the diver along the Y axis
        let actualY = random(min: diver.size.height/2, max: size.height - diver.size.height/2)
        
        // Position the diver slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        diver.position = CGPoint(x: size.width + diver.size.width/2, y: actualY)
        
        // Add the diver to the scene
        addChild(diver)
        
        diver.physicsBody = SKPhysicsBody(rectangleOf: diver.size) // 1
        diver.physicsBody?.isDynamic = true // 2
        diver.physicsBody?.categoryBitMask = PhysicsCategory.Diver // 3
        diver.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Player
        diver.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine speed of the diver
        let actualDuration = random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -diver.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: self.scoreLabel)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        diver.run(SKAction.sequence([actionMove, loseAction]))
        
    }
    
    func addFish() {
        
        let fish = SKSpriteNode(imageNamed: "fish")
        let actualY = random(min: fish.size.height/2, max: size.height - fish.size.height/2)
        fish.position = CGPoint(x: size.width + fish.size.width/2, y: actualY)
        
        addChild(fish)
        
        fish.physicsBody = SKPhysicsBody(rectangleOf: fish.size)
        fish.physicsBody?.isDynamic = true
        fish.physicsBody?.categoryBitMask = PhysicsCategory.Fish
        fish.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        fish.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(10.0), max: CGFloat(15.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -fish.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: self.scoreLabel)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        fish.run(SKAction.sequence([actionMove, loseAction]))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position + CGPoint(x: player.size.width/2, y: 0)
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Diver
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        run(SKAction.playSoundFileNamed("shotfire.mp3", waitForCompletion: false))
        
    }
    
    func projectileDidCollideWithDiver(projectile: SKSpriteNode, diver: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        diver.removeFromParent()
        
        score += 2
        if (score > 9) {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
            let gameOverScene = GameOverScene(size: self.size, won: true, score: scoreLabel)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func projectileDidCollideWithFish(projectile: SKSpriteNode, fish: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        fish.removeFromParent()
        
        score -= 1
        if (score < -10) {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: scoreLabel)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func diverDidCollideWithPlayer(diver: SKSpriteNode, player: SKSpriteNode) {
        print("Hit player and diver")
        player.removeFromParent()
        
        score = 0
 
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
        let gameOverScene = GameOverScene(size: self.size, won: false, score: scoreLabel)
        self.view?.presentScene(gameOverScene, transition: reveal)

    }
    
    func fishDidCollideWithPlayer(fish: SKSpriteNode, player: SKSpriteNode) {
        print("Hit")
        run(SKAction.playSoundFileNamed("chomp.mp3", waitForCompletion: false))
        fish.removeFromParent()
        
        score += 1
        if (score > 9) {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 2)
            let gameOverScene = GameOverScene(size: self.size, won: true, score: scoreLabel)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        // 2
//        if ((firstBody.categoryBitMask & PhysicsCategory.Diver != 0) &&
//            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
//                if let diver = firstBody.node as? SKSpriteNode, let
//                    projectile = secondBody.node as? SKSpriteNode {
//                    projectileDidCollideWithDiver(projectile: projectile, diver: diver)
//                }
//        }
        if ((firstBody.categoryBitMask == PhysicsCategory.Diver) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile)) {
            if let diver = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithDiver(projectile: projectile, diver: diver)
            }
        }
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Fish) &&
            (secondBody.categoryBitMask == PhysicsCategory.Projectile)) {
            if let fish = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithFish(projectile: projectile, fish: fish)
            }
        }
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Diver) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player)) {
            if let diver = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                diverDidCollideWithPlayer(diver: diver, player: player)
            }
        }
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Fish) &&
            (secondBody.categoryBitMask == PhysicsCategory.Player)) {
            if let fish = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                fishDidCollideWithPlayer(fish: fish, player: player)
            }
        }
        
        
        
        
    }
    
}
