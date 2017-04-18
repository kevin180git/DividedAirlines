//
//  GameScene.swift
//  DividedAirlines
//
//  Created by Kevin Lee on 4/15/17.
//  Copyright © 2017 Kevin Lee. All rights reserved.
//
//not sure how to change states
//countdown timer is jenky
//problem with randomly generate face and not equal to last face
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var wastedLabel: SKLabelNode?
    
    var scoreLabel: SKLabelNode?
    var scoreboard: SKSpriteNode?
    var score:Int = 0
    var computerTime: SKLabelNode?
    var computerImage: SKSpriteNode?
    
    var playerState:Int = 1
    var compState:Int = 1
    var gameOver:Bool = false
    
    //for destroying officer nodes
    var topOuterRec: SKSpriteNode?
    var bottomOuterRec: SKSpriteNode?
    var leftOuterRec: SKSpriteNode?
    var rightOuterRec: SKSpriteNode?
    
    var player: SKSpriteNode?
    var topRec: SKSpriteNode?
    var bottomRec: SKSpriteNode?
    var leftRec: SKSpriteNode?
    var rightRec: SKSpriteNode?
    
    var spawnRate:TimeInterval = 2.0
    var timeSinceSpawn:TimeInterval = 0.0
    var lastTime:TimeInterval = 0.0
    
    var compRate:TimeInterval = 1.0
    var timeSinceUpdate:TimeInterval = 0.0
    var lastUpdateTime:TimeInterval = 0.0
    var compNum:Int = 5
    
    var finalScoreLabel:SKLabelNode?
    var finalScore:SKLabelNode?
    
    let noCategory:UInt32 = 0
    let playerCategory:UInt32 = 0b1
    let officerCategory:UInt32 = 0b1 << 1
    let recCategory:UInt32 = 0b1 << 2
    let outerRecCategory:UInt32 = 0b1 << 3
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self //for contact detection
        wastedLabel = self.childNode(withName: "wastedLabel") as? SKLabelNode
        wastedLabel?.fontName = "FORQUE"
        wastedLabel?.isHidden = true
        finalScoreLabel = self.childNode(withName: "finalScoreLabel") as?SKLabelNode
        finalScoreLabel?.isHidden = true
        finalScore = self.childNode(withName: "finalScore") as? SKLabelNode
        finalScore?.isHidden = true

        scoreboard = self.childNode(withName: "scoreboard") as? SKSpriteNode
        scoreLabel = scoreboard?.childNode(withName: "score") as? SKLabelNode //this it the actual score
        computerTime = scoreboard?.childNode(withName: "computerTime") as? SKLabelNode
        computerImage = scoreboard?.childNode(withName: "computerImage") as? SKSpriteNode
        scoreboard?.physicsBody?.categoryBitMask = recCategory
        scoreboard?.physicsBody?.collisionBitMask = noCategory
        scoreboard?.physicsBody?.contactTestBitMask = noCategory
        
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = recCategory //| officerCategory //what bounces off
        player?.physicsBody?.contactTestBitMask = officerCategory //everything that triggers a contact here
        
        
        topRec = self.childNode(withName: "topRec") as? SKSpriteNode
        topRec?.physicsBody?.categoryBitMask = recCategory
        topRec?.physicsBody?.collisionBitMask = noCategory
        topRec?.physicsBody?.contactTestBitMask = noCategory
        bottomRec = self.childNode(withName: "bottomRec") as? SKSpriteNode
        bottomRec?.physicsBody?.categoryBitMask = recCategory
        bottomRec?.physicsBody?.collisionBitMask = noCategory
        bottomRec?.physicsBody?.contactTestBitMask = noCategory
        leftRec = self.childNode(withName: "leftRec") as? SKSpriteNode
        leftRec?.physicsBody?.categoryBitMask = recCategory
        leftRec?.physicsBody?.collisionBitMask = noCategory
        leftRec?.physicsBody?.contactTestBitMask = noCategory
        rightRec = self.childNode(withName: "rightRec") as? SKSpriteNode
        rightRec?.physicsBody?.categoryBitMask = recCategory
        rightRec?.physicsBody?.collisionBitMask = noCategory
        rightRec?.physicsBody?.contactTestBitMask = noCategory
        
        topOuterRec = self.childNode(withName: "topOuterRec") as? SKSpriteNode
        topOuterRec?.physicsBody?.categoryBitMask = outerRecCategory
        topOuterRec?.physicsBody?.collisionBitMask = noCategory
        topOuterRec?.physicsBody?.contactTestBitMask = officerCategory
        bottomOuterRec = self.childNode(withName: "bottomOuterRec") as? SKSpriteNode
        bottomOuterRec?.physicsBody?.categoryBitMask = outerRecCategory
        bottomOuterRec?.physicsBody?.collisionBitMask = noCategory
        bottomOuterRec?.physicsBody?.contactTestBitMask = officerCategory
        leftOuterRec = self.childNode(withName: "leftOuterRec") as? SKSpriteNode
        leftOuterRec?.physicsBody?.categoryBitMask = outerRecCategory
        leftOuterRec?.physicsBody?.collisionBitMask = noCategory
        leftOuterRec?.physicsBody?.contactTestBitMask = officerCategory
        rightOuterRec = self.childNode(withName: "rightOuterRec") as? SKSpriteNode
        rightOuterRec?.physicsBody?.categoryBitMask = outerRecCategory
        rightOuterRec?.physicsBody?.collisionBitMask = noCategory
        rightOuterRec?.physicsBody?.contactTestBitMask = officerCategory
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == nil || contact.bodyB.node == nil{
            return
        }
        
        let cA:UInt32 = contact.bodyA.categoryBitMask
        let cB:UInt32 = contact.bodyB.categoryBitMask

        if cA == playerCategory || cB == playerCategory {
            let otherNode:SKNode = (cA == playerCategory) ? contact.bodyB.node! : contact.bodyA.node!
            playerCollide(with: otherNode)
        } else if cA == recCategory || cB == recCategory {
            let otherNode:SKNode = (cA == recCategory) ? contact.bodyB.node! : contact.bodyA.node!
            recCollide(with: otherNode) //s
        } else if cA == outerRecCategory || cB == outerRecCategory {
            let otherNode:SKNode = (cA == outerRecCategory) ? contact.bodyB.node! : contact.bodyA.node!
            outerRecCollide(with: otherNode) //s
        }  else { //both officers
            let bA:SKNode = contact.bodyA.node!
            let bB:SKNode = contact.bodyB.node!
            

            //====================================================================score=====
            //let points:Int = contact.bodyA.node?.userData?.value(forKey: "Int") as! Int
            //contact.bodyA.node?.removeFromParent()
            //contact.bodyB.node?.removeFromParent()

        }
        scoreLabel?.text = "\(score)"

        computerTime?.text = "\(compNum)"
    }
    func outerRecCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        if gameOver != true {
            if playerState == compState {
                score += 1
            }
            
        }

        if otherCategory == officerCategory {
            other.removeFromParent()
        } else {
            print("\(otherCategory)")
        }
    }
    
    func playerCollide(with other: SKNode) {
        let otherCategory = other.physicsBody?.categoryBitMask
        
        if otherCategory == officerCategory {
            if playerState == compState {
                other.removeFromParent()
            } else {
                other.removeFromParent()
                gameIsOver()
            }
            
        }
    }
    
    func gameIsOver() {
        gameOver = true
        let finalScoreNum:Int = score
        print("You got \(finalScoreNum)")
        finalScoreLabel?.isHidden = false
        finalScore?.text = "\(finalScoreNum)"
        finalScore?.isHidden = false
        wastedLabel?.isHidden = false
        spawnAll3()
        
    }
    
    func recCollide(with other: SKNode) {
        if gameOver != true {
            score += 1
        }

        let otherCategory = other.physicsBody?.categoryBitMask
        if otherCategory == officerCategory {
            other.removeFromParent()
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        //moved = false
    }
    
    func changeSkin() {
//        let pText:SKTexture = (player?.texture)!
//        let oText:SKTexture = SKTexture(imageNamed: "Dao")
//        if pText.isEqual(oText){
//            player?.texture = SKTexture(imageNamed: "dividedOfficer")
//        } else {
//            print("\(pText)")
//            print("\(oText)")
//            player?.texture = SKTexture(imageNamed: "dividedOfficer2")
//        }
//

//        if player?.texture == SKTexture(imageNamed: "Dao") {
//            player?.texture = SKTexture(imageNamed: "dividedOfficer")
//        } else {
//            player?.texture = SKTexture(imageNamed: "Dao")
//        }
        if gameOver != true {
            if playerState == 3 {
                player?.texture = SKTexture(imageNamed: "Dao")
                playerState = 1
            } else if playerState == 1 {
                player?.texture = SKTexture(imageNamed: "Joe")
                playerState = 2
            } else if playerState == 2 {
                player?.texture = SKTexture(imageNamed: "Brian")
                playerState = 3
            }
        }

    }
    
    //for spawning officers
    func checkOfficer(_ frameRate:TimeInterval) {
        timeSinceSpawn += frameRate
        
        if timeSinceSpawn < spawnRate {
            return
        }
        
        spawnOfficer()
        
        timeSinceSpawn = 0.0
    }
    //for updating timer
    func updateCompTime(_ upDateRate:TimeInterval) {
        //make it go 5 4 3 2 1 0
        timeSinceUpdate += upDateRate
        
        if timeSinceUpdate < compRate {
            return
        }
        changeTime()
        //changeFace()
        
        timeSinceUpdate = 0.0
        
        //var time:Int = Int(computerTime!.text!)!
        //print("\(time)")
    }
    //actually updating time
    func changeTime() {
        if compNum > 0 {
            compNum -= 1
        } else {
            randomlyGenerateFace()
            //print("change")
            compNum = 5
        }
    }
//    func changeFace(){
//        if compNum == 0 {
//            randomlyGenerateFace()
//        }
//    }
    
    //for computer image
    func randomlyGenerateFace() {
//        let currentFace:SKTexture = (computerImage?.texture)!
//        if currentFace.hash == SKTexture(imageNamed: "Dao").hash {
//            print("success!")
//        } else {
//            print(currentFace.hash)
//            print(SKTexture(imageNamed: "Dao").hash)
//        }
        if gameOver != true {
            let whatFace:Int = Int(arc4random()) % 3 + 1
            if whatFace == 1 {
                computerImage?.texture = SKTexture(imageNamed: "Dao")
                compState = 1
            } else if whatFace == 2 {
                computerImage?.texture = SKTexture(imageNamed: "Joe")
                compState = 2
            } else if whatFace == 3 {
                computerImage?.texture = SKTexture(imageNamed: "Brian")
                compState = 3
            }
        }


        
    }
    func spawnOfficer() {
        if gameOver != true {
            //random choose a officer
            let off = Int(arc4random()) % 3 + 1 // 1,2,3,4
            var dividedOfficer: SKNode?
            if off == 1 {
                let scene:SKScene = SKScene(fileNamed: "dividedOfficer")!
                dividedOfficer = scene.childNode(withName: "dividedOfficer")
                
            } else {
                let fileName: String = off == 2 ? "dividedOfficer2" : "dividedOfficer3"
                let scene:SKScene = SKScene(fileNamed: fileName)!
                dividedOfficer = scene.childNode(withName: fileName)
                
            }
            
            //for randomizing where it spawns relative to the rectangle
            //ex: rect + 300, rect - 200
            //var i = Int(arc4random()) % Int(bottomRec!.size.width - 100)
            //print(i)
            let whichSide = Int(arc4random()) % 4 + 1 // 1,2,3,4
            //what impulse - trying to add force based on what side it coming from... not working
            var whatImpulse: CGVector?
            if whichSide > 2 {
                dividedOfficer?.position = (whichSide == 3 ? bottomRec?.position : topRec?.position)!
                whatImpulse = (whichSide == 3 ?  CGVector(dx: 0, dy: 500): CGVector(dx: 0, dy: -500))
                
            } else {
                dividedOfficer?.position = (whichSide == 1 ? leftRec?.position : rightRec?.position)!
                whatImpulse = (whichSide == 1 ?  CGVector(dx: 500, dy: 0): CGVector(dx: -500, dy: 0))
                
            }
            dividedOfficer?.physicsBody?.velocity = whatImpulse!
            //dividedOfficer?.position = bottomRec!.position
            dividedOfficer?.move(toParent: self)
            
            dividedOfficer?.physicsBody?.categoryBitMask = officerCategory
            dividedOfficer?.physicsBody?.collisionBitMask = noCategory //playerCategory
            dividedOfficer?.physicsBody?.contactTestBitMask = playerCategory | officerCategory
            //dividedOfficer?.userData?.setValue(1, forKey: "Int") //dont think it works, gonna manually put in
            //in sks file

        }

        
    }
    
    
    func spawnAll3() {
        var dividedOfficer: SKNode?
        let scene:SKScene = SKScene(fileNamed: "dividedOfficer")!
        dividedOfficer = scene.childNode(withName: "dividedOfficer")
        dividedOfficer?.position = CGPoint(x: player!.position.x + 125, y: player!.position.y + 125)
        dividedOfficer?.move(toParent: self)
        
        dividedOfficer?.physicsBody?.categoryBitMask = noCategory
        dividedOfficer?.physicsBody?.collisionBitMask = noCategory //playerCategory
        dividedOfficer?.physicsBody?.contactTestBitMask = noCategory
        
        var dividedOfficer2: SKNode?
        let scene2:SKScene = SKScene(fileNamed: "dividedOfficer2")!
        dividedOfficer2 = scene2.childNode(withName: "dividedOfficer2")
        dividedOfficer2?.position = CGPoint(x: player!.position.x + -150, y: player!.position.y)
        dividedOfficer2?.move(toParent: self)
        
        dividedOfficer2?.physicsBody?.categoryBitMask = noCategory
        dividedOfficer2?.physicsBody?.collisionBitMask = noCategory //playerCategory
        dividedOfficer2?.physicsBody?.contactTestBitMask = noCategory
        
        var dividedOfficer3: SKNode?
        let scene3:SKScene = SKScene(fileNamed: "dividedOfficer3")!
        dividedOfficer3 = scene3.childNode(withName: "dividedOfficer3")
        dividedOfficer3?.position = CGPoint(x: player!.position.x + 125, y: player!.position.y - 125)
        dividedOfficer3?.move(toParent: self)
        
        dividedOfficer3?.physicsBody?.categoryBitMask = noCategory
        dividedOfficer3?.physicsBody?.collisionBitMask = noCategory //playerCategory
        dividedOfficer3?.physicsBody?.contactTestBitMask = noCategory
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if pos.y.isLess(than: 467.0) && gameOver != true {
            player?.position = pos
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        changeSkin()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updateCompTime(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime

        checkOfficer(currentTime - lastTime)
        lastTime = currentTime

        //changeTime()
    }
}
