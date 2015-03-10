//
//  GameScene.swift
//  SWBladeDemo
//
//  Created by Julio Montoya on 18/06/14.
//  Copyright (c) 2014 Julio Montoya. All rights reserved.
//

import SpriteKit


class Sandbox2: SKScene {
    // This optional variable will help us to easily access our blade
    var blade:SWBlade?
    let textureAtlas = SKTextureAtlas(named:"pound.atlas")
    var spriteArray = Array<SKTexture>();
    
    var monsterSprite = SKSpriteNode();
    
    // This will help us to update the position of the blade
    // Set the initial value to 0
    var delta = CGPointZero
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.blackColor()
        
        spriteArray.append(textureAtlas.textureNamed("slam1"));
        spriteArray.append(textureAtlas.textureNamed("slam2"));
        spriteArray.append(textureAtlas.textureNamed("slam3"));
        spriteArray.append(textureAtlas.textureNamed("slam4"));
        spriteArray.append(textureAtlas.textureNamed("slam5"))
        
        monsterSprite = SKSpriteNode(texture:spriteArray[0]);
        monsterSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        monsterSprite.xScale = 0.5;
        monsterSprite.yScale = 0.5;
        addChild(self.monsterSprite);
        
        
        let animateAction = SKAction.animateWithTextures(self.spriteArray, timePerFrame: 0.20);
        let repeatAction = SKAction.repeatActionForever(animateAction);
        let waitAction = SKAction.waitForDuration(1)
        let group = SKAction.repeatActionForever(SKAction.sequence([animateAction,waitAction]))
        self.monsterSprite.runAction(group);
    }
    
    // MARK: - SWBlade Functions
    
    // This will help us to initialize our blade
    func presentBladeAtPosition(position:CGPoint) {
        blade = SWBlade(position: position, target: self, color: UIColor.whiteColor())
        self.addChild(blade!)
    }
    
    // This will help us to remove our blade and reset the delta value
    func removeBlade() {
        delta = CGPointZero
        blade!.removeFromParent()
    }
    
    // MARK: - Touch Events
    
    // initialize the blade at touch location
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let any_object: AnyObject? = touches.anyObject()
        let touchLocation = any_object!.locationInNode(self)
        presentBladeAtPosition(touchLocation)
    }
    
    // delta value will help us later to properly update our blade position,
    // Calculate the difference between currentPoint and previousPosition and store that value in delta
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let any_object: AnyObject? = touches.anyObject()
        let currentPoint = any_object!.locationInNode(self)
        let previousPoint = any_object!.previousLocationInNode(self)
        delta = CGPoint(x: currentPoint.x - previousPoint.x, y: currentPoint.y - previousPoint.y)
    }
    
    // Remove the Blade if the touches have been cancelled or ended
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        removeBlade()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        removeBlade()
    }
    
    // MARK: - FPS
    
    override func update(currentTime: CFTimeInterval) {
        // if the blade is available
        if blade != nil {
            // Here you add the delta value to the blade position
            let newPosition = CGPoint(x: blade!.position.x + delta.x, y: blade!.position.y + delta.y)
            // Set the new position
            blade!.position = newPosition
            // it's important to reset delta at this point,
            // You are telling the blade to only update his position when touchesMoved is called
            delta = CGPointZero
        }
    }
    
}