//
//  AppDelegate.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var audioEchoSession: AudioEchoSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let audioEchoSession = AudioEchoSession()
        audioEchoSession.start()

        self.audioEchoSession = audioEchoSession

        return true
    }
}
