//
//  TimePickerViewController.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

final class TimePickerViewController: UIViewController {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(toolbar)
        stackView.addArrangedSubview(datePicked)
        
        return stackView
    }()
    
    private lazy var datePicked: UIDatePicker = {
        let datePicked = UIDatePicker()
        datePicked.datePickerMode = .time
        datePicked.translatesAutoresizingMaskIntoConstraints = false
        return datePicked
    }()
    
    private lazy var toolbar: UIToolbar = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.items = [cancelButton, flexibleSpace, doneButton]
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    var selectDateAction: ((Date) -> Void)?
    
    private lazy var modalTransitionHandler = TimePickerModalTransition()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = modalTransitionHandler
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        addTapGestureRecognizer()
        
        addStackView()
        addBackgroundView()
        view.bringSubviewToFront(stackView)
    }
    
    // MARK: - Private
    
    private func addStackView() {
        view.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func addBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        selectDateAction?(datePicked.date)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func viewTapped() {
        dismiss(animated: true, completion: nil)
    }
}
