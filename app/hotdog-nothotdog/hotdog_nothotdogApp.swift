//
//  hotdog_nothotdogApp.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 23/12/2024.
//

import SwiftUI
import SwiftData

@main
struct hotdog_nothotdogApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView(cameraViewModel: CameraViewModel())
        }
    }
}
