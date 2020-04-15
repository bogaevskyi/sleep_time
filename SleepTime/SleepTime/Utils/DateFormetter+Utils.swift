//
//  DateFormatter+Utils.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var alarmDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
}
