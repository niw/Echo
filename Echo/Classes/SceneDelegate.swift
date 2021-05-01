//
//  SceneDelegate.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var cancellableSet: Set<AnyCancellable> = []

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let viewModel = ViewModel()
        viewModel.$isRunning.sink { isRunning in
            if isRunning {
                AudioEchoSession.shared.start()
            } else {
                AudioEchoSession.shared.stop()
            }
        }.store(in: &cancellableSet)

        let mainView = MainView()
            .environmentObject(viewModel)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: mainView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
