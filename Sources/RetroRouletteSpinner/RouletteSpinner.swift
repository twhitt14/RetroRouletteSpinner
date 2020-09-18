//
//  RouletteSpinner.swift
//  
//
//  Created by Trevor Whittingham on 9/18/20.
//

import UIKit

public struct RouletteSpinner {
    
    private enum RandomSurpriseType: Int, CaseIterable {
        case none = 0
        case jumpUp
        case jumpDown
        
        static func random() -> RandomSurpriseType {
            return RandomSurpriseType.allCases.randomElement()!
        }
    }
    
    // MARK: -
    // MARK: Properties
    
    public static var spinDuration = 4.4
    public static let pullbackTime = 0.5
    public static let decelerationTime = 1.0
    public static let endSurpriseDelayTime = 0.25
    public static let endSurpriseScrollTime = 0.25
    public static var comeToRestTime: Double {
        return decelerationTime + endSurpriseDelayTime + endSurpriseScrollTime
    }
    public static var mainSpinTime: Double {
        return spinDuration - pullbackTime - comeToRestTime
    }
    
    private static var hapticFeedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: -
    // MARK: Methods
    
    public static func spin(scrollView: UIScrollView, toView chosenView: UIView, addRandomSurprisesAtEnd: Bool, rowHeight: CGFloat, rowSpacing: CGFloat, duration: Double, useHaptics: Bool, beforeSurpriseEndCompletion: @escaping () -> Void, finalCompletion: @escaping () -> Void) {
        
        spinDuration = duration
        
        if useHaptics {
            hapticFeedbackGenerator = UIImpactFeedbackGenerator()
            hapticFeedbackGenerator?.prepare()
            generateAndFireTapTimers()
        }
        
        func scrollToChosenLabel(withOffset offset: CGFloat = 0) {
            let yValue = chosenView.center.y - scrollView.frame.height / 2 + offset
            scrollView.setContentOffset(CGPoint(x: 0, y: yValue), animated: false)
        }
        
        let topInset = scrollView.frame.height / 3
        scrollView.contentInset.top = topInset
        scrollView.verticalScrollIndicatorInsets.top = topInset
        
        UIView.animate(withDuration: pullbackTime, delay: 0, options: .curveEaseInOut, animations: {
            scrollView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
        }) { _ in
            
            var offsetBeforeSurprise: CGFloat = 0
            
            let random = RandomSurpriseType.random()
            switch random {
            case .none:
                break
            case .jumpUp:
                offsetBeforeSurprise = rowHeight + rowSpacing
            case .jumpDown:
                offsetBeforeSurprise = -(rowHeight + rowSpacing)
            }
            
            UIView.animate(withDuration: mainSpinTime, delay: 0, options: .curveEaseInOut, animations: {
                scrollToChosenLabel(withOffset: 300 + offsetBeforeSurprise)
            }) { _ in
                if addRandomSurprisesAtEnd {
                    UIView.animate(withDuration: decelerationTime, delay: 0, options: .curveEaseInOut, animations: {
                        scrollToChosenLabel(withOffset: offsetBeforeSurprise)
                    }) { _ in
                        beforeSurpriseEndCompletion()
                        
                        if useHaptics {
                            createTapTimerWithDelay(endSurpriseScrollTime / 2.5)
                        }
                        
                        UIView.animate(withDuration: endSurpriseScrollTime, delay: endSurpriseDelayTime, options: .curveEaseInOut, animations: {
                            scrollToChosenLabel()
                        }) { _ in
                            scrollView.contentInset.top = 0
                            scrollView.verticalScrollIndicatorInsets.top = 0
                            
                            resetVariablesAfterRoulette()
                            if offsetBeforeSurprise == 0 {
                                // need a little delay since the animation is instantly complete
                                Timer.scheduledTimer(withTimeInterval: endSurpriseDelayTime + endSurpriseScrollTime, repeats: false, block: { _ in
                                    finalCompletion()
                                })
                            } else {
                                finalCompletion()
                            }
                        }
                    }
                } else {
                    // `addRandomSurprisesAtEnd` was false
                    UIView.animate(withDuration: decelerationTime, delay: 0, options: .curveEaseInOut, animations: {
                        scrollToChosenLabel()
                    }) { _ in
                        beforeSurpriseEndCompletion()
                        
                        scrollView.contentInset.top = 0
                        scrollView.verticalScrollIndicatorInsets.top = 0
                        
                        resetVariablesAfterRoulette()
                        finalCompletion()
                    }
                }
            }
        }
    }
    
    private static func resetVariablesAfterRoulette() {
        hapticFeedbackGenerator = nil
    }
    
    private static func generateAndFireTapTimers() {
        
        // pullback taps
        let pullbackTaps = 0...2
        for tapNumber in pullbackTaps {
            createTapTimerWithDelay(Double(tapNumber) * pullbackTime / Double(pullbackTaps.count))
        }
        
        // spinning taps
        let allSpinningTapDelays = spinningTapDelays + spinningTapDelays.reversed()
        
        allSpinningTapDelays.enumerated().forEach { tuple in
            let offset = tuple.offset
            let shift = -0.02 // making the first tap just a tiny bit earlier
            let delay = shift + allSpinningTapDelays[0...offset].reduce(pullbackTime, +)
            createTapTimerWithDelay(delay)
            print(delay)
        }
        
        // bounce back taps
        let bouncebackTaps = 1...4
        for tapNumber in bouncebackTaps {
            createTapTimerWithDelay(pullbackTime + mainSpinTime + Double(tapNumber) * pullbackTime / Double(pullbackTaps.count))
        }
        
        // surprise tap code lives in the `spin()` method
    }
    
    private static func createTapTimerWithDelay(_ delay: TimeInterval) {
        let hapticTimer = Timer(timeInterval: delay, repeats: false) { _ in
            self.hapticFeedbackGenerator?.impactOccurred(intensity: 1)
            self.hapticFeedbackGenerator?.prepare()
        }
        
        RunLoop.main.add(hapticTimer, forMode: .default)
    }
    
    // MARK: -
    // MARK: Really long variable definitions
    
    private static let spinningTapDelays = [
        0.2,
        0.12,
        0.07,
        0.025,
        0.0125,
        0.011,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
        0.01,
    ]
}

