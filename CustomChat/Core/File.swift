//
//  File.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 18/05/24.
//

import SplineRuntime
import SwiftUI

struct ContentView: View {
    var body: some View {
        // fetching from cloud
        let url = URL(string: "https://build.spline.design/7Y9UIbTk0YOZXp342oNL/scene.splineswift")!

        // // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!

        try? SplineView(sceneFileURL: url).ignoresSafeArea(.all)
    }
}
