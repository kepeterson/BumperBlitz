//
//  IntroScene.swift
//  Bouncers
//
//  Created by Kyle Peterson on 2/24/15.
//  Copyright (c) 2015 KP. All rights reserved.
//

import SpriteKit

class SettingsScene: SKScene{
    let mainGame = GameScene()
    var ud = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView) {
        var bgImage = SKSpriteNode(imageNamed: backgroundImage)
        bgImage.size = size
        bgImage.zPosition = CGFloat.min
        bgImage.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bgImage)
        
        var splashImage = SKSpriteNode(imageNamed: homeScreenTarget)
        splashImage.position = CGPoint(x: size.width/2, y: size.height/2)
        splashImage.zPosition = 9
        addChild(splashImage)
        splashImage.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.moveTo(CGPoint(x: size.width/4, y: size.height/2), duration: 3.0), SKAction.moveTo(CGPoint(x: 2 * size.width/4, y: size.height), duration: 3.0), SKAction.moveTo(CGPoint(x: 3 * size.width/4, y: size.height/2), duration: 3.0)])))
        
        var imagePathSfx = getImageFor(ud.boolForKey("sfxEnabled"), forButton: "sfx")
        
        var effectsButton = SKSpriteNode(imageNamed: imagePathSfx)
        effectsButton.position = CGPoint(x: 3*size.width/4, y: size.height/4)
        effectsButton.name = "sfx"
        effectsButton.physicsBody = SKPhysicsBody(circleOfRadius: effectsButton.size.height/2)
        effectsButton.physicsBody?.dynamic = false
        effectsButton.zPosition = 10
        addChild(effectsButton)
        
        var imagePathSound = getImageFor(ud.boolForKey("musicEnabled"), forButton: "music")
        
        var musicButton = SKSpriteNode(imageNamed: imagePathSound)
        musicButton.position = CGPoint(x:  size.width/2, y: size.height/4)
        musicButton.physicsBody = SKPhysicsBody(circleOfRadius: musicButton.size.height/2)
        musicButton.name = "music"
        musicButton.zPosition = 10
        musicButton.physicsBody?.dynamic = false
        addChild(musicButton)
        
        var backButton = SKSpriteNode(imageNamed: "backw")
        backButton.position = CGPoint(x: size.width/4, y: size.height/4)
        backButton.physicsBody = SKPhysicsBody(circleOfRadius: backButton.size.height/2)
        backButton.name = "back"
        backButton.physicsBody?.dynamic = false
        backButton.zPosition = 10
        addChild(backButton)
        
        var tutButton = SKLabelNode(fontNamed: mainFont)
        var oButton = SKShapeNode(rectOfSize: CGSize(width: 200, height: 75))
        oButton.position = CGPoint(x: size.width/2, y: size.height * 1/18)
        tutButton.color = SKColor.whiteColor()
        tutButton.zPosition = 10
        tutButton.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 150, height: 75), center: tutButton.position)
        tutButton.physicsBody?.dynamic = false
        oButton.fillColor = SKColor.grayColor()
        tutButton.text = "Tutorial"
        tutButton.name = "tutorial"
        oButton.addChild(tutButton)
        addChild(oButton)
    }
    
    func getImageFor(boo: Bool, forButton: String) -> String{
        switch forButton{
            case "music":
                if boo {
                    return musicImage
                } else {
                    return musicOffImage
                }
            case "sfx":
                if boo {
                    return sfxImage
                } else {
                    return sfxOffImage
                }
            default:
                return "ug"
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if (body != nil && body?.node?.name == "music"){
            ud.setBool(!ud.boolForKey("musicEnabled"), forKey: "musicEnabled")
            var sprite = body?.node as SKSpriteNode
            sprite.texture = SKTexture(imageNamed: getImageFor(ud.boolForKey("musicEnabled"), forButton: "music"))
            if ud.boolForKey("musicEnabled"){
                MusicSingleton.sharedInstance.playMusic(musicFile)
            } else {
                MusicSingleton.sharedInstance.stopMusic()
            }
        } else if (body != nil && body?.node?.name == "sfx"){
            ud.setBool(!ud.boolForKey("sfxEnabled"), forKey: "sfxEnabled")
            var sprite = body?.node as SKSpriteNode
            sprite.texture = SKTexture(imageNamed: getImageFor(ud.boolForKey("sfxEnabled"), forButton: "sfx"))
        } else if (body != nil && body?.node?.name == "back"){
            let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
            let introScene = IntroScene(size: size)
            self.view?.presentScene(introScene)
        } else if (body != nil && body?.node?.name == "tutorial"){
            let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
            let tutorialScene = TutorialScene(size: size)
            self.view?.presentScene(tutorialScene)
        }
        
    }
}
