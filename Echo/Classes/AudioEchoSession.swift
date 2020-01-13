//
//  AudioEchoSession.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import AVFoundation
import Combine
import Foundation

class AudioEchoSession: NSObject {
    private var audioEngine = AVAudioEngine()

    override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidInterrupt(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteDidChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionMediaServicesDidLost(_:)), name: AVAudioSession.mediaServicesWereLostNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionMediaServicesDidReset(_:)), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)

        resetAudioSession()

        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: nil)
    }

    private(set) var isRunning: Bool = false

    func start() {
        guard !isRunning else { return }

        do {
            try self.audioEngine.start()
            self.isRunning = true
        } catch {
            print(error)
        }
    }

    func stop() {
        guard isRunning else { return }

        self.audioEngine.stop()
        isRunning = false
    }

    // MARK: - Notifications

    @objc
    public func audioSessionDidInterrupt(_ notification: NSNotification) {
        guard let interruptionTypeNumber = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeNumber.uintValue) else {
                return
        }

        print(interruptionType)

        switch interruptionType {
        case .began:
            // nothing we can do
            break
        case .ended:
            resetAudioSession()
            if (isRunning) {
                do {
                    try self.audioEngine.start()
                } catch {
                    print(error)
                }
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
        // TODO: implement this.
    }

    enum AudioSessionPortDescriptionUID: String {
        case WiredMicrophone = "Wired Microphone"
    }

    private func resetAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP])
            try session.setPreferredInput(session.availableInputs?.first(where: { (description) -> Bool in
                return description.uid == AudioSessionPortDescriptionUID.WiredMicrophone.rawValue
            }))
        } catch {
            print(error)
        }
    }
}
