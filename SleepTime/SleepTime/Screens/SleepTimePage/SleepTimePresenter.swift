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
    
    private lazy var scheduler = SleepTimeScheduler()
    
    private unowned let view: SleepTimeViewing
    private let soundManager: SleepTimeSoundManaging
    private let notificationManager: NotificationManaging
    
    init(view: SleepTimeViewing, notificationManager: NotificationManaging, soundManager: SleepTimeSoundManaging) {
        self.view = view
        self.notificationManager = notificationManager
        self.soundManager = soundManager
    }
    
    // MARK: - Flows
    
    private func startMainFlow() {
        notificationManager.scheduleNotification(at: alarmDate)
        
        if case .time(let time) = sleepTimer {
            let duration = TimeInterval(time) * 60.0 // to seconds
            startIntroFlow(forDuration: duration)
            startRecordingFlow(afterDelay: duration)
        } else {
            startRecordingFlow(afterDelay: 0)
        }
    }
    
    private func startIntroFlow(forDuration duration: TimeInterval) {
        state = .playing
        soundManager.playIntro(forDuration: duration)
    }
    
    private func startRecordingFlow(afterDelay delay: TimeInterval) {
        if delay > 0 {
            scheduler.startRecordingTimer(delay) { [weak self] in
                self?.state = .recording
            }
        } else {
            state = .recording
        }
        
        soundManager.startRecording(afterDelay: delay)
        scheduler.startAlarmTimer(fireAt: alarmDate) { [weak self] in
            self?.soundManager.stopRecording()
            self?.startAlarmFlow()
        }
    }
    
    private func startAlarmFlow() {
        state = .alarm
        soundManager.playAlarm()
        view.showAlarmAlert { [weak self] in
            self?.reset()
        }
    }
    
    // MARK: - State Actions
    
    private func pause() {
        state = .paused
        scheduler.pauseRecordingTimer()
        soundManager.pauseAll()
    }
    
    private func resume() {
        state = .playing
        scheduler.resumeRecordingTimer()
        soundManager.resumeAll()
    }
    
    private func reset() {
        soundManager.stopAll()
        
        notificationManager.cancelNotification()
        scheduler.stopRecordingTimer()
        scheduler.stopAlarmTimer()
        
        state = .idle
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
                pause()
            case .paused:
                resume()
            case .recording:
                reset()
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
