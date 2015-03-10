//
//  IntroScene.swift
//  Bouncers
//
//  Created by Kyle Peterson on 2/24/15.
//  Copyright (c) 2015 KP. All rights reserved.
//

import SpriteKit

class SandboxScene: SKScene{
    let mainGame = GameScene()
    var wayPoints: [timedPoint] = []
    var gameLayer = SKNode()
    
    var ud = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView) {
        addChild(gameLayer)
        var bgImage = SKSpriteNode(imageNamed: "BG")
        bgImage.size = size
        bgImage.position = CGPoint(x: size.width/2, y: size.height/2)
        gameLayer.addChild(bgImage)
        var card1 = makeTextCard("Lorem Ipsum, blah blah blah. This is a cool idea but man its difficult.")
        gameLayer.addChild(card1)
    }
    
    func createPathToMove() -> CGPathRef? {
        var currDate = NSDate().dateByAddingTimeInterval(-0.5)
        var filteredWayPoints = wayPoints.filter({$0.addedAt.timeIntervalSinceReferenceDate > currDate.timeIntervalSinceReferenceDate})
        
        if filteredWayPoints.count <= 1 {
            return nil
        }
        
        var ref = CGPathCreateMutable()
        
        for var i = 0; i < filteredWayPoints.count; ++i {
            let p = filteredWayPoints[i]
            
            if i == 0 {
                CGPathMoveToPoint(ref, nil, p.point.x, p.point.y)
            } else {
                CGPathAddLineToPoint(ref, nil, p.point.x, p.point.y)
            }
        }
        return ref
    }
    
    func drawLines() {
        enumerateChildNodesWithName("line", usingBlock: {node, stop in
            node.removeFromParent()
        })
        
        if let path = createPathToMove(){
            let shapeNode = SKShapeNode()
            shapeNode.path = path
            shapeNode.name = "line"
            shapeNode.strokeColor = SKColor(red: 82/255, green: 220/255, blue: 222/255, alpha: 0.9)
            shapeNode.lineWidth = 4
            shapeNode.zPosition = 1
            gameLayer.addChild(shapeNode)
        }
    }
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let location = touches.anyObject()!.locationInNode(self)
        wayPoints.append(timedPoint(point: location, addedAt: NSDate()))
        /*let val = gameLayer.paused
            println("Pause:\(!val)")
            makeTextCard("test")
            pause(!val)*/
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let location = touches.anyObject()!.locationInNode(self)
        wayPoints.append(timedPoint(point: location, addedAt: NSDate()))
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if (body != nil && body?.node?.name == "next"){
            pause(false)
            deleteTextCard()
        } else if (body != nil && body?.node?.name == settingsNodeName){
            let reveal = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 10)
            let settingsScene = SandboxScene(size: size)
            self.view?.presentScene(settingsScene)
        }

        
        println(wayPoints.count)
        wayPoints = []
    }
    
    override func update(currentTime: NSTimeInterval) {
        drawLines()
    }
    
    func pause(bool : Bool){
        setupOverlay(bool)
        gameLayer.paused = bool
    }
    
    func deleteTextCard(){
        var node = childNodeWithName("card")
        node?.removeFromParent()
        
    }
    
    func setupOverlay(bool : Bool){
        if bool {
            var overlay = SKSpriteNode(color: SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5), size: size)
            overlay.zPosition = 1
            overlay.position = CGPoint(x: size.width/2, y: size.height/2)
            overlay.name = overlayNodeName
            addChild(overlay)
        }else{
            childNodeWithName(overlayNodeName)?.removeFromParent()
        }
    }

}

class timedPoint {
    var point : CGPoint
    var addedAt : NSDate
    
    init(point: CGPoint, addedAt: NSDate){
        self.point = point
        self.addedAt = addedAt
    }
}
