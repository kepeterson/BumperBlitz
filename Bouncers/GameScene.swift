struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Target   : UInt32 = 0b1       // 1
    static let Bouncer: UInt32 = 0b10      // 2
}
enum ColliderType: UInt32 {
    case Target = 1
    case Beam = 2
    case Wall = 4
}

struct spawnMoreThresholds{
    static let One: Double = 15
    static let Two: Double = 30
    static let Three: Double = 60
    static let Four: Double = 120
    static let Five: Double = 480
}

struct Z {
    static let textCard: CGFloat = 10
}

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint{
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

func distance (point1: CGPoint, point2: CGPoint) -> CGFloat{
    return sqrt(pow((point1.x - point2.x),2) + pow((point1.y - point2.y),2))
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

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let actionMoveDone = SKAction.removeFromParent(); var gameLayer = SKNode()
    var score = 0, combo = 0; var HUDLayer = SKNode()
    var extantTargets = 0; var extantPowerUps = 0
    var start = NSDate()
    var currentSpawnTime = 2.0; var currentPowerUpSpawnTime = 8.0
    var bladeMode = false; var bigMode = false; var touchInProgress = false
    var bigTouches: Int = 0
    let nd = NSUserDefaults.standardUserDefaults()
    
    
    func setupHud(){
        let scoreLabel = SKLabelNode(fontNamed: mainFont)
        scoreLabel.fontSize = 30
        scoreLabel.name = scoreNodeName
        scoreLabel.fontColor = fontColor
        scoreLabel.zPosition = CGFloat.max
        scoreLabel.text = String(format:"Score: %02u", score)
        scoreLabel.position = CGPoint(x: 90, y: size.height - 35)
        HUDLayer.addChild(scoreLabel)
        
    }
    
    func setupOverlay(bool : Bool){
        if bool {
            var overlay = SKSpriteNode(color: SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), size: size)
            overlay.zPosition = 1
            overlay.position = CGPoint(x: size.width/2, y: size.height/2)
            overlay.name = overlayNodeName
            HUDLayer.addChild(overlay)
        }else{
            HUDLayer.childNodeWithName(overlayNodeName)?.removeFromParent()
        }
    }
    
    func enableGlowFrame(enable : Bool, color : SKColor){
        
        if enable {
            var glowPath = CGPathCreateWithRoundedRect(frame, 5, 5, nil)
            var glowShape = SKShapeNode(path: glowPath)
            glowShape.zPosition = 5
            glowShape.glowWidth = 15
            glowShape.name = glowShapeName
            glowShape.strokeColor = color
            HUDLayer.addChild(glowShape)
        } else {
            HUDLayer.childNodeWithName(glowShapeName)?.removeFromParent()
        }
    }
    
    override func didMoveToView(view: SKView) {
        
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
        
        spawnPowerUp()
        spawnTargets(1)
    }

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#mini: CGFloat, #maxi: CGFloat) -> CGFloat {
        return random() * (maxi - mini) + mini
    }
    
    func randomDirection() -> CGFloat{
        if (random() > 0.5){
            return CGFloat(1)
        } else {
            return CGFloat(-1)
        }
    }
    
    func adjustScoreBy(scoreAdd: Int){
        score += scoreAdd
        let scoreNode = HUDLayer.childNodeWithName(scoreNodeName) as SKLabelNode
        scoreNode.text = String(format:"Score: %02u", score)
    }

    
    func adjustComboBy(comboIncrease: Int) {
        var end = NSDate()
        var interval = end.timeIntervalSinceDate(start)
        let comboTimeOut = score > 300 ? 1.5 : -1.5 * Float(score)/Float(300) + 3
        if (interval > NSTimeInterval(comboTimeOut)){
            combo = 0
            self.start = NSDate()
        }
        start = start.dateByAddingTimeInterval(interval/3)
        combo += comboIncrease
    }
    
    func spawnTargets(num: Int){
        for i in 0..<num {
            addTarget()
        }
        var spawnNumber = 1
        if Double(score) < spawnMoreThresholds.One{
            currentSpawnTime = (-Double(score)/spawnMoreThresholds.One * 0.8 + 1)
        } else if Double(score) < spawnMoreThresholds.Two{
            spawnNumber = 2
            currentSpawnTime = (-Double(score)/spawnMoreThresholds.One + 3)
        } else if Double(score) < spawnMoreThresholds.Three {
            spawnNumber = 3
            currentSpawnTime = (-Double(score)/spawnMoreThresholds.Two + 3)
        } else if Double(score) < spawnMoreThresholds.Four {
            spawnNumber = 4
            currentSpawnTime = (-Double(score)/spawnMoreThresholds.Three + 3)
        } else if Double(score) < spawnMoreThresholds.Five{
            spawnNumber = 5
            currentSpawnTime = (-Double(score)/spawnMoreThresholds.Four + 3)
        } else {
            spawnNumber = 6
        }
        
        runAction(SKAction.sequence([SKAction.waitForDuration(currentSpawnTime), SKAction.runBlock({
            self.spawnTargets(spawnNumber)})]))
    }
    
    func spawnPowerUp(){
        if extantPowerUps == 0 && !bladeMode && !bigMode {
            addPowerUp()
        }
        runAction(SKAction.sequence([SKAction.waitForDuration(currentPowerUpSpawnTime), SKAction.runBlock({self.spawnPowerUp()})]))
    }
    
    func addTarget(){
        let target = SKSpriteNode(imageNamed: targetImage)
        let targetX = random(mini:0, maxi:1)
        let targetY = random(mini:0, maxi:1)
        let leftXBound = size.width/3
        let topYBound = size.height/3
        target.setScale(1.25); target.zPosition = 2
        target.position = CGPoint(x: targetX*leftXBound+leftXBound, y: targetY*topYBound+topYBound)
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
        target.physicsBody?.categoryBitMask = ColliderType.Target.rawValue
        target.physicsBody?.contactTestBitMask = ColliderType.Target.rawValue | ColliderType.Wall.rawValue | ColliderType.Beam.rawValue
        target.physicsBody?.collisionBitMask = ColliderType.Wall.rawValue | ColliderType.Target.rawValue | ColliderType.Beam.rawValue
        
        let impulseMultiplier = 4.0 as CGFloat
        let impulseX = random(mini: 1, maxi: 2)
        let impulseY = random(mini: 1, maxi: 2)
        target.physicsBody?.applyImpulse(CGVector(dx: randomDirection() * impulseX * impulseMultiplier, dy: randomDirection() * impulseY * impulseMultiplier))
    }
    
    func addPowerUp(){
        let (imageName, nodeName) = randomPowerUp()
        let powerUp = SKSpriteNode(imageNamed: imageName)
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width/2)
        let targetX = random(mini:0, maxi:1)
        let targetY = random(mini:0, maxi:1)
        let leftXBound = size.width/3
        let topYBound = size.height/3
        powerUp.position = CGPoint(x: targetX*leftXBound+leftXBound, y: targetY*topYBound+topYBound)
        powerUp.name = nodeName
        powerUp.zPosition = 10
        var rotation = SKAction.repeatActionForever((SKAction.rotateByAngle(2 * CGFloat(M_PI), duration: 3.0)))
        gameLayer.addChild(powerUp)
        powerUp.runAction(rotation)
        extantPowerUps++
        
    }
    
    func randomPowerUp() -> (NSString, NSString){
        let randomNum = random()
        var imageName: NSString; var nodeName: NSString
        if randomNum > 0.5 {
            imageName = powerUpImage
            nodeName = powerUpNodeName
        } else {
            imageName = powerUp2Image
            nodeName = powerUp2NodeName
        }
        return (imageName, nodeName)
    }
    
    func removePowerUp(node: SKNode?){
        var color : SKColor = SKColor(); var duration: NSTimeInterval
        if node?.name == powerUpNodeName{
            bigMode = true
            color = SKColor.redColor()
            duration = 5.0
        } else if node?.name == powerUp2NodeName{
            bladeMode = true
            color = SKColor.yellowColor()
            duration = 7.5
        } else {
            println("unknown powerup!")
            return
        }
        node?.runAction(actionMoveDone)
        enableGlowFrame(true, color: color)
        extantPowerUps--
        if nd.boolForKey("sfxEnabled"){
            self.runAction(SKAction.playSoundFileNamed(powerUpFile, waitForCompletion: false))
        }
        var timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("clearPowerUps"), userInfo: nil, repeats: false)
    }
    
    //MARK: - Touch Events
    
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
            if bigTouches == 3{
                clearPowerUps()
            }
            //spriteAt(touchLocation!)
            
        }
        
        if bladeMode && !touchInProgress {
            touchInProgress = true
            presentBladeAtPosition(touchLocation!)
        }
        
        if body != nil{
            if body?.node?.name == targetNodeName{
                if nd.boolForKey("sfxEnabled"){
                    runAction(SKAction.playSoundFileNamed(hitFile, waitForCompletion: false))
                }
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
    
    func didBeginContact(contact: SKPhysicsContact) {
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
    
    func drawComboText(point: CGPoint){
        let comboText = SKLabelNode(fontNamed: mainFont)
        comboText.position = point
        comboText.fontSize = getFontSize(combo)
        comboText.text = String(combo)
        gameLayer.addChild(comboText)
        comboText.zPosition = 10
        var path = CGPathCreateMutable()
        var direction = randomDirection()
        CGPathMoveToPoint(path, nil, point.x, point.y)
        CGPathAddQuadCurveToPoint(path, nil, point.x + direction * 10, point.y + 50, point.x + direction * 100, point.y-100)
        let comboMove = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 1.0)
        let fadeAction = SKAction.fadeOutWithDuration(1.0)
        comboText.runAction(SKAction.sequence([SKAction.group([comboMove, fadeAction]), actionMoveDone]))
    }
    
    func removeTarget(removedTarget: SKPhysicsBody?, location: CGPoint?){
        removedTarget?.node?.runAction(actionMoveDone)
        adjustComboBy(1)
        if (combo > 3){
            drawComboText(location!)
        }
        adjustScoreBy(1)
        extantTargets--
    }
    
    func pause(bool : Bool){
        setupOverlay(bool)
        gameLayer.paused = bool
    }
    
    func clearPowerUps() {
        bladeMode = false
        bigModeEnded()
        enableGlowFrame(false, color: SKColor.whiteColor())
        bigTouches = 0
    }
    
    func bigModeEnded(){
        bigMode = false
        gameLayer.enumerateChildNodesWithName("temp", usingBlock: {node, stop in
            node.removeFromParent()
        })
    }
    
    // MARK: - SWBlade Functions
    var blade:SWBlade? = nil
    var delta = CGPointZero
    
    // This will help us to initialize our blade
    func presentBladeAtPosition(position:CGPoint) {
        blade = SWBlade(position: position, target: self, color: beamColor)
        blade?.enablePhysics(ColliderType.Beam.rawValue, contactTestBitmask: ColliderType.Target.rawValue, collisionBitmask: ColliderType.Target.rawValue)
        gameLayer.addChild(blade!)
    }
    
    func removeBlade() {
        touchInProgress = false
        delta = CGPointZero
        if let bladex = blade {
            bladex.removeFromParent()
        }
    }
}
