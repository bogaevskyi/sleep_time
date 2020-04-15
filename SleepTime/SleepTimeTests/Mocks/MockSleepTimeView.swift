//
//  MockSleepTimeView.swift
//  SleepTimeTests
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

@testable import SleepTime
import Foundation

final class MockSleepTimeView: SleepTimeViewing {
    var sleepTimerValue: String = ""
    
    var alarmValue: String = ""
    
    var updateViewStateCalledValue: SleepTimeState?
    var updateViewStateCalled = false
    func update(viewState: SleepTimeState) {
        updateViewStateCalledValue = viewState
        updateViewStateCalled = true
    }
    
    var showTimerOptionsCompletion: ((SleepTimerOption) -> Void)?
    var showTimerOptionsCompletionStub: SleepTimerOption?
    var showTimerOptionsCalled = false
    func showTimerOptions(_ options: [SleepTimerOption], completion: @escaping (SleepTimerOption) -> Void) {
        showTimerOptionsCompletion = completion
        if let stub = showTimerOptionsCompletionStub {
            completion(stub)
        }
        showTimerOptionsCalled = true
    }
    
    var showTimePickerCompletion: ((Date) -> Void)?
    var showTimePickerCompletionStub: Date?
    var showTimePickerCalled = false
    func showTimePicker(_ completion: @escaping (Date) -> Void) {
        showTimePickerCompletion = completion
        if let stub = showTimePickerCompletionStub {
            completion(stub)
        }
        showTimePickerCalled = true
    }
    
    var showAlarmAlertCompletion: (() -> Void)?
    var showAlarmAlertCalled = false
    func showAlarmAlert(_ completion: @escaping () -> Void) {
        showAlarmAlertCompletion = completion
        showAlarmAlertCalled = true
    }
}
