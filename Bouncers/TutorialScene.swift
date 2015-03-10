import SpriteKit
import AVFoundation


class TutorialScene: GameScene, SKPhysicsContactDelegate {
    var tutorialStep = 0
    var midPoint:CGPoint = CGPointZero

    
    override func didMoveToView(view: SKView) {
        
        midPoint = CGPoint(x: size.width/2, y: size.height/2)
        
        addChild(gameLayer); addChild(HUDLayer)
        var bgImage = SKSpriteNode(imageNamed: backgroundImage)
        bgImage.size = size; bgImage.zPosition = CGFloat.min
        bgImage.position = CGPoint(x: size.width/2, y: size.height/2)
        gameLayer.addChild(bgImage)
        //playBackgroundMusic("background-music-aac.caf")
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.contactTestBitMask = 0
        borderBody.categoryBitMask = ColliderType.Wall.rawValue
        borderBody.collisionBitMask = ColliderType.Target.rawValue | ColliderType.Wall.rawValue
        self.physicsBody = borderBody
        self.physicsBody?.friction = 0.0
        
        setupHud()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        doTutorial()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if bigMode && bigTouches < 3{
            bigTouches++
            var rect = CGRect(origin: touchLocation! + CGPoint(x: -bigSize/2, y: -bigSize/2), size: CGSize(width: bigSize, height: bigSize))
            var node = SKShapeNode(rect: rect)
            node.fillColor = SKColor.whiteColor()
            node.zPosition = 1
            node.alpha = 0.5
            gameLayer.addChild(node)
            node.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(1.0), actionMoveDone]))
            var hitTargets = Array<SKPhysicsBody>()
            physicsWorld.enumerateBodiesInRect(rect, usingBlock: {body, stop in
                if body.node?.name == targetNodeName{
                    hitTargets.append(body)
                }
            })
            hitTargets.map({bod in self.removeTarget(bod, location: bod?.node?.position)})
            //spriteAt(touchLocation!)
            
        }
        
        if bladeMode && !touchInProgress {
            touchInProgress = true
            presentBladeAtPosition(touchLocation!)
        }
        
        if body != nil{
            if body?.node?.name == targetNodeName{
                removeTarget(body, location: touchLocation)
            } else if body?.node?.name == powerUpNodeName || body?.node?.name == powerUp2NodeName{
                removePowerUp(body?.node)
            } else {
                println("Weird body hit:\(body?.node?.name)")
            }
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let currentPoint = touch?.locationInNode(self)
        let previousPoint = touch?.previousLocationInNode(self)
        if bladeMode && currentPoint != nil && previousPoint != nil{
            delta = currentPoint! - previousPoint!
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        removeBlade()
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if (body != nil && body?.node?.name == "next"){
            if tutorialStep == 0 {
                pause(false)
                HUDLayer.childNodeWithName("card")?.removeFromParent()
                addTargetAt(CGPoint(x: size.width * 4/11, y: size.height/2))
                addTargetAt(CGPoint(x: size.width * 7/11, y: size.height/2))
            } else if tutorialStep == 1{
                HUDLayer.childNodeWithName("card")?.removeFromParent()
                doTutorial3()
            } else if tutorialStep == 2 {
                HUDLayer.childNodeWithName("card")?.removeFromParent()
                pause(false)
                addPowerUpAt(CGPoint(x: size.width/2, y: size.height/2), type: (powerUp2Image, powerUp2NodeName))
                addTargetAt(CGPoint(x: size.width * 2/20, y: 5 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 4/20, y: 6 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 6/20, y: 7 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 8/20, y: 6 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 10/20, y: 5 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 12/20, y: 4 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 14/20, y: 5 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 16/20, y: 6 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 18/20, y: 7 * size.height/20))
            } else if tutorialStep == 3{
                HUDLayer.childNodeWithName("card")?.removeFromParent()
                pause(false)
                addPowerUpAt(CGPoint(x: size.width/2, y: size.height/2), type: (powerUpImage, powerUpNodeName))
                addTargetAt(CGPoint(x: size.width * 2/20, y: 3 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 4/20, y: 3 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 3/20, y: 6 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 18/20, y: 18 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 16/20, y: 18 * size.height/20))
                addTargetAt(CGPoint(x: size.width * 17/20, y: 15 * size.height/20))
            } else if tutorialStep == 4{
                nd.setBool(false, forKey: "tutorialEnabled")
                let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
                let settingsScene = IntroScene(size: size)
                self.view?.presentScene(settingsScene)
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        removeBlade()
    }
    
    override func update(currentTime: NSTimeInterval) {
        if blade != nil && bladeMode{
            let newPosition = CGPoint(x: blade!.position.x + delta.x, y: blade!.position.y + delta.y)
            blade!.position = newPosition
        }
    }
    
    override func didBeginContact(contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node
        let secondNode = contact.bodyB.node
        
        let collision = firstNode!.physicsBody!.categoryBitMask | secondNode!.physicsBody!.categoryBitMask
        if collision == ColliderType.Target.rawValue | ColliderType.Beam.rawValue {
            let theNode = [firstNode, secondNode].filter({$0?.name == targetNodeName}).first!
            removeTarget(theNode!.physicsBody, location: theNode!.position)
            println("Special ability collision")
        } else if collision == ColliderType.Target.rawValue | ColliderType.Target.rawValue {
            //NSLog("Target target detected")
        } else if collision == ColliderType.Wall.rawValue | ColliderType.Target.rawValue {
            //println("Wall!")
        } else {
            //NSLog("Error: Unknown collision category \(collision)")
        }
    }
    
    func addTargetAt(point: CGPoint){
        let target = SKSpriteNode(imageNamed: targetImage)
        target.setScale(1.25); target.zPosition = 2
        target.position = point
        target.name = targetNodeName
        gameLayer.addChild(target)
        extantTargets++
        
        if (extantTargets > gameOverNumber){
            let reveal = SKTransition.crossFadeWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: score)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        target.physicsBody = SKPhysicsBody(circleOfRadius: target.size.width/2)
        target.physicsBody?.friction = 0.0
        target.physicsBody?.restitution = 1.0
        target.physicsBody?.linearDamping = 0.0
        target.physicsBody?.usesPreciseCollisionDetection = true
        target.physicsBody?.categoryBitMask = ColliderType.Target.rawValue
        target.physicsBody?.contactTestBitMask = ColliderType.Target.rawValue | ColliderType.Wall.rawValue | ColliderType.Beam.rawValue
        target.physicsBody?.collisionBitMask = ColliderType.Wall.rawValue | ColliderType.Target.rawValue | ColliderType.Beam.rawValue
    }
    
    override func removeTarget(removedTarget: SKPhysicsBody?, location: CGPoint?) {
        super.removeTarget(removedTarget, location: location)
        if score == 2 {
            doTutorial2()
        } else if score == 11 {
            clearPowerUps()
            delay(0.25){
                self.gameLayer.childNodeWithName(powerUp2NodeName)?.removeFromParent()
                while let target = self.gameLayer.childNodeWithName(targetNodeName){
                    target.removeFromParent()
                }
                self.doTutorial4()
            }
        } else if score == 17 {
            clearPowerUps()
            delay(0.25){
                self.doTutorial5()
            }
        }
    }
    
    func addPowerUpAt(point: CGPoint, type: (String, String)){
        let (imageName, nodeName) = type
        let powerUp = SKSpriteNode(imageNamed: imageName)
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width/2)
        powerUp.position = point
        powerUp.name = nodeName
        powerUp.zPosition = 10
        var rotation = SKAction.repeatActionForever((SKAction.rotateByAngle(2 * CGFloat(M_PI), duration: 3.0)))
        gameLayer.addChild(powerUp)
        powerUp.runAction(rotation)
        extantPowerUps++
        
    }

        
    func doTutorial(){
        pause(true)
        var card1 = makeTextCard("BUMPERBLITZ is a hectic game of reflexes and accuracy. Tap bumpers to destroy them.")
        card1.position = midPoint
        HUDLayer.addChild(card1)
    }
    
    func doTutorial2(){
        tutorialStep = 1
        pause(true)
        var card = makeTextCard("The more bumpers you've taken out, the faster they'll spawn. You'll want to use both thumbs!")
        card.position = midPoint
        HUDLayer.addChild(card)
    }
    
    func doTutorial3(){
        tutorialStep = 2
        var card = makeTextCard("BUMPERBLITZ also features power-ups that help you destroy bumpers more effectively. The first is the blade power-up. Tap the swirly yellow power-up, then drag your finger over the bumpers.")
        card.position = midPoint
        HUDLayer.addChild(card)
    }
    
    func doTutorial4(){
        tutorialStep = 3
        pause(true)
        var card = makeTextCard("The second power-up is the MEGA finger. This buff makes your next 3 taps bigger and allows you to take out clustered groups of bumpers with ease.")
        card.position = midPoint
        HUDLayer.addChild(card)
    }
    
    func doTutorial5(){
        tutorialStep = 4
        pause(true)
        var card = makeTextCard("That's all you need to know to play BUMPLERBLITZ. How high can you score? You can re-do this tutorial at any time from the Settings screen.")
        card.position = midPoint
        HUDLayer.addChild(card)
    }
    
}
