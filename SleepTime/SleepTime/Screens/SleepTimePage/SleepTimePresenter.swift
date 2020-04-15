//
//  SleepTimePresenter.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

enum SleepTimeState {
    case idle
    case playing
    case recording
    case paused
    case alarm
    
    var canPause: Bool {
        switch self {
            case .playing:
            return true
            default:
            return false
        }
    }
}

protocol SleepTimePresenting {
    func viewReady()
    func viewDidTapPlayPause()
    func viewDidTapTimer()
    func viewDidTapAlarm()
}

enum SleepTimerOption {
    case off
    case time(_ : Int)
    
    var stringValue: String {
        switch self {
            case .off: return "Off"
            case .time(let time): return "\(time) min"
        }
    }
}

final class SleepTimePresenter {
    private lazy var alarmDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    // MARK: - Values
    
    private var pausedState: SleepTimeState?
    
    private var state: SleepTimeState = .idle {
        didSet {
            view.update(viewState: state)
        }
    }
    private var sleepTimer: SleepTimerOption = .time(20) {
        didSet {
            view.sleepTimerValue = sleepTimer.stringValue
        }
    }
    
    private var alarmDate: Date = Date() {
        didSet {
            view.alarmValue = alarmDateFormatter.string(from: alarmDate)
        }
    }

    // MARK: - Init
    
    private unowned let view: SleepTimeViewing
    private let soundManager: SleepTimeSoundManaging
    private let notificationManager: NotificationManaging
    
    init(view: SleepTimeViewing, notificationManager: NotificationManaging, soundManager: SleepTimeSoundManaging) {
        self.view = view
        self.notificationManager = notificationManager
        self.soundManager = soundManager
    }
    
    // MARK: - Private
    
    private func startMainFlow() {
        notificationManager.scheduleNotification(at: alarmDate)
        
        if case .time(let time) = sleepTimer {
            playNatureSound(forDuration: time)
        } else {
            startRecording()
        }
    }
    
    // MARK: -
    
    private func startRecording() {
        state = .recording
        let difference = alarmDate.timeIntervalSince(Date())
        soundManager.startRecording(forDuration: difference) { [weak self] _ in
            self?.runAlarmFlow()
        }
    }
    
    private func playNatureSound(forDuration duration: Int) {
        state = .playing
        let duration: TimeInterval = TimeInterval(duration) * 60.0 // to seconds
        soundManager.playIntro(forDuration: duration) { [weak self] in
            self?.startRecording()
        }
    }
    
    private func pauseNatureSound() {
        state = .paused
        soundManager.pauseIntro()
    }
    
    private func resumeNatureSound() {
        state = .playing
        soundManager.resumeIntro()
    }
    
    private func runAlarmFlow() {
        state = .alarm
        soundManager.playAlarm()
        view.showAlarmAlert { [weak self] in
            self?.resetAll()
        }
    }
    
    private func resetAll() {
        soundManager.pauseIntro()
        soundManager.pauseAlarm()
        soundManager.stopRecording()
        
        view.update(viewState: .idle)
    }
}

extension SleepTimePresenter: SleepTimePresenting {
    func viewReady() {
        view.update(viewState: state)
        view.sleepTimerValue = sleepTimer.stringValue
        alarmDate = Date()
        
        notificationManager.requestAuthorization()
        
        soundManager.setupSession()
        soundManager.observeInterruptionBegan { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.state.canPause {
                strongSelf.pausedState = strongSelf.state
                strongSelf.state = .paused
            }
        }
        soundManager.observeInterruptionEnded { [weak self] shouldResume in
            guard let strongSelf = self else { return }
            if let pausedState = strongSelf.pausedState {
                strongSelf.state = pausedState
            }
        }
    }
    
    func viewDidTapPlayPause() {
        switch state {
            case .idle:
                startMainFlow()
            case .playing:
                pauseNatureSound()
            case .paused:
                resumeNatureSound()
            case .recording:
                resetAll()
            case .alarm: break;
        }
    }
    
    func viewDidTapTimer() {
        let options: [SleepTimerOption] = [
            .off,
            .time(1),
            .time(5),
            .time(10),
            .time(15),
            .time(20)
        ]
        view.showTimerOptions(options) { [weak self] selected in
            self?.sleepTimer = selected
        }
    }
    
    func viewDidTapAlarm() {
        view.showTimePicker { [weak self] date in
            self?.alarmDate = date
        }
    }
}
