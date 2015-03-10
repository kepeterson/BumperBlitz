//
//  IntroScene.swift
//  Bouncers
//
//  Created by Kyle Peterson on 2/24/15.
//  Copyright (c) 2015 KP. All rights reserved.
//

import SpriteKit

class IntroScene: SKScene{
    let mainGame = GameScene()
    let nd = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView) {
        var bgImage = SKSpriteNode(imageNamed: backgroundImage)
        bgImage.size = size
        bgImage.position = CGPoint(x: size.width/2, y: size.height/2)
        bgImage.zPosition = CGFloat.min
        addChild(bgImage)
        
        var splashImage = SKSpriteNode(imageNamed: homeScreenTarget)
        splashImage.position = CGPoint(x: size.width/2, y: size.height/2)
        splashImage.zPosition = CGFloat.max
        addChild(splashImage)
        splashImage.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.moveTo(CGPoint(x: 0 + splashImage.size.width/2, y: size.height/2), duration: 1.0), SKAction.moveTo(CGPoint(x: size.width - splashImage.size.width/2, y: size.height/2), duration: 1.0)])))
        
        var titleName = SKLabelNode(fontNamed: mainFont)
        titleName.position = CGPoint(x: size.width/2, y: 0.70 * size.height)
        titleName.text = "BUMPER BLITZ"
        titleName.fontColor = fontColor
        if UIScreen.mainScreen().bounds.size.height < 321 {
            titleName.fontSize = 70
        } else {
            titleName.fontSize = 80
        }
        titleName.zPosition = 10
        addChild(titleName)
        
        var playButton = SKSpriteNode(imageNamed: playButtonImage)
        playButton.position = CGPoint(x: size.width/3, y: size.height/4)
        playButton.name = playNodeName
        playButton.physicsBody = SKPhysicsBody(circleOfRadius: playButton.size.height/2)
        playButton.physicsBody?.dynamic = false
        playButton.zPosition = 10
        addChild(playButton)
        
        var settingsButton = SKSpriteNode(imageNamed: settingsButtonImage)
        settingsButton.position = CGPoint(x: 2 * size.width/3, y: size.height/4)
        settingsButton.physicsBody = SKPhysicsBody(circleOfRadius: settingsButton.size.height/2)
        settingsButton.name = settingsNodeName
        settingsButton.physicsBody?.dynamic = false
        settingsButton.zPosition = 10
        addChild(settingsButton)
        
        if nd.boolForKey("musicEnabled"){
            MusicSingleton.sharedInstance.playMusic(musicFile)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if (body != nil && body?.node?.name == playNodeName){
            println("play")
            let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
            if nd.boolForKey("tutorialEnabled") {
                let gameScene = TutorialScene(size: size)
                self.view?.presentScene(gameScene)
            } else {
                let gameScene = GameScene(size: size)
                self.view?.presentScene(gameScene)
            }
        } else if (body != nil && body?.node?.name == settingsNodeName){
            let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
            let settingsScene = SettingsScene(size: size)
            self.view?.presentScene(settingsScene)
        }
        
    }
}
