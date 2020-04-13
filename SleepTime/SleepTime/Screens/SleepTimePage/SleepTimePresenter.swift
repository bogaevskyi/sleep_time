//
//  SleepTimePresenter.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

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
    private enum Sounds {
        static let nature = "nature"
        static let alarm = "alarm"
    }
    
    private lazy var alarmDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    // TODO: inject
    private lazy var player = AudioPlayer()
    
    // MARK: - Values
    
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
    
    init(view: SleepTimeViewing) {
        self.view = view
    }
}

extension SleepTimePresenter: SleepTimePresenting {
    func viewReady() {
        view.sleepTimerValue = sleepTimer.stringValue
        alarmDate = Date()
    }
    
    func viewDidTapPlayPause() {
        
        if case .time(let time) = sleepTimer {
            view.update(viewState: .playing)
            let duration: TimeInterval = Double(time) * 60.0 // to seconds
            player.playInLoop(Sounds.nature, duration: duration) {
                print("End sound")
            }
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
