//
//  ValueRow.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

final class ValueRow: UIView {
    private enum Constants {
        static let fontSize: CGFloat = 16
        static let defaultColor: UIColor = .secondarySystemBackground
        static let offset: CGFloat = 16
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: Constants.fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .bold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    var tapAction: (() -> Void)?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        setupView()
        addTitleLabel()
        addValueLabel()
        addTapGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setupView() {
        backgroundColor = Constants.defaultColor
        layer.cornerRadius = 10
    }
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }
    
    private func addValueLabel() {
        addSubview(valueLabel)
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.offset).isActive = true
        valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func addTitleLabel() {
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.offset).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func animateBackground() {
        let blink = CABasicAnimation(keyPath: "backgroundColor")
        blink.duration = 0.15
        blink.fromValue = Constants.defaultColor.cgColor
        blink.toValue = Constants.defaultColor.withAlphaComponent(0.5).cgColor
        blink.autoreverses = true
        layer.add(blink, forKey: nil)
    }
    
    // MARK: - Actions
    
    @objc private func viewTapped() {
        animateBackground()
        tapAction?()
    }
}
