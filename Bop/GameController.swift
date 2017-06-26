//
//  ViewController.swift
//  Bop
//
//  Created by Nick Jones on 31/10/2016.
//  Copyright © 2016 NickJones. All rights reserved.
//

import UIKit

class GameController: UIViewController {

    @IBOutlet var leftLoadingBar: UIView!
    @IBOutlet var rightLoadingBar: UIView!
    
    @IBOutlet var blueView: UIView!
    @IBOutlet var yellowView: UIView!
    @IBOutlet var redView: UIView!
    @IBOutlet var greenView: UIView!
    
    @IBOutlet var yellowButton: UIButton!
    @IBOutlet var greenButton: UIButton!
    @IBOutlet var blueButton: UIButton!
    @IBOutlet var redButton: UIButton!
    
    var sections: [UIView]!
    var buttons: [UIView]!
    var failureView: UIView!
    
    var currentSection: Int = 0
    var remainingTime = 5.0 {
        didSet {
            remainingTime = min(remainingTime, 5.0)
        }
    }
    var currentScore = 0
    
    var countdown: Timer!
    
    override func viewDidAppear(_ animated: Bool) {
        
        sections = [yellowView, greenView, blueView, redView]
        buttons = [yellowButton, greenButton, blueButton, redButton]
        
        nextSection()
        
        countdown = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimerBars), userInfo: nil, repeats: true)
    }
    
    @objc func newGame() {
        failureView.removeFromSuperview()
        remainingTime = 5
        currentScore = 0
        countdown = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimerBars), userInfo: nil, repeats: true)
        nextSection()
    }
    
    @objc func updateTimerBars() {
        
        if (remainingTime <= 0) {
            countdown.invalidate()
            gameOver()
            return
        }
        
        let multiplier = 0.001 + ((Double(currentScore) + 0.0000001) / 20000)
        let maximumSpeed = min(multiplier, 0.06)
        
        remainingTime = remainingTime - maximumSpeed
        
        leftLoadingBar.frame.size.height = view.frame.size.height * CGFloat((remainingTime / 5.0))
        rightLoadingBar.frame.size.height = view.frame.size.height * CGFloat((remainingTime / 5.0))
        leftLoadingBar.center.y = view.frame.size.height / 2
        rightLoadingBar.center.y = view.frame.size.height / 2
        
        view.layoutIfNeeded()
    }
    
    private func nextSection() {
        
        var availableSections = [UIView]()

        for section in sections {
            section.alpha = 0.2
            if section.tag != currentSection {
                availableSections.append(section)
            }
        }
        
        let nextSection = Int(arc4random_uniform(UInt32(availableSections.count)))
        
        availableSections[nextSection].alpha = 1
        currentSection = availableSections[nextSection].tag
    }
    
    func gameOver() {
        countdown.invalidate()
        
        failureView = UIView(frame: view.frame)
        failureView.backgroundColor = .clear
        failureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newGame)))
        
        let failureBacker = UIView(frame: view.frame)
        failureBacker.alpha = 0
        failureBacker.backgroundColor = .black
        
        failureView.addSubview(failureBacker)
        
        let restartButton = UIButton(frame: CGRect(
            x: view.frame.size.width * 0.25,
            y: view.frame.size.height * 0.5 - 10,
            width: view.frame.size.width * 0.5,
            height: 20)
        )
        restartButton.setTitle("Try again", for: .normal)
        restartButton.alpha = 0
        failureView.addSubview(restartButton)
        
        let totalScore = UILabel(frame: restartButton.frame)
        totalScore.text = "Final score: \(currentScore)"
        totalScore.textAlignment = .center
        totalScore.textColor = .white
        totalScore.frame.origin.y += 30
        totalScore.alpha = 0
        failureView.addSubview(totalScore)
        
        currentScore = 0
        
        view.addSubview(failureView)
        
        UIView.animate(withDuration: 0.3) {
            failureBacker.alpha = 0.7
            restartButton.alpha = 1
            totalScore.alpha = 1
        }
        
    }
    
    @IBAction func sectionTapped(_ sender: UIButton) {
        if (sender.tag == currentSection) {
            let point = UILabel(frame: CGRect(x: 0, y: (view.frame.size.height / 2) - 10, width: view.frame.size.width, height: 20))
            point.text = "+1"
            point.alpha = 0
            point.textAlignment = .center
            point.textColor = .black
            view.addSubview(point)
            
            UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: .calculationModeLinear, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    point.frame.origin.y -= 50
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    point.alpha = 1
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                    point.alpha = 0
                })
                
                }, completion: { (done) in
                    point.removeFromSuperview()
            })
            
            remainingTime = remainingTime + (0.5 + (Double(Double(currentScore) + 0.000001) / 50))
            currentScore = currentScore + 1
            nextSection()
            return
        }
        
        countdown.invalidate()
        gameOver()
    }
}

