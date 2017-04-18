//
//  MainMenu.swift
//  DividedAirlines
//
//  Created by Brian Wang on 4/17/17.
//  Copyright © 2017 Kevin Lee. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var playButton:SKSpriteNode?
    
    override func didMove(to view: SKView) {
        print("fku joe")
        playButton = self.childNode(withName: "playButton") as! SKSpriteNode
        playButton?.name = "playButton"
        playButton?.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if (playButton?.contains(location))! {
                print("fuck")
                let nextScene = SKScene(fileNamed: "GameScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene)

            }
        }
//        let touch:UITouch = touches.first!
//        let positionInScene = touch.location(in: self)
//        let touchedNode:SKNode = self.nodes(at: positionInScene).first!
//        
//        if let name = touchedNode.name {
//            
//            if name == "playButton" {
//                print("fuck")
//                let nextScene = SKScene(fileNamed: "GameScene")
//                nextScene?.scaleMode = .aspectFill
//                self.view?.presentScene(nextScene)
//
//            }
//        }
    }
}
