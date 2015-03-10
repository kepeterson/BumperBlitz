import Foundation
import SpriteKit

class GameOverScene: SKScene {
    var ud = NSUserDefaults.standardUserDefaults()
    var scores: Array<Int> = []
    
    init(size: CGSize, score:Int) {
        super.init(size: size)
        isHighScore(score)
        var bgImage = SKSpriteNode(imageNamed: backgroundImage)
        bgImage.size = size
        bgImage.zPosition = CGFloat.min
        bgImage.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bgImage)

        var message1 = "GAME OVER"
        
        let label = SKLabelNode(fontNamed: mainFont)
        label.text = message1
        label.fontSize = 80
        label.zPosition = 10
        label.fontColor = fontColor
        label.position = CGPoint(x: size.width/2, y: 0.77 * size.height)
        addChild(label)
        
        var message2 = "SCORE: \(score)"
        let labelScore = SKLabelNode(fontNamed: mainFont)
        labelScore.text = message2
        labelScore.fontSize = 60
        labelScore.zPosition = 10
        labelScore.fontColor = fontColor
        labelScore.position = CGPoint(x: 0.3 * size.width, y: 7 * size.height/16)
        addChild(labelScore)
        
        var highScoresNode = buildHighScoreLabel()
        highScoresNode.position = CGPoint(x: 3 * size.width/4, y: 3 * size.height/5)
        highScoresNode.zPosition = 10
        addChild(highScoresNode)
        
        var replayButton = SKSpriteNode(imageNamed: replayImage)
        replayButton.position = CGPoint(x: 3 * size.width/4, y: size.height/6)
        replayButton.name = replayNodeName
        replayButton.physicsBody = SKPhysicsBody(circleOfRadius: replayButton.size.height/2)
        replayButton.physicsBody?.dynamic = false
        replayButton.zPosition = 10
        addChild(replayButton)
        
        var homeButton = SKSpriteNode(imageNamed: homeImage)
        homeButton.position = CGPoint(x: size.width/4, y: size.height/6)
        homeButton.name = homeNodeName
        homeButton.physicsBody = SKPhysicsBody(circleOfRadius: homeButton.size.height/2)
        homeButton.physicsBody?.dynamic = false
        homeButton.zPosition = 10
        addChild(homeButton)
        
        //NSNotificationCenter.defaultCenter().postNotificationName("playAd", object: nil)
    }
    
    func isHighScore(score: Int){
        scores = ud.objectForKey("highScores") as Array<Int>
        if score > scores[0] as Int{
            scores[2] = scores[1]
            scores[1] = scores[0]
            scores[0] = score
        } else if score > scores[1] as Int{
            scores[2] = scores[1]
            scores[1] = score
        } else if score > scores[2] as Int {
            scores[2] = score
        }
        
        ud.setObject(scores, forKey: "highScores")
        println(scores)
        
    }
    
    func buildHighScoreLabel() -> SKNode {
        var node = SKNode()
        var line1 = SKLabelNode(fontNamed: mainFont)
        line1.text = "HIGH SCORES"
        line1.fontColor = fontColor
        node.addChild(line1)
        var leftOffset = -55
        
        for i in 0..<3{
            var dotLine = SKLabelNode(fontNamed: mainFont)
            var rankLabel = SKLabelNode(fontNamed: mainFont)
            var scoreLine = SKLabelNode(fontNamed: mainFont)
            rankLabel.text = String(i+1)
            rankLabel.position = CGPoint(x: leftOffset, y: -30 * (i + 1))
            rankLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            dotLine.text = ":"
            dotLine.position = CGPoint(x: leftOffset + 25, y: -30 * (i + 1))
            dotLine.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            scoreLine.text = String(scores[i])
            scoreLine.position = CGPoint(x: leftOffset + 45, y: -30 * (i + 1))
            scoreLine.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            node.addChild(dotLine); node.addChild(rankLabel); node.addChild(scoreLine)
        }
        
        return node
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch: AnyObject? = touches.anyObject()
        let touchLocation = touch?.locationInNode(self)
        let body = self.physicsWorld.bodyAtPoint(touchLocation!)
        
        if (body != nil && body?.node?.name == replayNodeName){
            backgroundImage = getBackGround()
            view?.presentScene(GameScene(size: size))
        } else if (body != nil && body?.node?.name == homeNodeName){
            backgroundImage = getBackGround()
            view?.presentScene(IntroScene(size: size))
        }
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}