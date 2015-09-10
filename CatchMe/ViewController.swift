//
//  ViewController.swift
//  CatchMe
//
//  Created by Ky Nguyen on 8/25/15.
//  Copyright (c) 2015 Ky Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class ViewController: UIViewController {

    
// declaration
    
    var round = 0
    var score = 0
    
    var targetValue = 0
    var timer = NSTimer()
    var interval = 0.025
    var currentValue = 0
    
    var sliderStep = 1
    
    let maxRound = 10
    
    let intervalMax = 0.025
    
    var player : AVAudioPlayer! = nil
    
// UI
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var roundDisplayer: UILabel!
    
    @IBOutlet weak var scoreDisplayer: UILabel!
    
    @IBOutlet weak var targetDisplayer: UILabel!
    
    @IBOutlet weak var gotYouButton: UIButton!
    
    @IBAction func gotYou(sender: AnyObject) {
        
        if gotYouButton.titleLabel!.text == "Try again" {
            
            startGame()
            
            gotYouButton.setTitle("Hit me", forState: UIControlState.Normal)
        }
        else {
            
            timer.invalidate()
            let difference = abs(currentValue - targetValue)
            let point = 100 - difference
            score += point
            
            playMySound()

            showRoundResult("Target value is \(targetValue)\nYou caught \(currentValue)\nYou got \(point)", title: selectTitleBaseScore(difference))
        }
    }
    
    
    
    
    
// override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSliderUI()

        loadHitMeSound()
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
// functions
    
    func generateTargetValue() {
        
        targetValue = Int(arc4random_uniform(100 + 1))
    }
    
    func initTimer() {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("timerRun"), userInfo: nil, repeats: true)
 
    }
    
    func fetchDataToUI() {
        
        targetDisplayer.text = String(targetValue)
        scoreDisplayer.text = String(score)
        roundDisplayer.text = String(round)
    }
    
    func timerRun() {
        
        if currentValue >= 100 {
            
            sliderStep = -1
        }
        
        if currentValue <= 0 {
            
            sliderStep = 1
        }
        
        currentValue += sliderStep
        
        slider.value = Float(currentValue)
    }
    
    func showRoundResult(message: String, title: String) {
        
        var action = UIAlertAction(title: "OK", style: .Default,
            handler: {
                action in self.startNewRound()
        })
        
        showAlert(title, message: message, action: action)
    }
    
    func showGameResult(title: String, message: String) {
        
        var action = UIAlertAction(title: "OK", style: .Default,
            handler: nil)
        
        showAlert(title, message: message, action: action)
    }
    
    func showAlert(title:String, message:String, action: UIAlertAction) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func addFadeAnimation() {
        
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        view.layer.addAnimation(transition, forKey: nil)
        
    }
    
    func startNewRound() {
        
        if round < maxRound {
            
            interval -= 0.002
            
            round++
            
            generateTargetValue()
            
            initTimer()
        }
        else {
            
            endGame()
        }
        
        fetchDataToUI()
    }
    
    func startGame() {
        
        reset()

        gotYouButton.enabled = true
        
        startNewRound()
    }
    
    func reset() {
        
        round = 0
        score = 0
        currentValue = 0
        slider.value = Float(currentValue)
        interval = intervalMax
        
        loadHitMeSound()

        timer.invalidate()
    }
    
    func endGame() {
        
        loadResultSound()
        timer.invalidate()
        
        var title = selectResultTitle()
        
        playMySound()
        
        showGameResult(title, message: "You scored \(score).")
        
        gotYouButton.setTitle("Try again", forState: UIControlState.Normal)
    }
    
    func selectResultTitle() -> String {
        
        var title = ""
        if score > 950 {
            
            title = "Excellent"
        }
        else if score > 800 {
            
            title = "Good catch"
        }
            
        else {
            
            title = "Nice try"
        }

        return title
    }
    
    func setSliderUI() {
        
        let thumbIcon = UIImage(named: "SliderThumb-Normal")
        slider.setThumbImage(thumbIcon, forState: .Normal)
        
        let thumbIconHighlight = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbIconHighlight, forState: .Highlighted)
        
        let inset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft") {
            
            let trackLeftResizable = trackLeftImage.resizableImageWithCapInsets(inset)
            
            slider.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
        }
        
        if let trackRightImage = UIImage(named: "SliderTrackRight") {
            
            let trackRightResizable = trackRightImage.resizableImageWithCapInsets(inset)
            slider.setMaximumTrackImage(trackRightResizable, forState: .Normal)
        }

    }
    
    func selectTitleBaseScore(difference:Int) -> String {
        
        title = ""
        
        if difference == 0
        {
            return "Perfect"
        }
        else if difference < 3
        {
            return "You almost had it"
        }
        else if difference < 10
        {
            return "Pretty good"
        }
        else
        {
            return "Not even close"
        }
    }
    
    func playMySound() {

        player.play()
    }
    
    func loadSound(name: String, ext: String) {
        
        let path = NSBundle.mainBundle().pathForResource(name, ofType:ext)
        let fileURL = NSURL(fileURLWithPath: path!)
        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        player.prepareToPlay()
    }
    
    func loadHitMeSound() {
        
        loadSound("HitMe", ext: "mp3")
    }
    
    func loadResultSound() {
        
        loadSound("result", ext: "wav")
    }
    
    
}

