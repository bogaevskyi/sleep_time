//
//  SceneDelegate.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeSleepTimeVC()
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func makeSleepTimeVC() -> UIViewController {
        let vc = SleepTimeViewController()
        vc.presenter = SleepTimePresenter(
            view: vc,
            notificationManager: NotificationManager(),
            soundManager: SleepTimeSoundManager()
        )
        return vc
    }
}

