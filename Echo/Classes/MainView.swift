//
//  MainView.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $viewModel.isRunning) {
                        Text("Microphone to headphones")
                    }
                    Text("Use Control Center to change output device from headphones to Bluetooth audio device such as AirPods.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitle("Echo")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(ViewModel())
    }
}
