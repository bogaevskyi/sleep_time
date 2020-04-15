//
//  SleepTimeScheduler.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

final class SleepTimeScheduler {
    private var recordingTimer: Timer?
    private var recordingTimerCompletion: (() -> Void)?
    private var recordingTimerInterval: TimeInterval = 0
    private var recordingTimerStartTime: TimeInterval = 0
    private var recordingTimerRemainingTime: TimeInterval = 0
    
    private var alarmTimer: Timer?
    private var alarmTimerCompletion: (() -> Void)?
    
    // MARK: - Start Recording
    
    func startRecordingTimer(_ timeInterval: TimeInterval, completion: @escaping () -> Void) {
        recordingTimerInterval = timeInterval
        recordingTimerCompletion = completion
        recordingTimerStartTime = Date.timeIntervalSinceReferenceDate
        
        let timer = Timer(timeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.fireRecordingTimer()
        }
        
        RunLoop.current.add(timer, forMode: .common)
        recordingTimer = timer
    }
    
    func pauseRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let elapsed = Date.timeIntervalSinceReferenceDate - recordingTimerStartTime
        recordingTimerRemainingTime = recordingTimerInterval - elapsed
    }
    
    func resumeRecordingTimer() {
        let timer = Timer(timeInterval: recordingTimerRemainingTime, repeats: false) { [weak self] _ in
            self?.fireRecordingTimer()
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        recordingTimerCompletion = nil
        recordingTimerInterval = 0
        recordingTimerStartTime = 0
        recordingTimerRemainingTime = 0
    }
    
    private func fireRecordingTimer() {
        recordingTimerCompletion?()
        stopRecordingTimer()
    }
    
    // MARK: - Alarm
    
    func startAlarmTimer(fireAt date: Date, completion: @escaping () -> Void) {
        alarmTimerCompletion = completion
        let timer = Timer(fire: date, interval: 0.0, repeats: false) { [weak self] _ in
            self?.fireAlarmTimer()
        }
        RunLoop.current.add(timer, forMode: .common)
        alarmTimer = timer
    }
    
    func stopAlarmTimer() {
        alarmTimer?.invalidate()
        alarmTimer = nil
        alarmTimerCompletion = nil
    }
    
    private func fireAlarmTimer() {
        alarmTimerCompletion?()
        stopAlarmTimer()
    }
}
