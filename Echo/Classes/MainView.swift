//
//  MainView.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 12/23/19.
//  Copyright © 2019 Yoshimasa Niwa. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Use Control Center to change output device from headphones to Bluetooth audio device such as AirPods.")
        }.padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
