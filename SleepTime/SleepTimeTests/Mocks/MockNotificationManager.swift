//
//  MockNotificationManager.swift
//  SleepTimeTests
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

@testable import SleepTime
import Foundation

final class MockNotificationManager: NotificationManaging {
    var requestAuthorizationCalled = false
    func requestAuthorization() {
        requestAuthorizationCalled = true
    }
    
    var scheduleNotificationCalledValue: Date?
    var scheduleNotificationCalled = false
    func scheduleNotification(at date: Date) {
        scheduleNotificationCalledValue = date
        scheduleNotificationCalled = true
    }
    
    var cancelNotificationCalled = false
    func cancelNotification() {
        cancelNotificationCalled = true
    }
}
