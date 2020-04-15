//
//  AudioSession.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 14.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioSession {
    var interruptionBeganHandler: (() -> Void)?
    var interruptionEndedHandler: ((_ shouldResume: Bool) -> Void)?
    
    func setup() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            session.requestRecordPermission { allowed in
                // TODO: handle record permission result
                if allowed {
                    print("RequestRecordPermission allowed")
                } else {
                    print("RequestRecordPermission not allowed")
                }
            }
            subscribeForInterruption()
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func subscribeForInterruption() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    // MARK: - Notification handler
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        switch type {
            case .began:
                interruptionBeganHandler?()
            case .ended:
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    interruptionEndedHandler?(true)
                    return
                }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                interruptionEndedHandler?(options.contains(.shouldResume))
            @unknown default:
                break
        }
    }
}
