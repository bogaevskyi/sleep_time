//
//  SleepTimeViewController.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

protocol SleepTimeViewing: AnyObject {}

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
        row.value = "20 min"
        row.tapAction = { [weak self] in
            print("Sleep Timer row tapped")
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight).isActive = true
        return row
    }()
    
    private lazy var alarmRow: ValueRow = {
        let row = ValueRow()
        row.title = "Alarm"
        row.value = "08:30 am"
        row.tapAction = { [weak self] in
            print("Alarm row tapped")
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
        print("Play/Pause button tapped")
    }
}

extension SleepTimeViewController: SleepTimeViewing {}
