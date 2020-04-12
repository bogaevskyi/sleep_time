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
    func viewDidTapTimer()
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
    private var sleepTimer: SleepTimerOption = .time(20)
    
    private unowned let view: SleepTimeViewing
    
    init(view: SleepTimeViewing) {
        self.view = view
    }
}

extension SleepTimePresenter: SleepTimePresenting {
    func viewReady() {
        view.sleepTimerValue = sleepTimer.stringValue
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
            self?.view.sleepTimerValue = selected.stringValue
        }
    }
}
