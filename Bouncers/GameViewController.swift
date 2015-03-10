import UIKit
import SpriteKit
import AVFoundation
import iAd

class GameViewController: UIViewController, ADInterstitialAdDelegate {
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    var requestingAd = false
    var button = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = IntroScene(size: view.bounds.size)
        let skView = view as SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadInterstitialAd", name: "playAd", object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loadInterstitialAd() {
        
        if !requestingAd {
            interstitialAd = ADInterstitialAd()
            interstitialAd.delegate = self
            requestingAd = true
        }
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        if interstitialAd != nil && requestingAd {
            interstitialAdView = UIView()
            interstitialAdView.frame = view.bounds
            println("in ad code")
            //view.addSubview(interstitialAdView)
            
            interstitialAd.presentInView(interstitialAdView)
            button.frame = CGRect(x: 10, y:  10, width: 40, height: 40)
            button.setBackgroundImage(UIImage(named: "circle_play"), forState: UIControlState.Normal)
            button.addTarget(self, action: Selector("close"), forControlEvents: UIControlEvents.TouchDown)
            view.addSubview(button)
            
            //interstitialAd.presentInView(interstitialAdView)
            requestingAd = false
        }
        UIViewController.prepareInterstitialAds()
    }
    
    func close() {
        
        interstitialAdView.removeFromSuperview()
        //self.button!.removeFromSuperview()
        
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
}



