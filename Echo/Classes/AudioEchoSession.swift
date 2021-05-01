//
//  AudioEchoSession.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import AVFoundation
import Foundation

final class AudioEchoSession {
    static let shared: AudioEchoSession = .init()

    private var audioEngine: AVAudioEngine?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidInterrupt(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteDidChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionMediaServicesDidLost(_:)), name: AVAudioSession.mediaServicesWereLostNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionMediaServicesDidReset(_:)), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)

        do {
            try resetAudioSession()
            resetAudioEngine()
        } catch {
            print(error)
        }
    }

    enum AudioSessionPortDescriptionUID: String {
        case WiredMicrophone = "Wired Microphone"
    }

    private func resetAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP])
        try session.setPreferredInput(session.availableInputs?.first(where: { (description) -> Bool in
            return description.uid == AudioSessionPortDescriptionUID.WiredMicrophone.rawValue
        }))
    }

    private func resetAudioEngine() {
        if let audioEngine = audioEngine {
            audioEngine.stop()
            self.audioEngine = nil
        }

        let audioEngine = AVAudioEngine()
        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: nil)
        self.audioEngine = audioEngine
    }

    private(set) var isRunning: Bool = false

    func start() {
        guard !isRunning else { return }

        do {
            try startSession()
            isRunning = true
        } catch {
            print(error)
        }
    }

    private func startSession() throws {
        try AVAudioSession.sharedInstance().setActive(true)
        try audioEngine!.start() // Intentionally forcibly unwrap or assert crash.
    }

    func stop() {
        guard isRunning else { return }

        do {
            try stopSession()
            isRunning = false
        } catch {
            print(error)
        }
    }

    private func stopSession() throws {
        audioEngine!.stop() // Intentionally forcibly unwrap or assert crash.
        try AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - Notifications

    @objc
    public func audioSessionDidInterrupt(_ notification: NSNotification) {
        // Making a phone call can reach here.

        guard let userInfo = notification.userInfo,
            let interruptionTypeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeValue) else {
                return
        }

        switch interruptionType {
        case .began:
            print("interruption began")
        case .ended:
            print("interruption end")

            // NOTE: Based on the documentation, apps that don’t require user input to begin audio
            // playback can ignore `shouldResume` flag in `AVAudioSession.InterruptionOptions`
            // for `AVAudioSessionInterruptionOptionKey` and resume playback when an interruption ends.
            // See `AVAudioSession.InterruptionOptions.shouldResume`
            if isRunning {
                // TODO: do we really need to reconstruct audio engine? probably not.
                resumeSession()
            }
        default:
            break
        }
    }

    @objc
    public func audioSessionRouteDidChanged(_ notification: NSNotification) {
        print(AVAudioSession.sharedInstance().currentRoute)
    }

    @objc
    public func audioSessionMediaServicesDidLost(_ notification: NSNotification) {
        // TODO: implement this.
    }

    @objc
    public func audioSessionMediaServicesDidReset(_ notification: NSNotification) {
        // See General recommendations for handling `AVAudioSessionMediaServicesWereResetNotification`
        // at <https://developer.apple.com/library/archive/qa/qa1749/_index.html>
        resumeSession()
    }

    private func resumeSession() {
        do {
            try resetAudioSession()
            resetAudioEngine()
            if (isRunning) {
                try startSession()
            }
        } catch {
            print(error)
        }
    }
}
