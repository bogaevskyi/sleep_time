//
//  SleepTimePresenterTests.swift
//  SleepTimeTests
//
//  Created by Andrew Bogaevskyi on 15.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

@testable import SleepTime
import XCTest

class SleepTimePresenterTests: XCTestCase {
    private var viewMock: MockSleepTimeView!
    private var notificationManagerMock: MockNotificationManager!
    private var soundManagerMock: MockSleepTimeSoundManager!
    private var sut: SleepTimePresenter!
    
    override func setUp() {
        super.setUp()
        
        viewMock = MockSleepTimeView()
        notificationManagerMock = MockNotificationManager()
        soundManagerMock = MockSleepTimeSoundManager()
        sut = SleepTimePresenter(
            view: viewMock,
            notificationManager: notificationManagerMock,
            soundManager: soundManagerMock
        )
    }
    
    override func tearDown() {
        viewMock = nil
        notificationManagerMock = nil
        soundManagerMock = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSetupViewOnViewReady() {
        // When
        sut.viewReady()
        
        // Then
        XCTAssertTrue(viewMock.updateViewStateCalled)
        XCTAssertEqual(viewMock.updateViewStateCalledValue, .idle)
        XCTAssertEqual(viewMock.sleepTimerValue, "20 min")
        XCTAssertEqual(viewMock.alarmValue, DateFormatter.alarmDateFormatter.string(from: Date()))
    }
    
    func testSetupSoundManagerOnViewReady() {
        // When
        sut.viewReady()
        
        // Then
        XCTAssertTrue(soundManagerMock.setupSessionCalled)
        XCTAssertTrue(soundManagerMock.observeInterruptionBeganCalled)
        XCTAssertNotNil(soundManagerMock.observeInterruptionBeganHandler)
        XCTAssertTrue(soundManagerMock.observeInterruptionEndedCalled)
        XCTAssertNotNil(soundManagerMock.observeInterruptionEndedHandler)
    }
    
    func testSetupNotificationManagerOnViewReady() {
        // When
        sut.viewReady()
        
        // Then
        XCTAssertTrue(notificationManagerMock.requestAuthorizationCalled)
    }
    
    // MARK: - Main Flow
    
    func testScheduleNotificationWhenStartMainFlow() {
        // Given
        let notificationDate = Date()
        setStubAlarmDate(notificationDate)
        
        // When
        sut.viewDidTapPlayPause()
        
        // Then
        XCTAssertTrue(notificationManagerMock.scheduleNotificationCalled)
        XCTAssertEqual(notificationManagerMock.scheduleNotificationCalledValue, notificationDate)
    }
    
    func testRunIntroSoundWhenStartMainFlowWithTimerOn() {
        // Given
        let givenTime = 1
        setStubSleepTimer(.time(givenTime))
        
        // When
        sut.viewDidTapPlayPause()
        
        // Then
        XCTAssertTrue(viewMock.updateViewStateCalled)
        XCTAssertEqual(viewMock.updateViewStateCalledValue, .playing)
        XCTAssertTrue(soundManagerMock.playIntroCalled)
        XCTAssertEqual(soundManagerMock.playIntroCalledValue, TimeInterval(givenTime) * 60.0)
    }
    
    // MARK: - Helper methods
    
    func setStubAlarmDate(_ date: Date) {
        viewMock.showTimePickerCompletionStub = date
        sut.viewDidTapAlarm()
    }
    
    func setStubSleepTimer(_ sleepTimer: SleepTimerOption) {
        viewMock.showTimerOptionsCompletionStub = sleepTimer
        sut.viewDidTapTimer()
    }
}
