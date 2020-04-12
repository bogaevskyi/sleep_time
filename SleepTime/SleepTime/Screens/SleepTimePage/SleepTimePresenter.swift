//
//  SleepTimePresenter.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import Foundation

protocol SleepTimePresenting {}

final class SleepTimePresenter {
    private unowned let view: SleepTimeViewing
    
    init(view: SleepTimeViewing) {
        self.view = view
    }
}

extension SleepTimePresenter: SleepTimePresenting {}
