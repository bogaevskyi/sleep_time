//
//  SleepTimeViewController.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

protocol SleepTimeViewing: AnyObject {
    var sleepTimerValue: String { get set }
    var alarmValue: String { get set }
    
    func update(viewState: SleepTimeState)
    
    func showTimerOptions(_ options: [SleepTimerOption], completion: @escaping (SleepTimerOption) -> Void)
    func showTimePicker(_ completion: @escaping (Date) -> Void)
    func showAlarmAlert(_ completion: @escaping () -> Void)
}

final class SleepTimeViewController: UIViewController {
    private enum Constants {
        static let buttonsHeight: CGFloat = 60
        static let playPauseButtonSpacing: CGFloat = 40
    }
    
    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.text = "Idle"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sleepTimerRow: ValueRow = {
        let row = ValueRow()
        row.title = "Sleep Timer"
        row.value = ""
        row.tapAction = { [weak self] in
            self?.presenter.viewDidTapTimer()
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight).isActive = true
        return row
    }()
    
    private lazy var alarmRow: ValueRow = {
        let row = ValueRow()
        row.title = "Alarm"
        row.value = ""
        row.tapAction = { [weak self] in
            self?.presenter.viewDidTapAlarm()
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight).isActive = true
        return row
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight).isActive = true
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(sleepTimerRow)
        stackView.addArrangedSubview(alarmRow)
        stackView.setCustomSpacing(Constants.playPauseButtonSpacing, after: alarmRow)
        stackView.addArrangedSubview(playPauseButton)
        
        return stackView
    }()
    
    var presenter: SleepTimePresenting!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        addStateLabel()
        addStackView()
        
        presenter.viewReady()
    }
    
    // MARK: - Add Views
    
    private func addStateLabel() {
        view.addSubview(stateLabel)
        stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
    }
    
    private func addStackView() {
        view.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.playPauseButtonSpacing).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func playPauseButtonTapped() {
        presenter.viewDidTapPlayPause()
    }
    
    // MARK: - Private
    
    private func updatePlayPauseButton(isPlay: Bool) {
        let title =  isPlay ? "Pause" : "Play"
        playPauseButton.setTitle(title, for: .normal)
    }
}

extension SleepTimeViewController: SleepTimeViewing {
    var sleepTimerValue: String {
        get { sleepTimerRow.value ?? "" }
        set { sleepTimerRow.value = newValue }
    }
    
    var alarmValue: String {
        get { alarmRow.value ?? "" }
        set { alarmRow.value = newValue }
    }
    
    func update(viewState: SleepTimeState) {
        switch viewState {
            case .idle:
                updatePlayPauseButton(isPlay: false)
            case .playing:
                updatePlayPauseButton(isPlay: true)
            case .recording:
                break
            case .paused:
                updatePlayPauseButton(isPlay: false)
            case .alarm:
                break
        }
        stateLabel.text = viewState.stringValue
    }
    
    func showTimerOptions(_ options: [SleepTimerOption], completion: @escaping (SleepTimerOption) -> Void) {
        let actionSheet = UIAlertController(title: nil, message: "Sleep Times", preferredStyle: .actionSheet)
        options.forEach { option in
            let action = UIAlertAction(title: option.stringValue, style: .default) { _ in
                completion(option)
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    func showTimePicker(_ completion: @escaping (Date) -> Void) {
        let timePicker = TimePickerViewController()
        timePicker.selectDateAction = completion
        present(timePicker, animated: true)
    }
    
    func showAlarmAlert(_ completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: "Alarm wend off", preferredStyle: .alert)
        let stopAction = UIAlertAction(title: "Stop", style: .default) { _ in
            completion()
        }
        alert.addAction(stopAction)
        present(alert, animated: true)
        
    }
}

extension SleepTimeState {
    var stringValue: String {
        switch self {
            case .idle: return "Idle"
            case .playing: return "Playing"
            case .recording: return "Recording"
            case .paused: return "Paused"
            case .alarm: return "Alarm"
        }
    }
}
