//
//  Helpers.swift
//  BumperBlitz
//
//  Created by Kyle Peterson on 2/26/15.
//  Copyright (c) 2015 KP. All rights reserved.
//

import Foundation
import SpriteKit

func getFontSize(score : Int) -> CGFloat{
    if score < 10 {
        return CGFloat(25)
    } else if score < 20 {
        return CGFloat(31)
    } else if score < 50 {
        return CGFloat(39)
    } else if score < 100 {
        return CGFloat(47)
    } else if score < 250 {
        return CGFloat(55)
    } else {
        return CGFloat(67)
    }
}

func addTextNode(text: String, width: Int) -> SKNode {
    let seperators = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let words = text.componentsSeparatedByCharactersInSet(seperators)
    let len = words.count
    var node = SKNode()
    
    let totLines = words.reduce(0, combine: {$0 + countElements($1)})/width + 1
    var cnt = 0
    
    for i in 0..<totLines{
        var lenPerLine = 0
        var lineStr = String()
        var locLabel = SKLabelNode(fontNamed: mainFont)
        
        while lenPerLine < width{
            if cnt > words.count - 1{
                break
            }else{
                lineStr = lineStr + " " + words[cnt]
                lenPerLine = countElements(lineStr)
                cnt++
            }
        }
        
        // creation of the SKLabelNode itself
        locLabel.text = lineStr;
        // name each label node so you can animate it if u wish
        // the rest of the code should be self-explanatory
        locLabel.name = NSString(format: "line%d", i)
        locLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        locLabel.fontSize = 16;
        locLabel.fontColor = UIColor.whiteColor()
        let Top = node.frame.size.height/2-20*CGFloat(i)
        locLabel.position = CGPointMake(0 , Top )
        
        node.addChild(locLabel)
    }
    return node
}

func printFonts() {
    for family in UIFont.familyNames()
    {
        NSLog(family as String);
        
        for name in UIFont.fontNamesForFamilyName(family as String)
        {
            print("  ")
            println(name as String);
        }
    }
}

func makeTextCard(text: NSString) -> SKShapeNode{
    var card = SKShapeNode(rectOfSize: CGSize(width: 400, height: 300))
    card.name = "card"
    var backCard = SKShapeNode(rectOfSize: CGSize(width:400, height:300))
    backCard.position = CGPoint(x: 5, y: -5); backCard.zPosition = -1
    card.addChild(backCard)
    var textLabel = addTextNode(text, 35)
    textLabel.position = CGPoint(x: 0, y: card.frame.size.height/3)
    card.addChild(textLabel)
    card.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
    backCard.fillColor = SKColor.blackColor()
    card.zPosition = Z.textCard
    var nextButton = SKSpriteNode(imageNamed: playButtonImage)
    nextButton.xScale = 0.75; nextButton.yScale = 0.75
    nextButton.zPosition = CGFloat.max
    nextButton.position = CGPoint(x: 0, y: -card.frame.size.height/2 + nextButton.frame.size.height/2 + 10)
    nextButton.physicsBody = SKPhysicsBody(circleOfRadius: nextButton.frame.size.width/2)
    nextButton.physicsBody?.dynamic = false
    nextButton.name = "next"
    card.addChild(nextButton)
    return card
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func randomx(#mini: CGFloat, #maxi: CGFloat) -> CGFloat {
    return random() * (maxi - mini) + mini
}

func getBackGround() -> String{
    let result = floor(randomx(mini: 0, maxi: 8.0))
    switch result{
    case 0:
        return "bg0"
    case 1:
        return "bg1"
    case 2:
        return "bg2"
    case 3:
        return "bg3"
    case 4:
        return "bg4"
    case 5:
        return "bg5"
    case 6:
        return "bg6"
    case 7:
        return "bg7"
    default:
        return "uh"
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

import AVFoundation

class MusicSingleton {
    
    var backgroundMusicPlayer: AVAudioPlayer!
    class var sharedInstance :MusicSingleton {
        struct Music {
            static let instance = MusicSingleton()
        }
        
        return Music.instance
    }
    
    func stopMusic() {
        if backgroundMusicPlayer != nil {
            backgroundMusicPlayer.stop()
        }
    }
    
    func playMusic(filename: String) {
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
}