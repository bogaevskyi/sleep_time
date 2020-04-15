//
//  MockSleepTimeSoundManager.swift
//  SleepTimeTests
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

@testable import SleepTime
import Foundation

final class MockSleepTimeSoundManager: SleepTimeSoundManaging {
    var setupSessionCalled = false
    func setupSession() {
        setupSessionCalled = true
    }
    
    var observeInterruptionBeganHandler: (() -> Void)?
    var observeInterruptionBeganCalled = false
    func observeInterruptionBegan(_ handler: @escaping () -> Void) {
        observeInterruptionBeganHandler = handler
        observeInterruptionBeganCalled = true
    }
    
    var observeInterruptionEndedHandler: ((Bool) -> Void)?
    var observeInterruptionEndedCalled = false
    func observeInterruptionEnded(_ handler: @escaping (Bool) -> Void) {
        observeInterruptionEndedHandler = handler
        observeInterruptionEndedCalled = true
    }
    
    var playIntroCalledValue: TimeInterval?
    var playIntroCalled = false
    func playIntro(forDuration duration: TimeInterval) {
        playIntroCalledValue = duration
        playIntroCalled = true
    }
    
    func resumeIntro() {
    }
    
    func pauseIntro() {
    }
    
    func playAlarm() {
    }
    
    func pauseAlarm() {
    }
    
    func startRecording(afterDelay delay: TimeInterval) {
    }
    
    func stopRecording() {
    }
    
    func pauseAll() {
    }
    
    func resumeAll() {
    }
    
    func stopAll() {
    }
}
