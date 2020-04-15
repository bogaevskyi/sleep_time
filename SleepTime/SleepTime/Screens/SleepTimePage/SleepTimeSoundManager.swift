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
    func playIntro(forDuration duration: TimeInterval)
    func resumeIntro()
    func pauseIntro()
    
    // Alarm sound
    func playAlarm()
    func pauseAlarm()
    
    // Recording
    func startRecording(afterDelay delay: TimeInterval)
    func stopRecording()
    
    // All
    func pauseAll()
    func resumeAll()
    func stopAll()
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
            self?.pauseAll()
        }
        session.interruptionEndedHandler = { [weak self] shouldResume in
            self?.interruptionEndedHandler?(shouldResume)
            guard shouldResume else { return }
            self?.resumeAll()
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
    
    func playIntro(forDuration duration: TimeInterval) {
        loopPlayer.play(Sounds.intro, duration: duration)
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
    
    /// Start recording.
    /// - Parameters:
    ///   - delay: A recording will start after delay time in seconds.
    func startRecording(afterDelay delay: TimeInterval) {
        recorder.startRecording(afterDelay: delay)
    }
    
    func stopRecording() {
        recorder.stopRecording()
    }
    
    // MARK: - All
    
    func pauseAll() {
        loopPlayer.pause()
        recorder.pause()
        player.stop()
    }
    
    func resumeAll() {
        loopPlayer.resume()
        recorder.resume()
    }
    
    func stopAll() {
        loopPlayer.stop()
        player.stop()
        recorder.stopRecording()
    }
}
