//
//  ModalShadedPresentationController.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

final class ModalShadedPresentationController: UIPresentationController {
    private lazy var shadedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
        
    // MARK: - Overrides
    
    override func presentationTransitionWillBegin() {
        guard
            let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator
            else { return }
        
        shadedView.alpha = 0
        shadedView.frame = container.bounds
        containerView?.addSubview(shadedView)
        
        coordinator.animate(alongsideTransition: { _ in
            self.shadedView.alpha = 1
        }, completion: nil)
    }
    
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { _ in
            self.shadedView.alpha = 0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            shadedView.removeFromSuperview()
        }
    }
}
