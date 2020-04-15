//
//  SleepTimeSoundManager.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 14.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

protocol SleepTimeSoundManaging {
    // Session
    func setupSession()
    
    // Interruption
    func observeInterruptionBegan(_ handler: @escaping () -> Void)
    func observeInterruptionEnded(_ handler: @escaping (_ shouldResume: Bool) -> Void)
    
    // Intro sound
    func playIntro(forDuration duration: TimeInterval, completion: @escaping () -> Void)
    func resumeIntro()
    func pauseIntro()
    
    // Alarm sound
    func playAlarm()
    func pauseAlarm()
    
    // Recording
    func startRecording(forDuration duration: TimeInterval, completion: @escaping (Bool) -> Void)
    func stopRecording()
}

final class SleepTimeSoundManager {
    private enum Sounds {
        static let intro = "nature.mp4"
        static let alarm = "alarm.mp4"
    }
    
    private lazy var session = AudioSession()
    
    private lazy var player = AudioPlayer()
    private lazy var loopPlayer = AudioLoopPlayer()
    private lazy var recorder = AudioRecorder()
    
    private var interruptionBeganHandler: (() -> Void)?
    private var interruptionEndedHandler: ((_ shouldResume: Bool) -> Void)?
}

extension SleepTimeSoundManager: SleepTimeSoundManaging {
    // MARK: - Session
    
    func setupSession() {
        session.setup()
        session.interruptionBeganHandler = { [weak self] in
            self?.interruptionBeganHandler?()
            self?.loopPlayer.pause()
            self?.player.stop()
        }
        session.interruptionEndedHandler = { [weak self] shouldResume in
            self?.interruptionEndedHandler?(shouldResume)
            guard shouldResume else { return }
            self?.loopPlayer.resume()
        }
    }
    
    // MARK: - Interruption
    
    func observeInterruptionBegan(_ handler: @escaping () -> Void) {
        interruptionBeganHandler = handler
    }
    
    func observeInterruptionEnded(_ handler: @escaping (_ shouldResume: Bool) -> Void) {
        interruptionEndedHandler = handler
    }
    
    // MARK: - Intro sound
    
    func playIntro(forDuration duration: TimeInterval, completion: @escaping () -> Void) {
        loopPlayer.play(Sounds.intro, duration: duration, completion: completion)
    }
    
    func resumeIntro() {
        loopPlayer.resume()
    }
    
    func pauseIntro() {
        loopPlayer.pause()
    }
    
    // MARK: - Alarm sound
    
    func playAlarm() {
        player.play(Sounds.alarm)
    }
    
    func pauseAlarm() {
        player.pause()
    }
    
    // MARK: - Recording
    
    func startRecording(forDuration duration: TimeInterval, completion: @escaping (Bool) -> Void) {
        recorder.startRecording(forDuration: duration, completion: completion)
    }
    
    func stopRecording() {
        recorder.stopRecording()
    }
}
