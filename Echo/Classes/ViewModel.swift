//
//  ViewModel.swift
//  Echo
//
//  Created by Yoshimasa Niwa on 5/1/21.
//  Copyright © 2021 Yoshimasa Niwa. All rights reserved.
//

import Combine
import Foundation

final class ViewModel: ObservableObject {
    @Published
    var isRunning: Bool = false
}
