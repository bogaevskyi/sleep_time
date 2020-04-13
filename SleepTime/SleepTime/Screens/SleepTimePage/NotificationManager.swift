//
//  NotificationManager.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 13.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    private enum Constants {
        static let notificationIdentifier = "SleepTime Local Notification"
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        // TODO: handel notification setttings with notificationCenter.getNotificationSettings
        
        notificationCenter.requestAuthorization(options: [.alert]) { allowed, error in
            if !allowed {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sleep Time"
        content.body = "Alarm went off"
        content.sound = UNNotificationSound.default
        
        let dateComponents = makeDateComponents(with: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: Constants.notificationIdentifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            print("notificationCenter ADD completion")
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - DateComponents
    
    private func makeDateComponents(with date: Date) -> DateComponents {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return dateComponents
    }
}
